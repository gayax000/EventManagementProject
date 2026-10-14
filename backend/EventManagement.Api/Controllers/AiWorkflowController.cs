using System.Text.Json;
using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using EventManagement.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace EventManagement.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class AiWorkflowController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IAiWorkflowService _aiWorkflowService;
    private readonly ILogger<AiWorkflowController> _logger;
    private readonly IMemoryCache _cache;

    public AiWorkflowController(AppDbContext context, IAiWorkflowService aiWorkflowService, ILogger<AiWorkflowController> logger, IMemoryCache cache)
    {
        _context = context;
        _aiWorkflowService = aiWorkflowService;
        _logger = logger;
        _cache = cache;
    }

    [HttpGet("resources")]
    public async Task<ActionResult<IEnumerable<Resource>>> GetResources()
    {
        // Cache resources for 10 minutes — resource list rarely changes
        if (_cache.TryGetValue("resources_all", out List<Resource>? cached) && cached != null)
            return Ok(cached);

        var resources = await _context.Resources.AsNoTracking().ToListAsync();
        _cache.Set("resources_all", resources, TimeSpan.FromMinutes(10));
        return Ok(resources);
    }

    [Authorize(Roles = "Manager,Admin")]
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
        _cache.Remove("resources_all");
        return CreatedAtAction(nameof(GetResources), new { id = resource.ResourceId }, resource);
    }

    [HttpPost("initiate")]
    public async Task<ActionResult<AiWorkflowResponseDto>> InitiateWorkflow([FromBody] InitiateAiWorkflowDto dto)
    {
        var ev = await _context.Events.FindAsync(dto.EventId);
        if (ev == null)
            return NotFound(new { message = "Event not found." });

        var workflow = await _aiWorkflowService.TriggerAgenticPlanAsync(dto.EventId);
        if (workflow == null)
            return StatusCode(500, new { message = "Failed to orchestrate AI workflow." });

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

    [Authorize(Roles = "Manager,Admin")]
    [HttpPost("{id}/approve")]
    public async Task<ActionResult> ApproveWorkflow(Guid id, [FromBody] ApproveAiWorkflowDto dto)
    {
        var workflow = await _context.AIWorkflowStates.Include(w => w.Event).FirstOrDefaultAsync(w => w.WorkflowId == id);
        if (workflow == null)
            return NotFound(new { message = "Workflow not found." });

        var claimUserIdStr = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value ?? User.FindFirst("sub")?.Value;
        
        string newStatus = dto.Action switch
        {
            "Approve" => "ApprovedByManager",
            "Reject" => "RejectedByManager",
            "Revise" => "RevisionRequested",
            _ => dto.Action ?? "ApprovedByManager"
        };

        workflow.ApprovalStatus = newStatus;
        workflow.ManagerRemarks = dto.ManagerRemarks;
        if (dto.SpecialDiscount > 0)
            workflow.EstimatedTotalCost -= dto.SpecialDiscount;

        if (workflow.Event != null)
        {
            workflow.Event.Status = workflow.ApprovalStatus;
            
            // Generate real-time Notification for the Customer
            try
            {
                _context.Notifications.Add(new Notification
                {
                    UserId = workflow.Event.CustomerId,
                    EventId = workflow.EventId,
                    Title = newStatus == "ApprovedByManager" ? "✅ Proposal Approved" : "⚠️ Proposal Status Updated",
                    Message = $"Your event proposal for \"{workflow.Event.Title}\" status updated to {newStatus}. Remarks: {dto.ManagerRemarks ?? "Processed by Manager"}",
                    Type = "WorkflowStatusChanged",
                    CreatedAt = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to create workflow status notification for event {EventId}", workflow.EventId);
            }
        }

        await _context.SaveChangesAsync();
        return Ok(new
        {
            message = $"Workflow has been updated to {workflow.ApprovalStatus}.",
            status = workflow.ApprovalStatus,
            managerRemarks = workflow.ManagerRemarks,
            finalCost = workflow.EstimatedTotalCost,
            approverId = claimUserIdStr
        });
    }
}