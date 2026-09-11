using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.Entities;

public class AIWorkflowState : BaseEntity
{
    [Key]
    public Guid WorkflowId { get; set; } = Guid.NewGuid();
    
    public Guid EventId { get; set; }
    public Event? Event { get; set; }
    
    public string ObjectiveText { get; set; } = string.Empty;
    
    // Stored as JSON strings in C# and mapped to jsonb in PostgreSQL
    public string GeneratedPlanJson { get; set; } = "{}";
    public string ToolExecutionLogsJson { get; set; } = "[]";
    public string WeatherAssessmentJson { get; set; } = "{}";
    
    public decimal EstimatedTotalCost { get; set; }
    
    // PendingManagerApproval, Approved, Rejected, RevisionRequested
    public string ApprovalStatus { get; set; } = "PendingManagerApproval";
    
    public Guid? ApprovedByManagerId { get; set; }
    public User? ApprovedByManager { get; set; }
    public string? ManagerRemarks { get; set; }
}
