using System.Text;
using EventManagement.Core.Interfaces;
using EventManagement.Infrastructure.Data;
using EventManagement.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// 1. Configure ProblemDetails & CORS
builder.Services.AddProblemDetails();

var allowedOriginsConfig = builder.Configuration["AllowedOrigins"]
    ?? "http://localhost:5173,http://localhost:3000,http://localhost:8080,http://127.0.0.1:5173,http://localhost:58458";
var allowedOrigins = allowedOriginsConfig
    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        if (builder.Environment.IsDevelopment() || allowedOrigins.Contains("*"))
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        }
        else
        {
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials();
        }
    });
});

// 2. PostgreSQL DbContext Configuration (Neon Cloud DB)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException("DefaultConnection database connection string is not configured in Environment Variables or User Secrets.");
}

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

// 3. Register Services in DI Container
builder.Services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();
builder.Services.AddHttpClient<IAiWorkflowService, AiWorkflowService>();

// 4. Configure Real JWT Bearer Authentication
var secretKey = builder.Configuration["JwtSettings:SecretKey"];
if (string.IsNullOrWhiteSpace(secretKey))
{
    throw new InvalidOperationException("JwtSettings:SecretKey is not configured in Environment Variables or User Secrets.");
}

var issuer = builder.Configuration["JwtSettings:Issuer"] ?? "EventCraft.Api";
var audience = builder.Configuration["JwtSettings:Audience"] ?? "EventCraft.Client";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
        ValidateIssuer = true,
        ValidIssuer = issuer,
        ValidateAudience = true,
        ValidAudience = audience,
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});

// 5. Add Controllers & Swagger with JWT Bearer Authentication Support
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "EventCraft Web API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer {token}'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// Configure listening port for Railway or default to 8080
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

var app = builder.Build();

// 6. Configure HTTP pipeline (CORS & Global Exception Handler)
app.UseCors("AllowAll");
app.UseMiddleware<EventManagement.Api.Middleware.GlobalExceptionHandlerMiddleware>();

app.UseSwagger();
app.UseSwaggerUI();

// Root health check endpoint with real DB Connectivity Verification
app.MapGet("/", async (AppDbContext dbContext) =>
{
    bool canConnect = false;
    try
    {
        canConnect = await dbContext.Database.CanConnectAsync();
    }
    catch { }

    return Results.Ok(new 
    { 
        status = canConnect ? "Healthy" : "Degraded", 
        service = "EventManagement API (.NET 8)", 
        database = canConnect ? "Neon PostgreSQL (Connected)" : "Neon PostgreSQL (Disconnected)",
        timestamp = DateTime.UtcNow 
    });
});

app.MapGet("/health", async (AppDbContext dbContext) =>
{
    bool canConnect = false;
    try
    {
        canConnect = await dbContext.Database.CanConnectAsync();
    }
    catch { }

    if (!canConnect)
    {
        return Results.Json(new { status = "Degraded", database = "Disconnected" }, statusCode: 530);
    }

    return Results.Ok(new { status = "Healthy", database = "Connected", timestamp = DateTime.UtcNow });
});

app.UseAuthentication();
app.UseAuthorization();

// 7. Map Controllers
app.MapControllers();

// 8. Seed Realistic Sri Lankan Venues, Hotels and Resources on Startup
using (var scope = app.Services.CreateScope())
{
    try
    {
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await context.Database.MigrateAsync();
        await DbInitializer.SeedAsync(context);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Database Migration / Seeding notice: {ex.Message}");
    }
}

app.Run();

public partial class Program { }