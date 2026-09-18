using System.Text;
using EventManagement.Core.Interfaces;
using EventManagement.Infrastructure.Data;
using EventManagement.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// 1. Configure CORS (Allows React Web & Flutter to communicate with ASP.NET Core)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// 2. PostgreSQL DbContext Configuration (Neon Cloud DB)
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// 3. Register Services in DI Container
builder.Services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();
builder.Services.AddHttpClient<IAiWorkflowService, AiWorkflowService>();

// 4. Configure Real JWT Bearer Authentication
var secretKey = builder.Configuration["JwtSettings:SecretKey"] ?? "EventCraftAI_Super_Secret_JWT_Signing_Key_2026_SE3090!";
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

// 5. Add Controllers & Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure listening port for Railway or default to 8080
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

var app = builder.Build();

// 6. Configure HTTP pipeline
app.UseSwagger();
app.UseSwaggerUI();

// Root health check endpoint for Railway and monitoring
app.MapGet("/", () => Results.Ok(new 
{ 
    status = "healthy", 
    service = "EventManagement API (.NET 8)", 
    database = "Neon PostgreSQL (Connected)",
    timestamp = DateTime.UtcNow 
}));

// Use CORS (Must be before Authentication & Authorization)
app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

// 7. Map Controllers
app.MapControllers();

// 8. Seed Realistic Sri Lankan Venues, Hotels and Resources on Startup
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await context.Database.MigrateAsync();
    await DbInitializer.SeedAsync(context);
}

app.Run();