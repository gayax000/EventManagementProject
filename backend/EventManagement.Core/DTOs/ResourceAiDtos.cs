using System.ComponentModel.DataAnnotations;
namespace EventManagement.Core.DTOs;
public class CreateResourceDto
{
    [Required, MaxLength(150)]
    public string ResourceName { get; set; } = string.Empty;
    [Required]
    public string ResourceType { get; set; } = string.Empty;
    [Range(100, 10000000)]
    public decimal UnitPrice { get; set; }
    [Range(1, 10000)]
    public int AvailableQuantity { get; set; }
}
public class InitiateAiWorkflowDto
{
    [Required]
    public Guid EventId { get; set; }
}
public class ApproveAiWorkflowDto
{
    [Required]
    public string Action { get; set; } = "Approve";
    public decimal SpecialDiscount { get; set; } = 0;
    public string? ManagerRemarks { get; set; }
}
public class AiWorkflowResponseDto
{
    public Guid WorkflowId { get; set; }
    public Guid EventId { get; set; }
    public string ApprovalStatus { get; set; } = string.Empty;
    public decimal EstimatedTotalCost { get; set; }
    public string GeneratedPlanJson { get; set; } = string.Empty;
    public string WeatherAssessmentJson { get; set; } = string.Empty;
}