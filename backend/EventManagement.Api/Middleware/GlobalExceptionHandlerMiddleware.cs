using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

namespace EventManagement.Api.Middleware;

public class GlobalExceptionHandlerMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionHandlerMiddleware> _logger;
    private readonly IHostEnvironment _environment;

    public GlobalExceptionHandlerMiddleware(
        RequestDelegate next, 
        ILogger<GlobalExceptionHandlerMiddleware> logger,
        IHostEnvironment environment)
    {
        _next = next;
        _logger = logger;
        _environment = environment;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled Exception occurred while processing request {Method} {Path}", context.Request.Method, context.Request.Path);
            await HandleExceptionAsync(context, ex);
        }
    }

    private Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/problem+json";
        
        var statusCode = exception switch
        {
            ArgumentException => (int)HttpStatusCode.BadRequest,
            KeyNotFoundException => (int)HttpStatusCode.NotFound,
            UnauthorizedAccessException => (int)HttpStatusCode.Unauthorized,
            InvalidOperationException => (int)HttpStatusCode.BadRequest,
            _ => (int)HttpStatusCode.InternalServerError
        };

        context.Response.StatusCode = statusCode;

        string title;
        string detail;

        if (statusCode == (int)HttpStatusCode.InternalServerError)
        {
            title = "Internal Server Error";
            detail = _environment.IsDevelopment()
                ? exception.Message
                : "An unexpected error occurred while processing the request.";
        }
        else
        {
            title = exception switch
            {
                ArgumentException => "Bad Request",
                KeyNotFoundException => "Not Found",
                UnauthorizedAccessException => "Unauthorized",
                InvalidOperationException => "Bad Request",
                _ => "Error"
            };
            detail = exception.Message;
        }

        var problemDetails = new ProblemDetails
        {
            Status = statusCode,
            Title = title,
            Detail = detail,
            Instance = context.Request.Path
        };

        var jsonOptions = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
        return context.Response.WriteAsync(JsonSerializer.Serialize(problemDetails, jsonOptions));
    }
}
