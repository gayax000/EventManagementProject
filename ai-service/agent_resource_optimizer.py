from typing import Optional, List
from schemas import EventObjectiveInput, ProposedItem
 
class ResourceOptimizerAgent:
    """
    Owned by Member 1: Resource & Budget Optimization Agent
    Matches hotel venues, catering buffet packages, and AV setups under the client's budget ceiling.
    """
    def __init__(self):
        self.role_name = "Resource Matching & Budget Optimization Agent"
 
    def query_inventory_tool(self, location: str) -> dict:
        loc = location.lower()
        if "nuwara" in loc:
            venue = "The Grand Hotel Nuwara Eliya - Governors Lawn"
        elif "kandy" in loc:
            venue = "Earl's Regency Kandy - Regent Ballroom"
        else:
            venue = "Shangri-La Colombo - Lotus Ballroom"
 
        return {
            "venueName": venue,
            "buffetPerHead": 5000.0,  # Premium Buffet B
            "soundRigPrice": 150000.0 # Concert Audio
        }
 
    def execute(self, objective: EventObjectiveInput, safeguard_item: Optional[ProposedItem]) -> dict:
        trace_log = [f"ResourceOptimizerAgent (Member 1): Matching packages for {objective.guestCount} guests in {objective.location}"]
        inv = self.query_inventory_tool(objective.location)
 
        items: List[ProposedItem] = []
 
        # 1. Catering Calculation
        catering_cost = inv["buffetPerHead"] * objective.guestCount
        items.append(ProposedItem(
            name=f"Premium Dinner Buffet B ({objective.guestCount} Guests x Rs. {inv['buffetPerHead']:,.0f})",
            category="Catering",
            cost=catering_cost
        ))
 
        # 2. Sound & Lighting Rig
        items.append(ProposedItem(
            name="Concert Stage, Audio & Intelligent Lighting Rig",
            category="AudioVisual",
            cost=inv["soundRigPrice"]
        ))
 
        # 3. Weather Safeguard if injected by Member 3's agent
        if safeguard_item:
            items.append(safeguard_item)
 
        subtotal = sum(i.cost for i in items)
        trace_log.append(f"ResourceOptimizerAgent (Member 1): Optimal package compiled. Subtotal: Rs. {subtotal:,.2f}")
 
        return {
            "agent": self.role_name,
            "selectedVenue": inv["venueName"],
            "items": items,
            "subtotal": subtotal,
            "trace": trace_log
        }