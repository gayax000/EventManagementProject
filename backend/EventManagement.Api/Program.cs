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

var app = builder.Build();

// 5. Configure HTTP pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Use CORS (Must be before Authorization & MapControllers)
app.UseCors("AllowAll");

app.UseAuthorization();

// 6. Map Controllers
app.MapControllers();

// 7. Seed Realistic Sri Lankan Venues, Hotels and Resources on Startup
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await DbInitializer.SeedAsync(context);
}

app.Run();