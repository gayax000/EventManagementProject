from typing import Optional, List, Dict, Any
from schemas import EventObjectiveInput, ProposedItem

PRIVATE_CATERING_TIERS = [
    {"per_plate": 5000.0, "partner": "Grand Royal Gourmet Catering", "prefix": "Executive 5-Star Gourmet Buffet"},
    {"per_plate": 3500.0, "partner": "Ceylon Feast Banquet Caterers", "prefix": "Standard Deluxe Banquet Buffet"},
    {"per_plate": 2500.0, "partner": "Island Spice Community Caterers", "prefix": "Traditional Sri Lankan Buffet"},
    {"per_plate": 1800.0, "partner": "SimpleEats Budget Catering", "prefix": "Economy Express Buffet"},
]

class ResourceOptimizerAgent:
    """
    Owned by Member 1: Resource & Budget Optimization Agent
    Matches hotel venues, catering buffet packages, vendor category packages,
    and Table Refreshments matrix under the client's budget ceiling.
    """
    def __init__(self):
        self.role_name = "Resource Matching & Budget Optimization Agent"

    def query_inventory_tool(self, location: str, hall_name: Optional[str] = None, hall_price: Optional[float] = None, budget: float = 0.0) -> dict:
        loc = (location or "").lower()
        if hall_name:
            rental = float(hall_price) if (hall_price is not None and hall_price > 0) else 0.0
            is_priv = "private" in hall_name.lower() or "residence" in hall_name.lower() or "home" in hall_name.lower() or "garden" in hall_name.lower()
            return {
                "venueName": hall_name,
                "hallRental": rental,
                "buffetPerHead": 5000.0,
                "isPrivate": is_priv
            }

        if "private" in loc or "residence" in loc or "home" in loc:
            venue = f"Private Residence Grounds ({location})"
            buffet = 4500.0
            hall = 0.0
            is_private = True
        elif "nuwara" in loc:
            venue = "The Grand Hotel Nuwara Eliya - Governors Lawn" if budget >= 1500000.0 else "Highland Mist Banquet Hall Nuwara Eliya"
            buffet = 5000.0
            hall = 350000.0 if budget >= 1500000.0 else 180000.0
            is_private = False
        elif "kandy" in loc:
            venue = "Earl's Regency Kandy - Regent Ballroom" if budget >= 1500000.0 else "Kandy City Banquet Hall"
            buffet = 5000.0
            hall = 320000.0 if budget >= 1500000.0 else 160000.0
            is_private = False
        elif "galle" in loc:
            venue = "Jetwing Lighthouse Galle - Ocean Rocks Lawn" if budget >= 1500000.0 else "Galle Heritage Banquet Pavilion"
            buffet = 5000.0
            hall = 350000.0 if budget >= 1500000.0 else 160000.0
            is_private = False
        else:
            if budget >= 2500000.0:
                venue = "Shangri-La Colombo - Lotus Ballroom"
                hall = 450000.0
            elif budget >= 1200000.0:
                venue = "Cinnamon Grand - Cedar Banquet Suite"
                hall = 250000.0
            else:
                venue = "Sapphire Banquet Hall Colombo"
                hall = 150000.0
            buffet = 5000.0
            is_private = False

        return {
            "venueName": venue,
            "hallRental": hall,
            "buffetPerHead": buffet,
            "isPrivate": is_private
        }

    def execute(self, objective: EventObjectiveInput, safeguard_item: Optional[ProposedItem]) -> dict:
        trace_log = [f"ResourceOptimizerAgent (Member 1): Matching packages for {objective.guestCount} guests in {objective.location}"]
        inv = self.query_inventory_tool(objective.location, objective.banquetHallName, objective.hallRentalPrice, float(objective.budgetLimit))

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

            c_matched = next((c for c in PRIVATE_CATERING_TIERS if c["per_plate"] <= target_per_plate), PRIVATE_CATERING_TIERS[-1])
            per_plate = c_matched["per_plate"]
            catering_partner = c_matched["partner"]
            catering_name = f"{c_matched['prefix']} ({guests} Guests x Rs. {per_plate:,.0f}/plate)"

        catering_cost = per_plate * guests
        items.append(ProposedItem(
            name=catering_name,
            category="Catering",
            cost=catering_cost,
            partner=catering_partner
        ))

        # 3. Catalog Definition for Dynamic Vendor Allocation
        CATALOG = {
            "SoundLighting": [
                {"cost": 250000.0, "name": "Concert Line-Array Rig + 16 Moving Heads + Beam Trusses", "partner": "Pulse Audio & Intelligent Lighting"},
                {"cost": 180000.0, "name": "Concert Line-Array Sound & Digital Mixer Package", "partner": "LiveSound Stage Rigs Colombo"},
                {"cost": 85000.0, "name": "Sensations Intelligent Audio & PAR Lighting", "partner": "Sensations Audio Rigs"},
                {"cost": 40000.0, "name": "Compact Speech PA Kit + 2 Wireless Mics", "partner": "QuickSound Compact Audio"},
                {"cost": 15000.0, "name": "Economy Acoustic Speech & Bluetooth PA Kit", "partner": "EchoLite Audio Solutions"}
            ],
            "Decor": [
                {"cost": 220000.0, "name": "Royal Fresh Flower Ceiling Drapes & Grand Stage Decor", "partner": "Royal Florists Colombo"},
                {"cost": 140000.0, "name": "Thematic Floral Stage + Entrance Tunnel Arch Decor", "partner": "Floral Elegance Sri Lanka"},
                {"cost": 85000.0, "name": "Thematic Floral Stage + Table Centerpieces", "partner": "Bloom Art Deco"},
                {"cost": 45000.0, "name": "Minimalist Floral Arch + Cake Table Styling", "partner": "SimplePetals Decor"},
                {"cost": 18000.0, "name": "Traditional Oil Lamp, Minimal Poruwa & Head Table Deco", "partner": "EcoFlora Minimalist Events"}
            ],
            "Photography": [
                {"cost": 150000.0, "name": "Cinematic 4K Media & Aerial Drone Coverage", "partner": "Studio 360 Cinematics"},
                {"cost": 85000.0, "name": "Professional Event Photography & Leather Bound Album", "partner": "Moments Photography"},
                {"cost": 45000.0, "name": "Compact Digital Event Photography Coverage", "partner": "SnapStudio Colombo"},
                {"cost": 20000.0, "name": "Basic 3-Hour Digital Photo Coverage", "partner": "FocusLite Photography"}
            ],
            "Cake": [
                {"cost": 65000.0, "name": "5-Tier Royal Handcrafted Fondant Wedding Cake", "partner": "The Cake Studio Colombo"},
                {"cost": 45000.0, "name": "3-Tier Luxury Floral Wedding Cake", "partner": "SugarBloom Confectionery"},
                {"cost": 22000.0, "name": "2-Tier Handcrafted Fondant Thematic Cake", "partner": "Artisanal Cakes"},
                {"cost": 12000.0, "name": "Single Tier Celebration Cutting Cake", "partner": "BakeHouse Colombo"}
            ],
            "Transport": [
                {"cost": 95000.0, "name": "Classic Vintage Rolls Royce / 1954 Jaguar Mark VII", "partner": "Vintage Royal Wedding Cars"},
                {"cost": 65000.0, "name": "Mercedes-Benz S-Class Luxury Chauffeur Sedan", "partner": "Executive Chauffeur Lanka"},
                {"cost": 25000.0, "name": "Toyota Premio Executive Bridal Sedan", "partner": "Prime Bridal Cabs"},
                {"cost": 15000.0, "name": "Standard Air-Conditioned Sedan Service", "partner": "CityRide Budget Transfers"}
            ]
        }

        range_idx = 0 if guests <= 150 else (1 if guests <= 250 else 2)
        REFRESHMENT_CATALOG = {
            "mocktail": [
                {"cost": [38000.0, 58000.0, 85000.0][range_idx], "name": "Artisanal Exotic Fruit Fusion Bar & Signature Mocktails"},
                {"cost": [22000.0, 35000.0, 52000.0][range_idx], "name": "Tropical Fresh Fruit Juices & Chilled Mocktails"},
                {"cost": [12000.0, 20000.0, 32000.0][range_idx], "name": "Chilled Mint Lime & Fruit Cordial Punch"}
            ],
            "midnight": [
                {"cost": [55000.0, 85000.0, 125000.0][range_idx], "name": "Live Action Midnight Street Food, Hopper & Satay Bar"},
                {"cost": [32000.0, 50000.0, 75000.0][range_idx], "name": "Live Kottu & Mini Burger Midnight Station"},
                {"cost": [20000.0, 30000.0, 45000.0][range_idx], "name": "Midnight Hot Savory Snack Station"}
            ],
            "snack": [
                {"cost": [42000.0, 65000.0, 95000.0][range_idx], "name": "Gourmet Savory Canapés, Cheese Platters & Vol-au-Vents"},
                {"cost": [25000.0, 40000.0, 60000.0][range_idx], "name": "Assorted Mini Pastries, Rolls & Samosa Platter"},
                {"cost": [15000.0, 25000.0, 38000.0][range_idx], "name": "Classic Tea-Time Biscuit & Mini Savory Selection"}
            ],
            "dessert": [
                {"cost": [48000.0, 75000.0, 110000.0][range_idx], "name": "Luxury Chocolate Fountain, French Pastries & Fruit Carving"},
                {"cost": [28000.0, 45000.0, 68000.0][range_idx], "name": "Watalappan, Caramel Pudding & Deluxe Ice Cream Bar"},
                {"cost": [15000.0, 25000.0, 40000.0][range_idx], "name": "Caramel Pudding & Vanilla Ice Cream Station"}
            ],
            "tea": [
                {"cost": [25000.0, 38000.0, 55000.0][range_idx], "name": "Artisanal Ceylon Tea & Brewed Espresso Coffee Lounge"},
                {"cost": [15000.0, 22000.0, 32000.0][range_idx], "name": "Premium Ceylon Milk Tea & Brewed Coffee Counter"},
                {"cost": [8000.0, 12000.0, 18000.0][range_idx], "name": "Traditional Ceylon Plain & Milk Tea Station"}
            ]
        }

        # 4. Dynamic Budget Pool & Allowance Apportionment
        safeguard_cost = float(safeguard_item.cost) if safeguard_item else 0.0
        net_vendor_pool = max(0.0, budget - hall_rental - catering_cost - safeguard_cost)

        needs_sound = any(k in s for s in services for k in ["sound", "lighting", "audio", "music"]) or (len(services) == 0)
        needs_decor = any(k in s for s in services for k in ["deco", "floral", "flower", "arch"])
        needs_photo = any(k in s for s in services for k in ["photo", "video", "media", "cinema"])
        needs_cake = any(k in s for s in services for k in ["cake", "dessert"])
        needs_transport = any(k in s for s in services for k in ["transport", "car", "bridal", "limo"])

        active_services = []
        if needs_sound: active_services.append("SoundLighting")
        if needs_decor: active_services.append("Decor")
        if needs_photo: active_services.append("Photography")
        if needs_cake: active_services.append("Cake")
        if needs_transport: active_services.append("Transport")

        # Refreshments count weight
        matched_refreshment_keys = []
        for r in refreshments:
            if "mocktail" in r or "drink" in r: matched_refreshment_keys.append("mocktail")
            elif "midnight" in r or "action" in r: matched_refreshment_keys.append("midnight")
            elif "snack" in r or "savory" in r or "refreshment" in r: matched_refreshment_keys.append("snack")
            elif "dessert" in r or "sweet" in r: matched_refreshment_keys.append("dessert")
            elif "tea" in r or "coffee" in r: matched_refreshment_keys.append("tea")

        total_units = len(active_services) + (len(matched_refreshment_keys) * 0.45)
        service_allowance = (net_vendor_pool / total_units) if total_units > 0 else net_vendor_pool
        refreshment_allowance = service_allowance * 0.45

        trace_log.append(
            f"ResourceOptimizerAgent (Member 1): Net Vendor Pool: Rs. {net_vendor_pool:,.2f} | "
            f"Service Allowance: Rs. {service_allowance:,.2f} across {len(active_services)} service(s) "
            f"and {len(matched_refreshment_keys)} refreshment(s)"
        )

        # 5. Tentative Allocation: Pick highest package <= allowance
        for cat in active_services:
            tiers = CATALOG[cat]
            # Find best tier within allowance
            affordable = [t for t in tiers if t["cost"] <= service_allowance]
            chosen = affordable[0] if affordable else tiers[-1]  # Highest affordable, or minimum tier
            items.append(ProposedItem(
                name=chosen["name"],
                category=cat,
                cost=chosen["cost"],
                partner=chosen["partner"]
            ))

        # 6. Tentative Refreshments Allocation
        for r_key in matched_refreshment_keys:
            r_tiers = REFRESHMENT_CATALOG[r_key]
            r_affordable = [t for t in r_tiers if t["cost"] <= refreshment_allowance]
            r_chosen = r_affordable[0] if r_affordable else r_tiers[-1]
            items.append(ProposedItem(
                name=r_chosen["name"],
                category="Refreshment",
                cost=r_chosen["cost"]
            ))

        # 7. Add Safeguard Marquee Tent (if outdoor rain detected)
        if safeguard_item:
            items.append(safeguard_item)

        # 8. Active Knapsack Step-Down Optimization Balancing Loop
        # Guarantees Subtotal <= Budget Ceiling whenever mathematically feasible!
        def calc_total():
            return sum(i.cost for i in items)

        loop_iterations = 0
        while calc_total() > budget and loop_iterations < 25:
            loop_iterations += 1
            stepped_down = False

            # Identify candidates for downgrade (variable vendor packages, refreshments, or private catering)
            downgrade_candidates = [
                (idx, it) for idx, it in enumerate(items)
                if it.category in CATALOG or it.category == "Refreshment" or (it.category == "Catering" and not has_fixed_hotel_menu)
            ]
            if not downgrade_candidates:
                break

            # Sort descending by cost so we trim the largest variable expense first
            downgrade_candidates.sort(key=lambda x: x[1].cost, reverse=True)

            for idx, it in downgrade_candidates:
                if it.category in CATALOG:
                    tiers = CATALOG[it.category]
                    curr_tier_idx = next((i for i, t in enumerate(tiers) if t["name"] == it.name), -1)
                    if curr_tier_idx != -1 and curr_tier_idx < len(tiers) - 1:
                        next_tier = tiers[curr_tier_idx + 1]
                        items[idx] = ProposedItem(
                            name=next_tier["name"],
                            category=it.category,
                            cost=next_tier["cost"],
                            partner=next_tier["partner"]
                        )
                        stepped_down = True
                        break
                elif it.category == "Refreshment":
                    for r_k, r_tiers in REFRESHMENT_CATALOG.items():
                        curr_r_idx = next((i for i, t in enumerate(r_tiers) if t["name"] == it.name), -1)
                        if curr_r_idx != -1 and curr_r_idx < len(r_tiers) - 1:
                            next_r = r_tiers[curr_r_idx + 1]
                            items[idx] = ProposedItem(
                                name=next_r["name"],
                                category="Refreshment",
                                cost=next_r["cost"]
                            )
                            stepped_down = True
                            break
                    if stepped_down:
                        break
                elif it.category == "Catering" and not has_fixed_hotel_menu:
                    for c_idx, c_tier in enumerate(PRIVATE_CATERING_TIERS):
                        if c_tier["partner"] == it.partner and c_idx < len(PRIVATE_CATERING_TIERS) - 1:
                            next_c = PRIVATE_CATERING_TIERS[c_idx + 1]
                            new_cost = next_c["per_plate"] * guests
                            items[idx] = ProposedItem(
                                name=f"{next_c['prefix']} ({guests} Guests x Rs. {next_c['per_plate']:,.0f}/plate)",
                                category="Catering",
                                cost=new_cost,
                                partner=next_c["partner"]
                            )
                            stepped_down = True
                            break
                    if stepped_down:
                        break

            if not stepped_down:
                # All variable items already at minimum possible cost tier
                break

        subtotal = sum(i.cost for i in items)
        if subtotal <= budget:
            trace_log.append(f"ResourceOptimizerAgent (Member 1): Optimal package balanced and compiled ({len(items)} items). Subtotal: Rs. {subtotal:,.2f} <= Budget Ceiling: Rs. {budget:,.2f}")
        else:
            trace_log.append(f"ResourceOptimizerAgent (Member 1): All vendor items trimmed to minimum tiers ({len(items)} items). Subtotal: Rs. {subtotal:,.2f} (Ceiling: Rs. {budget:,.2f})")

        return {
            "agent": self.role_name,
            "selectedVenue": inv["venueName"],
            "items": items,
            "subtotal": subtotal,
            "trace": trace_log
        }