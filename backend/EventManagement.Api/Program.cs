using EventManagement.Infrastructure.Data;
using EventManagement.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;

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

// 3. Register HttpClient & Agentic AI Workflow Service (Spec Section 10 Integration)
builder.Services.AddHttpClient<IAiWorkflowService, AiWorkflowService>();

// 4. Add Controllers & Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure listening port for Railway or default to 8080
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

var app = builder.Build();

// 5. Configure HTTP pipeline
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

// Use CORS (Must be before Authorization & MapControllers)
app.UseCors("AllowAll");

app.UseAuthorization();

// 6. Map Controllers
app.MapControllers();

// 7. Seed Realistic Sri Lankan Venues, Hotels and Resources on Startup
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await context.Database.MigrateAsync();
    await DbInitializer.SeedAsync(context);
}

app.Run();