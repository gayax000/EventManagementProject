from typing import Optional, List, Dict, Any
from schemas import EventObjectiveInput, ProposedItem

class ResourceOptimizerAgent:
    """
    Owned by Member 1: Resource & Budget Optimization Agent
    Matches hotel venues, catering buffet packages, vendor category packages,
    and Table Refreshments matrix under the client's budget ceiling.
    """
    def __init__(self):
        self.role_name = "Resource Matching & Budget Optimization Agent"

    def query_inventory_tool(self, location: str, hall_name: Optional[str] = None, hall_price: Optional[float] = None) -> dict:
        loc = location.lower()
        if hall_name and hall_price and hall_price > 0:
            return {
                "venueName": hall_name,
                "hallRental": float(hall_price),
                "buffetPerHead": 5000.0,
                "isPrivate": False
            }

        if "private" in loc or "residence" in loc or "home" in loc:
            venue = f"Private Residence Grounds ({location})"
            buffet = 4500.0
            hall = 0.0
            is_private = True
        elif "nuwara" in loc:
            venue = "The Grand Hotel Nuwara Eliya - Governors Lawn"
            buffet = 5000.0
            hall = 450000.0
            is_private = False
        elif "kandy" in loc:
            venue = "Earl's Regency Kandy - Regent Ballroom"
            buffet = 5000.0
            hall = 550000.0
            is_private = False
        elif "galle" in loc:
            venue = "Jetwing Lighthouse Galle - Ocean Rocks Lawn"
            buffet = 5000.0
            hall = 620000.0
            is_private = False
        else:
            venue = "Shangri-La Colombo - Lotus Ballroom"
            buffet = 5000.0
            hall = 850000.0
            is_private = False

        return {
            "venueName": venue,
            "hallRental": hall,
            "buffetPerHead": buffet,
            "isPrivate": is_private
        }

    def execute(self, objective: EventObjectiveInput, safeguard_item: Optional[ProposedItem]) -> dict:
        trace_log = [f"ResourceOptimizerAgent (Member 1): Matching packages for {objective.guestCount} guests in {objective.location}"]
        inv = self.query_inventory_tool(objective.location, objective.banquetHallName, objective.hallRentalPrice)

        items: List[ProposedItem] = []
        budget = float(objective.budgetLimit)
        guests = max(1, objective.guestCount)
        services = [s.lower() for s in (objective.selectedServices or [])]
        refreshments = [r.lower() for r in (objective.tableRefreshments or [])]

        # 1. Venue Rental (Banquet Hall contracted vs Private Grounds)
        is_private = inv["isPrivate"] or ("private" in (objective.preferredLocation or "").lower())
        hall_rental = 0.0
        if not is_private:
            if objective.hallRentalPrice is not None and objective.hallRentalPrice > 0:
                hall_rental = float(objective.hallRentalPrice)
            else:
                hall_rental = float(inv.get("hallRental", 0.0))

        if hall_rental > 0 and not is_private:
            items.append(ProposedItem(
                name=f"{inv['venueName']} Rental",
                category="Venue",
                cost=hall_rental,
                partner=inv["venueName"]
            ))

        # 2. Catering Buffet Balancing (Fixed for Hotel, Dynamically Balanced for Private Venue)
        catering_style = objective.cateringStyle or "InternationalBuffet"
        style_labels = {
            "OutdoorBBQ": "Outdoor Live BBQ Grill Feast",
            "HighTeaCanape": "High Tea Canapé & Snack Platter",
            "SriLankanHeritage": "Sri Lankan Heritage Traditional Buffet",
            "InternationalBuffet": "International Hotel Buffet"
        }
        catering_label = style_labels.get(catering_style, "International Hotel Buffet")

        has_fixed_hotel_menu = (objective.perPlatePrice is not None and objective.perPlatePrice > 0) and not is_private

        if has_fixed_hotel_menu:
            # Hotel Banquet Hall contracted with client's selected per-plate menu
            per_plate = float(objective.perPlatePrice)
            catering_partner = f"{inv['venueName']} In-House Culinary Team"
            catering_name = f"{catering_label} ({guests} Guests x Rs. {per_plate:,.0f}/plate)"
        else:
            # Private Venue / Outdoor Grounds: AI balances catering vendor dynamically to fit client budget!
            available_for_catering = max(0.0, budget - hall_rental) * 0.55
            target_per_plate = max(1800.0, available_for_catering / guests)

            if target_per_plate >= 5000.0:
                per_plate = 5000.0
                catering_partner = "Grand Royal Gourmet Catering"
                catering_name = f"Executive 5-Star Gourmet Buffet ({guests} Guests x Rs. {per_plate:,.0f}/plate)"
            elif target_per_plate >= 3500.0:
                per_plate = 3500.0
                catering_partner = "Ceylon Feast Banquet Caterers"
                catering_name = f"Standard Deluxe Banquet Buffet ({guests} Guests x Rs. {per_plate:,.0f}/plate)"
            elif target_per_plate >= 2500.0:
                per_plate = 2500.0
                catering_partner = "Island Spice Community Caterers"
                catering_name = f"Traditional Sri Lankan Buffet ({guests} Guests x Rs. {per_plate:,.0f}/plate)"
            else:
                per_plate = 1800.0
                catering_partner = "SimpleEats Budget Catering"
                catering_name = f"Economy Express Buffet ({guests} Guests x Rs. {per_plate:,.0f}/plate)"

        catering_cost = per_plate * guests
        items.append(ProposedItem(
            name=catering_name,
            category="Catering",
            cost=catering_cost,
            partner=catering_partner
        ))

        # 3. Dynamic Per-Service Vendor Allowance Calculation
        safeguard_cost = float(safeguard_item.cost) if safeguard_item else 0.0
        remaining_budget = max(0.0, budget - hall_rental - catering_cost - safeguard_cost)

        needs_sound = any(k in s for s in services for k in ["sound", "lighting", "audio", "music"]) or (len(services) == 0)
        needs_decor = any(k in s for s in services for k in ["deco", "floral", "flower", "arch"])
        needs_photo = any(k in s for s in services for k in ["photo", "video", "media", "cinema"])
        needs_cake = any(k in s for s in services for k in ["cake", "dessert"])
        needs_transport = any(k in s for s in services for k in ["transport", "car", "bridal", "limo"])

        active_count = (1 if needs_sound else 0) + (1 if needs_decor else 0) + (1 if needs_photo else 0) + (1 if needs_cake else 0) + (1 if needs_transport else 0)
        allowance = (remaining_budget / active_count) if active_count > 0 else remaining_budget

        trace_log.append(
            f"ResourceOptimizerAgent (Member 1): Dynamic Vendor Balancing -> Remaining Budget: Rs. {remaining_budget:,.2f} | "
            f"Per-Service Allowance: Rs. {allowance:,.2f} across {active_count} requested service(s)"
        )

        # 4. Sound & Stage Lighting (Selected by Allowance)
        if needs_sound:
            if allowance >= 200000.0:
                s_name = "Concert Line-Array Rig + 16 Moving Heads + Beam Trusses"
                s_cost = 250000.0
                s_partner = "Pulse Audio & Intelligent Lighting"
            elif allowance >= 120000.0:
                s_name = "Concert Line-Array Sound & Digital Mixer Package"
                s_cost = 180000.0
                s_partner = "LiveSound Stage Rigs Colombo"
            elif allowance >= 60000.0:
                s_name = "Sensations Intelligent Audio & PAR Lighting"
                s_cost = 85000.0
                s_partner = "Sensations Audio Rigs"
            elif allowance >= 30000.0:
                s_name = "Compact Speech PA Kit + 2 Wireless Mics"
                s_cost = 40000.0
                s_partner = "QuickSound Compact Audio"
            else:
                s_name = "Economy Acoustic Speech & Bluetooth PA Kit"
                s_cost = 15000.0
                s_partner = "EchoLite Audio Solutions"

            items.append(ProposedItem(
                name=s_name,
                category="SoundLighting",
                cost=s_cost,
                partner=s_partner
            ))

        # 5. Floral Stage & Theme Decor (Selected by Allowance)
        if needs_decor:
            if allowance >= 180000.0:
                d_name = "Royal Fresh Flower Ceiling Drapes & Grand Stage Decor"
                d_cost = 220000.0
                d_partner = "Royal Florists Colombo"
            elif allowance >= 110000.0:
                d_name = "Thematic Floral Stage + Entrance Tunnel Arch Decor"
                d_cost = 140000.0
                d_partner = "Floral Elegance Sri Lanka"
            elif allowance >= 60000.0:
                d_name = "Thematic Floral Stage + Table Centerpieces"
                d_cost = 85000.0
                d_partner = "Bloom Art Deco"
            elif allowance >= 30000.0:
                d_name = "Minimalist Floral Arch + Cake Table Styling"
                d_cost = 45000.0
                d_partner = "SimplePetals Decor"
            else:
                d_name = "Traditional Oil Lamp, Minimal Poruwa & Head Table Deco"
                d_cost = 18000.0
                d_partner = "EcoFlora Minimalist Events"

            items.append(ProposedItem(
                name=d_name,
                category="Decor",
                cost=d_cost,
                partner=d_partner
            ))

        # 6. Professional Photography & Cinematography (Selected by Allowance)
        if needs_photo:
            if allowance >= 120000.0:
                p_name = "Cinematic 4K Media & Aerial Drone Coverage"
                p_cost = 150000.0
                p_partner = "Studio 360 Cinematics"
            elif allowance >= 65000.0:
                p_name = "Professional Event Photography & Leather Bound Album"
                p_cost = 85000.0
                p_partner = "Moments Photography"
            elif allowance >= 35000.0:
                p_name = "Compact Digital Event Photography Coverage"
                p_cost = 45000.0
                p_partner = "SnapStudio Colombo"
            else:
                p_name = "Basic 3-Hour Digital Photo Coverage"
                p_cost = 20000.0
                p_partner = "FocusLite Photography"

            items.append(ProposedItem(
                name=p_name,
                category="Photography",
                cost=p_cost,
                partner=p_partner
            ))

        # 7. Handcrafted Celebration Cakes (Selected by Allowance)
        if needs_cake:
            if allowance >= 55000.0:
                c_name = "5-Tier Royal Handcrafted Fondant Wedding Cake"
                c_cost = 65000.0
                c_partner = "The Cake Studio Colombo"
            elif allowance >= 35000.0:
                c_name = "3-Tier Luxury Floral Wedding Cake"
                c_cost = 45000.0
                c_partner = "SugarBloom Confectionery"
            elif allowance >= 18000.0:
                c_name = "2-Tier Handcrafted Fondant Thematic Cake"
                c_cost = 22000.0
                c_partner = "Artisanal Cakes"
            else:
                c_name = "Single Tier Celebration Cutting Cake"
                c_cost = 12000.0
                c_partner = "BakeHouse Colombo"

            items.append(ProposedItem(
                name=c_name,
                category="Cake",
                cost=c_cost,
                partner=c_partner
            ))

        # 8. VIP & Bridal Chauffeur Transport (Selected by Allowance)
        if needs_transport:
            if allowance >= 80000.0:
                t_name = "Classic Vintage Rolls Royce / 1954 Jaguar Mark VII"
                t_cost = 95000.0
                t_partner = "Vintage Royal Wedding Cars"
            elif allowance >= 50000.0:
                t_name = "Mercedes-Benz S-Class Luxury Chauffeur Sedan"
                t_cost = 65000.0
                t_partner = "Executive Chauffeur Lanka"
            elif allowance >= 22000.0:
                t_name = "Toyota Premio Executive Bridal Sedan"
                t_cost = 25000.0
                t_partner = "Prime Bridal Cabs"
            else:
                t_name = "Standard Air-Conditioned Sedan Service"
                t_cost = 15000.0
                t_partner = "CityRide Budget Transfers"

            items.append(ProposedItem(
                name=t_name,
                category="Transport",
                cost=t_cost,
                partner=t_partner
            ))

        # 9. Table Refreshments & Live Action Counters Matrix
        range_idx = 0 if guests <= 150 else (1 if guests <= 250 else 2)
        is_luxury = allowance >= 80000.0 or budget >= 2500000.0
        is_premium = allowance >= 40000.0 or budget >= 1200000.0

        for r in refreshments:
            if "mocktail" in r or "drink" in r:
                if is_luxury:
                    r_label = "Artisanal Exotic Fruit Fusion Bar & Signature Mocktails"
                    r_cost = [38000.0, 58000.0, 85000.0][range_idx]
                elif is_premium:
                    r_label = "Tropical Fresh Fruit Juices & Chilled Mocktails"
                    r_cost = [22000.0, 35000.0, 52000.0][range_idx]
                else:
                    r_label = "Chilled Mint Lime & Fruit Cordial Punch"
                    r_cost = [12000.0, 20000.0, 32000.0][range_idx]
                items.append(ProposedItem(name=r_label, category="Refreshment", cost=r_cost))

            elif "midnight" in r or "action" in r:
                if is_luxury:
                    r_label = "Live Action Midnight Street Food, Hopper & Satay Bar"
                    r_cost = [55000.0, 85000.0, 125000.0][range_idx]
                elif is_premium:
                    r_label = "Live Kottu & Mini Burger Midnight Station"
                    r_cost = [32000.0, 50000.0, 75000.0][range_idx]
                else:
                    r_label = "Midnight Hot Savory Snack Station"
                    r_cost = [20000.0, 30000.0, 45000.0][range_idx]
                items.append(ProposedItem(name=r_label, category="Refreshment", cost=r_cost))

            elif "snack" in r or "savory" in r or "refreshment" in r:
                if is_luxury:
                    r_label = "Gourmet Savory Canapés, Cheese Platters & Vol-au-Vents"
                    r_cost = [42000.0, 65000.0, 95000.0][range_idx]
                elif is_premium:
                    r_label = "Assorted Mini Pastries, Rolls & Samosa Platter"
                    r_cost = [25000.0, 40000.0, 60000.0][range_idx]
                else:
                    r_label = "Classic Tea-Time Biscuit & Mini Savory Selection"
                    r_cost = [15000.0, 25000.0, 38000.0][range_idx]
                items.append(ProposedItem(name=r_label, category="Refreshment", cost=r_cost))

            elif "dessert" in r or "sweet" in r:
                if is_luxury:
                    r_label = "Luxury Chocolate Fountain, French Pastries & Fruit Carving"
                    r_cost = [48000.0, 75000.0, 110000.0][range_idx]
                elif is_premium:
                    r_label = "Watalappan, Caramel Pudding & Deluxe Ice Cream Bar"
                    r_cost = [28000.0, 45000.0, 68000.0][range_idx]
                else:
                    r_label = "Caramel Pudding & Vanilla Ice Cream Station"
                    r_cost = [15000.0, 25000.0, 40000.0][range_idx]
                items.append(ProposedItem(name=r_label, category="Refreshment", cost=r_cost))

            elif "tea" in r or "coffee" in r:
                if is_luxury:
                    r_label = "Artisanal Ceylon Tea & Brewed Espresso Coffee Lounge"
                    r_cost = [25000.0, 38000.0, 55000.0][range_idx]
                elif is_premium:
                    r_label = "Premium Ceylon Milk Tea & Brewed Coffee Counter"
                    r_cost = [15000.0, 22000.0, 32000.0][range_idx]
                else:
                    r_label = "Traditional Ceylon Plain & Milk Tea Station"
                    r_cost = [8000.0, 12000.0, 18000.0][range_idx]
                items.append(ProposedItem(name=r_label, category="Refreshment", cost=r_cost))

        # 10. Environmental Marquee Tent Safeguard (if injected by Member 3's weather agent)
        if safeguard_item:
            items.append(safeguard_item)

        subtotal = sum(i.cost for i in items)
        trace_log.append(f"ResourceOptimizerAgent (Member 1): Optimal package compiled ({len(items)} items). Subtotal: Rs. {subtotal:,.2f}")

        return {
            "agent": self.role_name,
            "selectedVenue": inv["venueName"],
            "items": items,
            "subtotal": subtotal,
            "trace": trace_log
        }