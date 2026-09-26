using EventManagement.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Infrastructure.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(AppDbContext context)
    {
        // Ensure new schema columns exist in PostgreSQL database
        try
        {
            await context.Database.ExecuteSqlRawAsync(@"
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""EventSession"" text DEFAULT 'DayLunch';
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""CateringStyle"" text DEFAULT 'InternationalBuffet';
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""TableRefreshmentsJson"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""PreferredLocation"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""RevisionNotes"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""SelectedServicesJson"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""InspirationImageUrl"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""AdditionalDetails"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""IsOutdoor"" boolean DEFAULT false;
                ALTER TABLE ""Vendors"" ADD COLUMN IF NOT EXISTS ""PackageName"" text;
                ALTER TABLE ""Vendors"" ADD COLUMN IF NOT EXISTS ""PackagePrice"" numeric;
            ");
        }
        catch { }

        // 1. Roles Seed
        if (!await context.Roles.AnyAsync())
        {
            context.Roles.AddRange(
                new Role { RoleId = 1, RoleName = "Admin" },
                new Role { RoleId = 2, RoleName = "Manager" },
                new Role { RoleId = 3, RoleName = "Customer" },
                new Role { RoleId = 4, RoleName = "Vendor" }
            );
            await context.SaveChangesAsync();
        }

        // 2. Default System Manager / Customer
        if (!await context.Users.AnyAsync())
        {
            var managerRole = await context.Roles.FirstAsync(r => r.RoleName == "Manager");
            var customerRole = await context.Roles.FirstAsync(r => r.RoleName == "Customer");

            context.Users.AddRange(
                new User
                {
                    UserId = Guid.Parse("11111111-1111-1111-1111-111111111111"),
                    FullName = "Kasun Bandara (Operations Manager)",
                    Email = "manager@eventcraft.lk",
                    PasswordHash = "Manager@2026",
                    PhoneNumber = "+94771234567",
                    RoleId = managerRole.RoleId,
                    AccountStatus = "Active"
                },
                new User
                {
                    UserId = Guid.Parse("22222222-2222-2222-2222-222222222222"),
                    FullName = "Sahan Perera (Client)",
                    Email = "sahan@gmail.com",
                    PasswordHash = "Customer@2026",
                    PhoneNumber = "+94719876543",
                    RoleId = customerRole.RoleId,
                    AccountStatus = "Active"
                }
            );
            await context.SaveChangesAsync();
        }

        // 3. Realistic Sri Lankan Venues & Hotels Seeding
        if (!await context.Venues.AnyAsync())
        {
            var manager = await context.Users.FirstAsync(u => u.Email == "manager@eventcraft.lk");

            var venues = new List<Venue>
            {
                // Colombo & Western Province
                new() { Name = "Shangri-La Colombo", LocationAddress = "1 Galle Face, Colombo 02", MaxCapacity = 1200, BaseRentalPrice = 850000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Grand Colombo", LocationAddress = "77 Galle Road, Colombo 03", MaxCapacity = 600, BaseRentalPrice = 650000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Galle Face Hotel", LocationAddress = "2 Galle Road, Colombo 03", MaxCapacity = 500, BaseRentalPrice = 750000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Lakeside", LocationAddress = "115 Sir Chittampalam A Gardiner Mawatha, Colombo 02", MaxCapacity = 450, BaseRentalPrice = 550000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Hilton Colombo", LocationAddress = "2 Sir Chittampalam A Gardiner Mawatha, Colombo 02", MaxCapacity = 700, BaseRentalPrice = 700000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "The Kingsbury Colombo", LocationAddress = "48 Janadhipathi Mawatha, Colombo 01", MaxCapacity = 400, BaseRentalPrice = 500000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Water's Edge Battaramulla", LocationAddress = "316 Pannipitiya Road, Battaramulla", MaxCapacity = 1000, BaseRentalPrice = 600000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Mount Lavinia Hotel", LocationAddress = "100 Hotel Road, Mount Lavinia", MaxCapacity = 600, BaseRentalPrice = 580000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Mövenpick Hotel Colombo", LocationAddress = "24 Dharmapala Mawatha, Colombo 03", MaxCapacity = 200, BaseRentalPrice = 400000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Marino Beach Colombo", LocationAddress = "590 Marine Drive, Colombo 03", MaxCapacity = 350, BaseRentalPrice = 450000, IsOutdoor = false, ManagerId = manager.UserId },

                // Nuwara Eliya & Central Highlands (Cold & Rain Risk Locations)
                new() { Name = "The Grand Hotel Nuwara Eliya", LocationAddress = "Grand Hotel Road, Nuwara Eliya", MaxCapacity = 350, BaseRentalPrice = 450000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Heritance Tea Factory", LocationAddress = "Kandapola, Nuwara Eliya", MaxCapacity = 200, BaseRentalPrice = 380000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Araliya Green City", LocationAddress = "Nuwara Eliya Town Center", MaxCapacity = 400, BaseRentalPrice = 420000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Jetwing St. Andrew's", LocationAddress = "St. Andrew's Drive, Nuwara Eliya", MaxCapacity = 180, BaseRentalPrice = 320000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Nuwara Eliya Golf Club", LocationAddress = "Park Road, Nuwara Eliya", MaxCapacity = 300, BaseRentalPrice = 350000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Langdale Boutique Hotel", LocationAddress = "Radella, Nuwara Eliya", MaxCapacity = 150, BaseRentalPrice = 280000, IsOutdoor = true, ManagerId = manager.UserId },

                // Kandy & Cultural Capital
                new() { Name = "Earl's Regency Kandy", LocationAddress = "Tennekumbura, Kandy", MaxCapacity = 700, BaseRentalPrice = 550000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "The Grand Kandyan Hotel", LocationAddress = "89/10 Lady Gordon's Drive, Kandy", MaxCapacity = 800, BaseRentalPrice = 600000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Mahaweli Reach Hotel", LocationAddress = "35 P.B.A. Weerakoon Mawatha, Kandy", MaxCapacity = 400, BaseRentalPrice = 480000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Amaya Hills Kandy", LocationAddress = "Heerassagala, Kandy", MaxCapacity = 300, BaseRentalPrice = 400000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Citadel Kandy", LocationAddress = "124 Srimath Kuda Ratwatte Mawatha, Kandy", MaxCapacity = 250, BaseRentalPrice = 380000, IsOutdoor = true, ManagerId = manager.UserId },

                // Down South & Coastal Venues
                new() { Name = "Jetwing Lighthouse Galle", LocationAddress = "Dadella, Galle", MaxCapacity = 450, BaseRentalPrice = 620000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Heritance Ahungalla", LocationAddress = "Galle Road, Ahungalla", MaxCapacity = 500, BaseRentalPrice = 550000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Bentota Beach", LocationAddress = "Bentota Coastal Strip", MaxCapacity = 600, BaseRentalPrice = 680000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Weligama Bay Marriott Resort", LocationAddress = "700 Matara Road, Weligama", MaxCapacity = 550, BaseRentalPrice = 720000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "The Fortress Resort & Spa", LocationAddress = "Koggala, Galle", MaxCapacity = 250, BaseRentalPrice = 520000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Anantara Peace Haven Tangalle", LocationAddress = "Goyambokka Estate, Tangalle", MaxCapacity = 300, BaseRentalPrice = 750000, IsOutdoor = true, ManagerId = manager.UserId },

                // Cultural Triangle & North Central
                new() { Name = "Heritance Kandalama", LocationAddress = "Kandalama, Dambulla", MaxCapacity = 350, BaseRentalPrice = 580000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Lodge Habarana", LocationAddress = "Habarana", MaxCapacity = 400, BaseRentalPrice = 460000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Jetwing Lake Dambulla", LocationAddress = "Mirisgonioya, Dambulla", MaxCapacity = 300, BaseRentalPrice = 420000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Aliya Resort & Spa", LocationAddress = "Audangawa, Sigiriya", MaxCapacity = 450, BaseRentalPrice = 500000, IsOutdoor = true, ManagerId = manager.UserId },

                // Negombo & Airport Zone
                new() { Name = "Heritance Negombo", LocationAddress = "Lewis Place, Negombo", MaxCapacity = 500, BaseRentalPrice = 540000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Jetwing Blue Negombo", LocationAddress = "Ethukale, Negombo", MaxCapacity = 400, BaseRentalPrice = 480000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Club Hotel Dolphin", LocationAddress = "Waikkal, Negombo", MaxCapacity = 600, BaseRentalPrice = 520000, IsOutdoor = true, ManagerId = manager.UserId },

                // Eastern & Northern Coast
                new() { Name = "Trinqua Blu by Cinnamon", LocationAddress = "Sampalthivu Post, Trincomalee", MaxCapacity = 350, BaseRentalPrice = 440000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Jetwing Jaffna", LocationAddress = "37 Mahatma Gandhi Road, Jaffna", MaxCapacity = 200, BaseRentalPrice = 320000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Uga Bay Passikudah", LocationAddress = "Passikudah Bay, Kalkudah", MaxCapacity = 300, BaseRentalPrice = 560000, IsOutdoor = true, ManagerId = manager.UserId }
            };

            context.Venues.AddRange(venues);
            await context.SaveChangesAsync();
        }

        // 4. Realistic Catering, AV, and Marquee Tent Resources Seeding
        if (!await context.Resources.AnyAsync())
        {
            var resources = new List<Resource>
            {
                // Catering Packages (Per Head)
                new() { ResourceName = "Executive Dinner Buffet (3 Meats, Seafood, 5 Salads, 8 Desserts)", ResourceType = "CateringPackage", UnitPrice = 6500, AvailableQuantity = 2000 },
                new() { ResourceName = "Premium Dinner Buffet B (2 Meats, Action Station, 6 Desserts)", ResourceType = "CateringPackage", UnitPrice = 5000, AvailableQuantity = 3000 },
                new() { ResourceName = "Standard Dinner Buffet A (Chicken/Fish, 4 Salads, 4 Desserts)", ResourceType = "CateringPackage", UnitPrice = 3800, AvailableQuantity = 5000 },
                new() { ResourceName = "Authentic Sri Lankan Heritage Feast (Claypot Style)", ResourceType = "CateringPackage", UnitPrice = 4200, AvailableQuantity = 2500 },
                new() { ResourceName = "High Tea & Evening Canapé Cocktail Platter", ResourceType = "CateringPackage", UnitPrice = 3200, AvailableQuantity = 1500 },
                new() { ResourceName = "Outdoor Live BBQ & Grill Station (Lamb, Prawns, Skewers)", ResourceType = "CateringPackage", UnitPrice = 7500, AvailableQuantity = 1000 },

                // Sound & Audio-Visual Systems
                new() { ResourceName = "Concert Line-Array Sound & Digital Mixer Package", ResourceType = "SoundLighting", UnitPrice = 180000, AvailableQuantity = 12 },
                new() { ResourceName = "Corporate Conference AV Setup (JBL Sound, 2 Wireless Mics)", ResourceType = "SoundLighting", UnitPrice = 85000, AvailableQuantity = 25 },
                new() { ResourceName = "Ambient Intelligent LED Moving Heads & Truss Rigging", ResourceType = "SoundLighting", UnitPrice = 95000, AvailableQuantity = 15 },
                new() { ResourceName = "P3 High-Definition Indoor/Outdoor LED Video Wall (16x10 ft)", ResourceType = "SoundLighting", UnitPrice = 220000, AvailableQuantity = 8 },
                new() { ResourceName = "DJ Console Pioneer Nexus Setup with Monitor Speakers", ResourceType = "SoundLighting", UnitPrice = 60000, AvailableQuantity = 20 },

                // Autonomous AI Contingency Safeguards (Crucial for AI Agent Workflow)
                new() { ResourceName = "Heavy-Duty Waterproof Marquee Tent (20x40 ft, Weather Safeguard)", ResourceType = "MarqueeTent", UnitPrice = 150000, AvailableQuantity = 15 },
                new() { ResourceName = "Waterproof Pagoda Canopy Tent (15x15 ft, Food/Bar Station)", ResourceType = "MarqueeTent", UnitPrice = 45000, AvailableQuantity = 30 },
                new() { ResourceName = "Industrial Outdoor Mist Coolers (Set of 4)", ResourceType = "ClimateControl", UnitPrice = 35000, AvailableQuantity = 20 },
                new() { ResourceName = "Outdoor Gas Patio Heaters (Hill Country Cold Defense)", ResourceType = "ClimateControl", UnitPrice = 40000, AvailableQuantity = 15 },
                new() { ResourceName = "Backup Diesel Silent Generator (60 kVA Uninterrupted Power)", ResourceType = "PowerBackup", UnitPrice = 90000, AvailableQuantity = 10 }
            };

            context.Resources.AddRange(resources);
            await context.SaveChangesAsync();
        }

        // 5. Realistic Sri Lankan Banquet Halls Seeding
        if (!await context.BanquetHalls.AnyAsync())
        {
            var venues = await context.Venues.ToListAsync();
            var halls = new List<BanquetHall>();

            foreach (var v in venues)
            {
                var lower = v.Name.ToLower();
                if (lower.Contains("shangri-la"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Lotus Grand Ballroom", MaxCapacity = 1000, HallRentalPrice = 450000, PerPlatePrice = 6500, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Sapphire Banquet Hall", MaxCapacity = 400, HallRentalPrice = 280000, PerPlatePrice = 6000, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Sunset Ocean Terrace", MaxCapacity = 250, HallRentalPrice = 220000, PerPlatePrice = 5500, IsOutdoor = true });
                }
                else if (lower.Contains("cinnamon grand"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Oak Room Ballroom", MaxCapacity = 600, HallRentalPrice = 350000, PerPlatePrice = 5500, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Cedar Banquet Suite", MaxCapacity = 300, HallRentalPrice = 200000, PerPlatePrice = 5000, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Atrium Garden Terrace", MaxCapacity = 350, HallRentalPrice = 250000, PerPlatePrice = 5200, IsOutdoor = true });
                }
                else if (lower.Contains("galle face hotel"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Grand Ballroom & Jubilee Hall", MaxCapacity = 450, HallRentalPrice = 380000, PerPlatePrice = 5800, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Chequerboard Lawn by the Sea", MaxCapacity = 500, HallRentalPrice = 420000, PerPlatePrice = 6000, IsOutdoor = true });
                }
                else if (lower.Contains("kingsbury"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "The Balmoral Ballroom", MaxCapacity = 400, HallRentalPrice = 320000, PerPlatePrice = 5600, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "The Winchester Suite", MaxCapacity = 200, HallRentalPrice = 180000, PerPlatePrice = 5200, IsOutdoor = false });
                }
                else if (lower.Contains("hilton"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Grand Ballroom", MaxCapacity = 700, HallRentalPrice = 380000, PerPlatePrice = 5800, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Poolside Palm Terrace", MaxCapacity = 300, HallRentalPrice = 240000, PerPlatePrice = 5200, IsOutdoor = true });
                }
                else if (lower.Contains("earl's regency") || lower.Contains("regency"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Regent Grand Ballroom", MaxCapacity = 700, HallRentalPrice = 280000, PerPlatePrice = 4800, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Mountbatten Pavilion & Garden", MaxCapacity = 300, HallRentalPrice = 200000, PerPlatePrice = 4500, IsOutdoor = true });
                }
                else if (lower.Contains("bentota"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Estuary Grand Ballroom", MaxCapacity = 450, HallRentalPrice = 380000, PerPlatePrice = 5800, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Bentota Beachfront Coconut Lawn", MaxCapacity = 600, HallRentalPrice = 420000, PerPlatePrice = 6000, IsOutdoor = true });
                }
                else if (lower.Contains("tea factory"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Highland Mist Banquet Hall", MaxCapacity = 150, HallRentalPrice = 220000, PerPlatePrice = 4800, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Cloud View Tea Plantation Lawn", MaxCapacity = 200, HallRentalPrice = 280000, PerPlatePrice = 5000, IsOutdoor = true });
                }
                else if (lower.Contains("peace haven") || lower.Contains("tangalle"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Peace Haven Grand Ballroom", MaxCapacity = 200, HallRentalPrice = 400000, PerPlatePrice = 6500, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Cliffside Ocean Palm Lawn", MaxCapacity = 300, HallRentalPrice = 500000, PerPlatePrice = 7000, IsOutdoor = true });
                }
                else if (lower.Contains("water's edge") || lower.Contains("waters edge"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Grand Ballroom & Eagle Suite", MaxCapacity = 600, HallRentalPrice = 400000, PerPlatePrice = 5500, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "The Boardwalk & Lakefront Lawn", MaxCapacity = 1000, HallRentalPrice = 450000, PerPlatePrice = 5800, IsOutdoor = true });
                }
                else if (lower.Contains("golf club"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Heritage Golf Clubhouse Hall", MaxCapacity = 180, HallRentalPrice = 220000, PerPlatePrice = 4500, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Colonial Pine Fairway Lawn", MaxCapacity = 300, HallRentalPrice = 280000, PerPlatePrice = 4800, IsOutdoor = true });
                }
                else if (lower.Contains("aliya"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Audangawa Banquet Suite", MaxCapacity = 250, HallRentalPrice = 280000, PerPlatePrice = 4800, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Sigiriya Rock View Garden Lawn", MaxCapacity = 450, HallRentalPrice = 350000, PerPlatePrice = 5200, IsOutdoor = true });
                }
                else if (lower.Contains("marriott") || lower.Contains("weligama"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Pearl Grand Ballroom", MaxCapacity = 550, HallRentalPrice = 480000, PerPlatePrice = 6200, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Sunset Oceanfront Lawn", MaxCapacity = 400, HallRentalPrice = 450000, PerPlatePrice = 6000, IsOutdoor = true });
                }
                else if (lower.Contains("marino beach"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Sky Grand Ballroom", MaxCapacity = 350, HallRentalPrice = 320000, PerPlatePrice = 5200, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Rooftop Oceanview Deck", MaxCapacity = 250, HallRentalPrice = 300000, PerPlatePrice = 5000, IsOutdoor = true });
                }
                else if (lower.Contains("lighthouse"))
                {
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Lighthouse Grand Ballroom", MaxCapacity = 300, HallRentalPrice = 380000, PerPlatePrice = 5500, IsOutdoor = false });
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Oceanfront Rocks Lawn", MaxCapacity = 450, HallRentalPrice = 420000, PerPlatePrice = 5800, IsOutdoor = true });
                }
                else
                {
                    // Indoor Grand Banquet Ballroom
                    halls.Add(new BanquetHall 
                    { 
                        VenueId = v.VenueId, 
                        HallName = $"{v.Name.Replace("Hotel", "").Replace("Resort", "").Trim()} Grand Ballroom", 
                        MaxCapacity = Math.Max(200, (int)(v.MaxCapacity * 0.75)), 
                        HallRentalPrice = Math.Min(v.BaseRentalPrice * 0.85m, 350000m), 
                        PerPlatePrice = 5200m, 
                        IsOutdoor = false 
                    });

                    // Outdoor Scenic Lawn / Terrace
                    halls.Add(new BanquetHall 
                    { 
                        VenueId = v.VenueId, 
                        HallName = $"{v.Name.Replace("Hotel", "").Replace("Resort", "").Trim()} Scenic Garden Lawn & Terrace", 
                        MaxCapacity = v.MaxCapacity, 
                        HallRentalPrice = Math.Min(v.BaseRentalPrice, 400000m), 
                        PerPlatePrice = 5500m, 
                        IsOutdoor = true 
                    });
                }
            }

            context.BanquetHalls.AddRange(halls);
            await context.SaveChangesAsync();
        }

        // 6. Realistic Multi-Category Event Vendors Seeding
        if (!await context.Vendors.AnyAsync())
        {
            var defaultUser = await context.Users.FirstOrDefaultAsync();
            var userId = defaultUser?.UserId ?? Guid.Empty;

            var vendors = new List<Vendor>
            {
                new() { BusinessName = "Lumina Pro Audio & Stage Lighting", Category = "SoundLighting", ContactNumber = "+94 77 123 4567", VerificationStatus = "Verified", AdminRemarks = "Concert Line-Array Rig + 16 Moving Heads", UserId = userId },
                new() { BusinessName = "Royal Blooms Floral & Stage Design", Category = "Decor", ContactNumber = "+94 77 234 5678", VerificationStatus = "Verified", AdminRemarks = "Royal Fresh Flower Ceiling Drapes & Grand Stage", UserId = userId },
                new() { BusinessName = "Studio Lumiere Wedding & Event Photography", Category = "Photography", ContactNumber = "+94 77 345 6789", VerificationStatus = "Verified", AdminRemarks = "Master Wedding Photography + 4K Highlights Video + Album", UserId = userId },
                new() { BusinessName = "Velvet Crumb Artisan Cake Studio", Category = "Cake", ContactNumber = "+94 77 456 7890", VerificationStatus = "Verified", AdminRemarks = "5-Tier Royal Handcrafted Fondant Wedding Cake", UserId = userId },
                new() { BusinessName = "Royal Crown VIP & Bridal Chauffeurs", Category = "Transport", ContactNumber = "+94 77 567 8901", VerificationStatus = "Verified", AdminRemarks = "Classic Vintage Rolls Royce / Jaguar Bridal Car", UserId = userId },
                new() { BusinessName = "Ceylon Grand Banquet Caterers", Category = "Catering", ContactNumber = "+94 77 678 9012", VerificationStatus = "Verified", AdminRemarks = "Royal 7-Course International Gala Buffet", UserId = userId },
                new() { BusinessName = "Ceylon WeatherShield Marquee Tents", Category = "MarqueeTent", ContactNumber = "+94 77 789 0123", VerificationStatus = "Verified", AdminRemarks = "Heavy-Duty Waterproof Marquee Tent (20x40 ft)", UserId = userId },
                new() { BusinessName = "VoltMax Heavy Power & Generator Hire", Category = "PowerBackup", ContactNumber = "+94 77 890 1234", VerificationStatus = "Verified", AdminRemarks = "Backup Diesel Silent Generator (60 kVA Heavy Duty)", UserId = userId },
                
                // Pending Verification Requests
                new() { BusinessName = "LensCraft 4K Drone & Cinematic Media", Category = "Photography", ContactNumber = "+94 70 332 1144", VerificationStatus = "Pending", AdminRemarks = "Professional Event Coverage (2 Photographers + Unlimited Soft Copies)", UserId = userId },
                new() { BusinessName = "Sweet Elegance Designer Cake House", Category = "Cake", ContactNumber = "+94 72 667 8899", VerificationStatus = "Pending", AdminRemarks = "3-Tier Luxury Floral Wedding Cake", UserId = userId },
                new() { BusinessName = "Prestige Executive Mercedes Fleet", Category = "Transport", ContactNumber = "+94 75 998 8776", VerificationStatus = "Pending", AdminRemarks = "Mercedes-Benz S-Class Luxury Chauffeur Sedan", UserId = userId }
            };

            context.Vendors.AddRange(vendors);
            await context.SaveChangesAsync();
        }
    }
}