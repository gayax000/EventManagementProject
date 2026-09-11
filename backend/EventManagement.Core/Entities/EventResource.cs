using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.Entities;

public class EventResource
{
    [Key]
    public Guid EventResourceId { get; set; } = Guid.NewGuid();

    public Guid EventId { get; set; }
    public Event? Event { get; set; }

    public Guid ResourceId { get; set; }
    public Resource? Resource { get; set; }

    public int Quantity { get; set; }
    public decimal CalculatedCost { get; set; }
    public string AllocationStatus { get; set; } = "ProposedByAI"; // ProposedByAI, Reserved, Released
}