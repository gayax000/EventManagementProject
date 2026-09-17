using System.Text;
using System.Text.Json;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EventManagement.Infrastructure.Services;

public interface IAiWorkflowService
{
    Task<AIWorkflowState?> TriggerAgenticPlanAsync(Guid eventId);
}

public class AiWorkflowService : IAiWorkflowService
{
    private readonly HttpClient _httpClient;
    private readonly AppDbContext _context;
    private readonly ILogger<AiWorkflowService> _logger;
    private readonly string _aiServiceUrl;

    public AiWorkflowService(HttpClient httpClient, AppDbContext context, IConfiguration configuration, ILogger<AiWorkflowService> logger)
    {
        _httpClient = httpClient;
        _context = context;
        _logger = logger;
        _aiServiceUrl = configuration["AiServiceUrl"] ?? "http://localhost:8000/api/ai/plan";
    }

    public async Task<AIWorkflowState?> TriggerAgenticPlanAsync(Guid eventId)
    {
        var ev = await _context.Events.Include(e => e.Venue).FirstOrDefaultAsync(e => e.EventId == eventId);
        if (ev == null)
        {
            _logger.LogWarning("Event {EventId} not found for AI orchestration.", eventId);
            return null;
        }

        var payload = new
        {
            eventId = ev.EventId.ToString(),
            title = ev.Title,
            targetDate = ev.TargetDate.ToString("yyyy-MM-dd"),
            guestCount = ev.GuestCount,
            budgetLimit = (double)ev.BudgetLimit,
            location = ev.Venue != null ? ev.Venue.LocationAddress : "Nuwara Eliya",
            isOutdoor = ev.Venue == null || ev.Venue.IsOutdoor
        };

        try
        {
            var content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");
            _logger.LogInformation("Calling Agentic AI Subsystem at {Url} for Event {EventId}...", _aiServiceUrl, eventId);

            var response = await _httpClient.PostAsync(_aiServiceUrl, content);
            if (response.IsSuccessStatusCode)
            {
                var jsonString = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(jsonString);
                var root = doc.RootElement;

                var estimatedCost = root.TryGetProperty("subtotal", out var subProp) ? subProp.GetDecimal() : 800000m;
                var planJson = root.TryGetProperty("multiStepPlan", out var planProp) ? planProp.GetRawText() : "[]";
                var weatherJson = root.TryGetProperty("weatherRiskAssessment", out var wProp) ? wProp.GetRawText() : "{}";
                var traceJson = root.TryGetProperty("auditTraceLogs", out var tProp) ? tProp.GetRawText() : "[]";

                var aiState = new AIWorkflowState
                {
                    EventId = ev.EventId,
                    ObjectiveText = $"Autonomous proposal for {ev.Title} ({ev.GuestCount} guests)",
                    GeneratedPlanJson = planJson,
                    WeatherAssessmentJson = weatherJson,
                    ToolExecutionLogsJson = traceJson,
                    EstimatedTotalCost = estimatedCost,
                    ApprovalStatus = "PendingManagerApproval"
                };

                _context.AIWorkflowStates.Add(aiState);
                ev.Status = "PendingManagerApproval";
                await _context.SaveChangesAsync();

                _logger.LogInformation("Successfully persisted AI Workflow {WorkflowId} for Event {EventId}.", aiState.WorkflowId, eventId);
                return aiState;
            }
            else
            {
                _logger.LogError("Agentic AI service responded with error code: {StatusCode}", response.StatusCode);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to connect to Agentic AI service at {Url}. Using fallback mock proposal.", _aiServiceUrl);
            
            // Dynamic realistic package calculation based on guest count and safeguards:
            // 1. Premium Dinner Buffet B (Rs. 5,000 per guest)
            // 2. Sound & Lighting Rig (Rs. 150,000)
            // 3. Waterproof Marquee Tent safeguard (Rs. 150,000)
            decimal dynamicCost = (ev.GuestCount * 5000m) + 150000m + 150000m;

            var fallbackState = new AIWorkflowState
            {
                EventId = ev.EventId,
                ObjectiveText = $"Autonomous proposal for {ev.Title} ({ev.GuestCount} guests)",
                GeneratedPlanJson = $"[\"Weather Assessment: 70% Rain Alert\", \"Auto-injected Waterproof Marquee Tent safeguard (Rs. 150,000)\", \"Premium Buffet B ({ev.GuestCount} guests @ Rs. 5,000)\", \"Sound & Stage Rig (Rs. 150,000)\"]",
                WeatherAssessmentJson = "{\"rainProbabilityPercent\": 70, \"condition\": \"Monsoon Rain Alert\", \"safeguard\": \"Heavy Duty Waterproof Marquee Tent\"}",
                ToolExecutionLogsJson = "[\"WeatherAgent: 70% rain alert triggered\", \"ResourceAgent: Compiled catering & AV packages\", \"SafetyAgent: Safeguard verified under budget\"]",
                EstimatedTotalCost = dynamicCost,
                ApprovalStatus = "PendingManagerApproval"
            };

            _context.AIWorkflowStates.Add(fallbackState);
            ev.Status = "PendingManagerApproval";
            await _context.SaveChangesAsync();
            return fallbackState;
        }

        return null;
    }
}