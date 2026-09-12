using System.Text.Json;
using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
namespace EventManagement.Api.Controllers;
[ApiController]
[Route("api/[controller]")]
public class AiWorkflowController : ControllerBase
{
    private readonly AppDbContext _context;
    public AiWorkflowController(AppDbContext context)
    {
        _context = context;
    }
    [HttpGet("resources")]
    public async Task<ActionResult<IEnumerable<Resource>>> GetResources()
    {
        return Ok(await _context.Resources.ToListAsync());
    }
    [HttpPost("resources")]
    public async Task<ActionResult<Resource>> CreateResource([FromBody] CreateResourceDto dto)
    {
        var resource = new Resource
        {
            ResourceName = dto.ResourceName,
            ResourceType = dto.ResourceType,
            UnitPrice = dto.UnitPrice,
            AvailableQuantity = dto.AvailableQuantity
        };
        _context.Resources.Add(resource);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetResources), new { id = resource.ResourceId }, resource);
    }
    [HttpPost("initiate")]
    public async Task<ActionResult<AiWorkflowResponseDto>> InitiateWorkflow([FromBody] InitiateAiWorkflowDto dto)
    {
        var ev = await _context.Events.FindAsync(dto.EventId);
        if (ev == null)
            return NotFound(new { message = "Event not found." });
        var weatherData = new { Forecast = "70% Chance of Rain", RiskLevel = "High", RecommendedSafeguard = "Waterproof Marquee Tent" };
        var planData = new
        {
            Steps = new[]
            {
                "Step 1: Check Venue capacity and outdoor flag",
                "Step 2: Weather Agent detects high rain risk -> Auto-appends Waterproof Marquee Tent (Rs. 150,000)",
                "Step 3: Budget Optimization Agent calculates Catering & AV package under budget limit",
                "Step 4: Validation Agent verifies constraint satisfaction and triggers Manager Approval hold"
            },
            EstimatedBudgetBreakdown = new { MarqueeTent = 150000, Catering = 500000, SoundLighting = 150000 }
        };
        var workflow = new AIWorkflowState
        {
            EventId = ev.EventId,
            ObjectiveText = $"Plan outdoor setup for {ev.Title} with budget {ev.BudgetLimit}",
            GeneratedPlanJson = JsonSerializer.Serialize(planData),
            WeatherAssessmentJson = JsonSerializer.Serialize(weatherData),
            EstimatedTotalCost = 800000,
            ApprovalStatus = "PendingManagerApproval"
        };
        _context.AIWorkflowStates.Add(workflow);
        await _context.SaveChangesAsync();
        return Ok(new AiWorkflowResponseDto
        {
            WorkflowId = workflow.WorkflowId,
            EventId = workflow.EventId,
            ApprovalStatus = workflow.ApprovalStatus,
            EstimatedTotalCost = workflow.EstimatedTotalCost,
            GeneratedPlanJson = workflow.GeneratedPlanJson,
            WeatherAssessmentJson = workflow.WeatherAssessmentJson
        });
    }
    [HttpPost("{id}/approve")]
    public async Task<ActionResult> ApproveWorkflow(Guid id, [FromBody] ApproveAiWorkflowDto dto)
    {
        var workflow = await _context.AIWorkflowStates.Include(w => w.Event).FirstOrDefaultAsync(w => w.WorkflowId == id);
        if (workflow == null)
            return NotFound(new { message = "Workflow not found." });
        workflow.ApprovalStatus = dto.Action == "Approve" ? "ApprovedByManager" : "RejectedByManager";
        workflow.ManagerRemarks = dto.ManagerRemarks;
        if (dto.SpecialDiscount > 0)
            workflow.EstimatedTotalCost -= dto.SpecialDiscount;
        if (workflow.Event != null)
            workflow.Event.Status = workflow.ApprovalStatus;
        await _context.SaveChangesAsync();
        return Ok(new { message = $"Workflow has been updated to {workflow.ApprovalStatus}.", finalCost = workflow.EstimatedTotalCost });
    }
}