using EventManagement.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Infrastructure.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(AppDbContext context)
    {
        // Migrate any existing users with plaintext passwords to secure BCrypt hashes safely
        var existingUsers = await context.Users.ToListAsync();
        bool usersUpdated = false;
        foreach (var user in existingUsers)
        {
            if (!string.IsNullOrEmpty(user.PasswordHash) &&
                !user.PasswordHash.StartsWith("$2a$") &&
                !user.PasswordHash.StartsWith("$2b$") &&
                !user.PasswordHash.StartsWith("$2y$"))
            {
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(user.PasswordHash);
                usersUpdated = true;
            }
        }
        if (usersUpdated)
        {
            await context.SaveChangesAsync();
        }

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
        var managerRole = await context.Roles.FirstAsync(r => r.RoleName == "Manager");
        var customerRole = await context.Roles.FirstAsync(r => r.RoleName == "Customer");

        if (!await context.Users.AnyAsync(u => u.Email == "manager@eventcraft.lk"))
        {
            context.Users.Add(new User
            {
                UserId = Guid.Parse("11111111-1111-1111-1111-111111111111"),
                FullName = "Kasun Bandara (Operations Manager)",
                Email = "manager@eventcraft.lk",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Manager@2026"),
                PhoneNumber = "+94771234567",
                RoleId = managerRole.RoleId,
                AccountStatus = "Active"
            });
            await context.SaveChangesAsync();
        }

        if (!await context.Users.AnyAsync(u => u.Email == "sahan@gmail.com"))
        {
            context.Users.Add(new User
            {
                UserId = Guid.Parse("22222222-2222-2222-2222-222222222222"),
                FullName = "Sahan Perera (Client)",
                Email = "sahan@gmail.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Customer@2026"),
                PhoneNumber = "+94719876543",
                RoleId = customerRole.RoleId,
                AccountStatus = "Active"
            });
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
        // NOTE: Photography category is intentionally kept clean (unseeded) so the user can live-register and demonstrate Photography vendors at the viva!
        try
        {
            var legacyPhotoVendors = await context.Vendors
                .Where(v => v.Category == "Photography" && (v.BusinessName.Contains("EventCraft") || v.BusinessName.Contains("Seeded") || v.BusinessName.Contains("Studio Lumiere")))
                .ToListAsync();
            if (legacyPhotoVendors.Any())
            {
                context.Vendors.RemoveRange(legacyPhotoVendors);
                await context.SaveChangesAsync();
            }
        }
        catch { }

        var systemCatalogVendorId = Guid.Parse("00000000-0000-0000-0000-000000000001");
        if (!await context.Users.AnyAsync(u => u.UserId == systemCatalogVendorId))
        {
            context.Users.Add(new User
            {
                UserId = systemCatalogVendorId,
                FullName = "EventCraft System Catalog",
                Email = "catalog-system@eventcraft.lk",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("SystemCatalog@2026"),
                PhoneNumber = "+94112000000",
                RoleId = managerRole.RoleId,
                AccountStatus = "Active"
            });
            await context.SaveChangesAsync();
        }
        var userId = systemCatalogVendorId;

        var predefinedVendors = new List<Vendor>
        {
            // 1. Sound & Stage Lighting (Tiers 1 - 9)
            new() { BusinessName = "QuickSound Acoustic & Speech Kit - Homagama", Category = "SoundLighting", ContactNumber = "+94 77 100 2233", VerificationStatus = "Verified", PackageName = "Compact Speech PA & Bluetooth Unit", PackagePrice = 15000, AdminRemarks = "Budget speech & acoustic PA system for micro events", UserId = userId },
            new() { BusinessName = "CityBeat Community Audio - Maharagama", Category = "SoundLighting", ContactNumber = "+94 77 105 4567", VerificationStatus = "Verified", PackageName = "Dual Powered PA Speaker Kit with Mic", PackagePrice = 20000, AdminRemarks = "Basic dual powered speakers & wired mic", UserId = userId },
            new() { BusinessName = "Derana Acoustics & PA System - Gampaha", Category = "SoundLighting", ContactNumber = "+94 77 111 2233", VerificationStatus = "Verified", PackageName = "Derana Compact Speech PA & Wireless Mics", PackagePrice = 25000, AdminRemarks = "Economy PA System for small gatherings & speeches", UserId = userId },
            new() { BusinessName = "Mano Sounds & Acoustic Setup - Moratuwa", Category = "SoundLighting", ContactNumber = "+94 77 123 4567", VerificationStatus = "Verified", PackageName = "Compact Speech PA Kit + 2 Wireless Mics", PackagePrice = 40000, AdminRemarks = "Budget PA system with dual wireless microphones", UserId = userId },
            new() { BusinessName = "SonicPulse Live Sound & Stage Monitors - Negombo", Category = "SoundLighting", ContactNumber = "+94 77 222 9988", VerificationStatus = "Verified", PackageName = "Stage Audio System + 2 Stage Monitors", PackagePrice = 60000, AdminRemarks = "4-Speaker powered setup with monitors & digital mix", UserId = userId },
            new() { BusinessName = "VibeWave Audio & Ambient LED - Kandy", Category = "SoundLighting", ContactNumber = "+94 77 234 5678", VerificationStatus = "Verified", PackageName = "Standard Stage Audio + Warm Ambient LED PAR Cans", PackagePrice = 85000, AdminRemarks = "Stage Audio System, Warm LED Mood Uplights, Digital Console", UserId = userId },
            new() { BusinessName = "Sensations Audio & Intelligent Lights - Colombo", Category = "SoundLighting", ContactNumber = "+94 77 333 4455", VerificationStatus = "Verified", PackageName = "Sensations Intelligent Audio & PAR Lighting", PackagePrice = 120000, AdminRemarks = "Digital console, moving heads & LED PAR uplights", UserId = userId },
            new() { BusinessName = "Lumina Pro Audio & Stage Lighting", Category = "SoundLighting", ContactNumber = "+94 77 345 6789", VerificationStatus = "Verified", PackageName = "Concert Line-Array Sound & Digital Mixer Package", PackagePrice = 180000, AdminRemarks = "Line-Array Sound & Digital Mixer Package", UserId = userId },
            new() { BusinessName = "Mega Sound Pro Audio & Line-Array Rig - Kandy", Category = "SoundLighting", ContactNumber = "+94 77 444 5566", VerificationStatus = "Verified", PackageName = "Mega Sound Line-Array Concert Setup", PackagePrice = 200000, AdminRemarks = "Full Line-Array concert sound rig with digital mixer", UserId = userId },
            new() { BusinessName = "Dynamic AV Technologies & Concert Rigging", Category = "SoundLighting", ContactNumber = "+94 77 456 7890", VerificationStatus = "Verified", PackageName = "Concert Line-Array Rig + 16 Moving Heads + Beam Trusses", PackagePrice = 250000, AdminRemarks = "Concert Rigging with 16 Moving Heads & Beam Trusses", UserId = userId },

            // 2. Floral Decor & Stage Styling (Tiers 1 - 9)
            new() { BusinessName = "Suba Setha Flora & Traditional Backdrop - Kadawatha", Category = "Decor", ContactNumber = "+94 77 550 1122", VerificationStatus = "Verified", PackageName = "Traditional Oil Lamp, Minimal Poruwa & Head Table Deco", PackagePrice = 18000, AdminRemarks = "Budget traditional floral backdrop & oil lamp setup", UserId = userId },
            new() { BusinessName = "Piyum Flora & Budget Event Decor - Malabe", Category = "Decor", ContactNumber = "+94 77 552 3344", VerificationStatus = "Verified", PackageName = "Economy Fabric Backdrop & Floral Table Runner", PackagePrice = 25000, AdminRemarks = "Minimalist fabric stage drape, artificial flowers & table styling", UserId = userId },
            new() { BusinessName = "Nelum Decorators & Flora - Kiribathgoda", Category = "Decor", ContactNumber = "+94 77 555 6677", VerificationStatus = "Verified", PackageName = "Nelum Economy Stage & Cake Table Decor", PackagePrice = 30000, AdminRemarks = "Budget floral backdrop & cake table styling", UserId = userId },
            new() { BusinessName = "Samanmal Flora & Deco Maharagama", Category = "Decor", ContactNumber = "+94 77 567 8901", VerificationStatus = "Verified", PackageName = "Minimalist Floral Arch + Cake Table Styling", PackagePrice = 45000, AdminRemarks = "Minimalist floral arch, Poruwa styling & cake table", UserId = userId },
            new() { BusinessName = "Blossom & Petal Thematic Studio - Panadura", Category = "Decor", ContactNumber = "+94 77 660 8899", VerificationStatus = "Verified", PackageName = "Floral Photo Booth & Elegant Settee Stage Drapes", PackagePrice = 65000, AdminRemarks = "Photo booth, stage drapes & artificial flower centerpieces", UserId = userId },
            new() { BusinessName = "Lassana Events & Floral Concepts", Category = "Decor", ContactNumber = "+94 77 678 9012", VerificationStatus = "Verified", PackageName = "Thematic Floral Stage + Table Centerpieces", PackagePrice = 85000, AdminRemarks = "Thematic floral stage, entrance arch, table centerpieces", UserId = userId },
            new() { BusinessName = "Orchid Garden Event Decorators - Galle", Category = "Decor", ContactNumber = "+94 77 666 7788", VerificationStatus = "Verified", PackageName = "Orchid Garden Fresh Floral & Stage Arch", PackagePrice = 110000, AdminRemarks = "Fresh floral entrance arch, stage backdrop & centerpieces", UserId = userId },
            new() { BusinessName = "Petals & Drapes Luxury Event Stylists", Category = "Decor", ContactNumber = "+94 77 789 0123", VerificationStatus = "Verified", PackageName = "Thematic Floral Stage + Entrance Tunnel Arch", PackagePrice = 140000, AdminRemarks = "Thematic floral stage, entrance tunnel arch, settee backdrop", UserId = userId },
            new() { BusinessName = "Poruwa Events & Majestic Botanical Artistry", Category = "Decor", ContactNumber = "+94 77 777 8899", VerificationStatus = "Verified", PackageName = "Poruwa Grand Botanical & Ceiling Drapes", PackagePrice = 180000, AdminRemarks = "Royal botanical stage art, ceiling drapes & starry wall", UserId = userId },
            new() { BusinessName = "Royal Blooms Floral & Botanical Artistry", Category = "Decor", ContactNumber = "+94 77 890 1234", VerificationStatus = "Verified", PackageName = "Royal Fresh Flower Ceiling Drapes & Grand Stage Decor", PackagePrice = 220000, AdminRemarks = "Grand stage decor, fresh flower ceiling drapes, starry wall", UserId = userId },

            // 3. VIP Transport & Bridal Cars (Tiers 1 - 9)
            new() { BusinessName = "SmartRide Ceylon Executive Hybrid Escorts - Nugegoda", Category = "Transport", ContactNumber = "+94 77 880 1199", VerificationStatus = "Verified", PackageName = "Toyota Prius / Axio Hybrid Chauffeur Sedan", PackagePrice = 14000, AdminRemarks = "Clean air-conditioned hybrid sedan with chauffeur", UserId = userId },
            new() { BusinessName = "Lanka Chauffeur Transfers - Hybrid Fleet", Category = "Transport", ContactNumber = "+94 77 888 9900", VerificationStatus = "Verified", PackageName = "Toyota Axio / Grace Executive Hybrid Sedan", PackagePrice = 20000, AdminRemarks = "Budget air-conditioned executive sedan", UserId = userId },
            new() { BusinessName = "Colombo Budget Chauffeurs - Dehiwala", Category = "Transport", ContactNumber = "+94 77 895 4422", VerificationStatus = "Verified", PackageName = "Toyota Allion / Premio Executive Sedan", PackagePrice = 25000, AdminRemarks = "Comfortable air-conditioned executive sedan", UserId = userId },
            new() { BusinessName = "Kandy & Colombo Executive Transfers", Category = "Transport", ContactNumber = "+94 77 901 2345", VerificationStatus = "Verified", PackageName = "Toyota Premio / Allion Executive Chauffeur Sedan", PackagePrice = 35000, AdminRemarks = "Comfortable air-conditioned executive chauffeur sedan", UserId = userId },
            new() { BusinessName = "Crown Luxury Auto Escorts - Colombo", Category = "Transport", ContactNumber = "+94 77 999 0011", VerificationStatus = "Verified", PackageName = "Chrysler 300C / Audi A6 Executive Bridal Sedan", PackagePrice = 45000, AdminRemarks = "Executive luxury bridal chauffeur sedan", UserId = userId },
            new() { BusinessName = "SilverLine Executive BMW Fleet", Category = "Transport", ContactNumber = "+94 77 012 3456", VerificationStatus = "Verified", PackageName = "BMW 5-Series Executive Bridal Sedan", PackagePrice = 50000, AdminRemarks = "BMW 5-Series Executive bridal chauffeur sedan", UserId = userId },
            new() { BusinessName = "Prestige Executive Mercedes Fleet", Category = "Transport", ContactNumber = "+94 77 123 7890", VerificationStatus = "Verified", PackageName = "Mercedes-Benz S-Class Luxury Chauffeur Sedan", PackagePrice = 65000, AdminRemarks = "Mercedes-Benz S-Class luxury chauffeur sedan", UserId = userId },
            new() { BusinessName = "Lanka Vintage & Luxury Prado Escorts", Category = "Transport", ContactNumber = "+94 77 111 0022", VerificationStatus = "Verified", PackageName = "Land Cruiser Prado V8 / Convertible Luxury Escort", PackagePrice = 80000, AdminRemarks = "Prado V8 / Convertible luxury bridal car", UserId = userId },
            new() { BusinessName = "Royal Crown Vintage Rolls Royce & Jaguar Escorts", Category = "Transport", ContactNumber = "+94 77 234 8901", VerificationStatus = "Verified", PackageName = "Classic Vintage Rolls Royce / 1954 Jaguar Mark VII", PackagePrice = 95000, AdminRemarks = "Classic vintage Rolls Royce / Jaguar Mark VII bridal car", UserId = userId },

            // 4. Celebration Cakes & Confectionery (Tiers 1 - 9)
            new() { BusinessName = "SweetBites Artisan Home Bakery - Moratuwa", Category = "Cake", ContactNumber = "+94 77 210 5544", VerificationStatus = "Verified", PackageName = "1-Tier Classic Buttercream Celebration Cake", PackagePrice = 7500, AdminRemarks = "1-Tier fresh vanilla/ribbon celebration cake", UserId = userId },
            new() { BusinessName = "BakeHouse Ceylon - Panadura", Category = "Cake", ContactNumber = "+94 77 222 3344", VerificationStatus = "Verified", PackageName = "1-Tier Classic Buttercream Celebration Cake", PackagePrice = 10000, AdminRemarks = "1-Tier classic buttercream cake for intimate parties", UserId = userId },
            new() { BusinessName = "Cupcake Boutique Ceylon - Nugegoda", Category = "Cake", ContactNumber = "+94 77 225 6677", VerificationStatus = "Verified", PackageName = "2-Tier Minimalist Buttercream Cake", PackagePrice = 12000, AdminRemarks = "2-Tier handcrafted celebration cake", UserId = userId },
            new() { BusinessName = "The Fab & Sponge Sweet Treats Colombo", Category = "Cake", ContactNumber = "+94 77 345 9012", VerificationStatus = "Verified", PackageName = "2-Tier Classic Buttercream Celebration Cake", PackagePrice = 15000, AdminRemarks = "2-Tier classic buttercream celebration gateau", UserId = userId },
            new() { BusinessName = "Butter & Cream Cake Studio - Kelaniya", Category = "Cake", ContactNumber = "+94 77 333 2211", VerificationStatus = "Verified", PackageName = "2-Tier Handcrafted Fondant Thematic Cake", PackagePrice = 22000, AdminRemarks = "2-Tier handcrafted custom fondant cake", UserId = userId },
            new() { BusinessName = "SugarStory Bespoke Cakes - Malabe", Category = "Cake", ContactNumber = "+94 77 456 0123", VerificationStatus = "Verified", PackageName = "2-Tier Custom Handcrafted Fondant Cake", PackagePrice = 30000, AdminRemarks = "2-Tier handcrafted custom thematic fondant cake", UserId = userId },
            new() { BusinessName = "Sweet Elegance Designer Cake House", Category = "Cake", ContactNumber = "+94 77 567 1234", VerificationStatus = "Verified", PackageName = "3-Tier Luxury Floral Wedding Cake", PackagePrice = 45000, AdminRemarks = "3-Tier luxury floral handcrafted wedding cake", UserId = userId },
            new() { BusinessName = "Cakes by Devli - Luxury Fondant Studio", Category = "Cake", ContactNumber = "+94 77 444 3322", VerificationStatus = "Verified", PackageName = "4-Tier Luxury Floral Fondant Wedding Cake", PackagePrice = 50000, AdminRemarks = "4-Tier luxury floral handcrafted wedding cake", UserId = userId },
            new() { BusinessName = "Velvet Crumb Artisan Cake Studio", Category = "Cake", ContactNumber = "+94 77 678 2345", VerificationStatus = "Verified", PackageName = "5-Tier Royal Handcrafted Fondant Wedding Cake", PackagePrice = 65000, AdminRemarks = "5-Tier royal handcrafted fondant cake with sugar flowers", UserId = userId },

            // 5. Catering Buffets (Tiers 1 - 10)
            new() { BusinessName = "Aroma Village Kitchen & Claypot Feast - Kottawa", Category = "Catering", ContactNumber = "+94 77 550 4411", VerificationStatus = "Verified", PackageName = "Village Claypot Rice & Curry Feast", PackagePrice = 1800, AdminRemarks = "Village rice & curry, 3 vegetables, chicken, pappadam & watalappan per plate", UserId = userId },
            new() { BusinessName = "Suwanda Bojun Event Caterers - Piliyandala", Category = "Catering", ContactNumber = "+94 77 552 8822", VerificationStatus = "Verified", PackageName = "Mixed Fried Rice & Chilli Chicken Feast", PackagePrice = 2200, AdminRemarks = "Mixed fried rice, chilli chicken, fish, chop suey & pudding per plate", UserId = userId },
            new() { BusinessName = "Suriya Caterers & Event Foods - Nugegoda", Category = "Catering", ContactNumber = "+94 77 555 4433", VerificationStatus = "Verified", PackageName = "Traditional Sri Lankan Rice & Curry Feast", PackagePrice = 2800, AdminRemarks = "Chicken, Dhal, 3 Vegetables, Salads & Dessert per plate", UserId = userId },
            new() { BusinessName = "SpiceRoute Catering Service - Wattala", Category = "Catering", ContactNumber = "+94 77 558 7733", VerificationStatus = "Verified", PackageName = "Basmati Yellow Rice & Devilled Feast", PackagePrice = 3200, AdminRemarks = "Yellow rice, chicken curry, devilled fish, salads & ice cream per plate", UserId = userId },
            new() { BusinessName = "Perera & Sons (P&S Event Catering)", Category = "Catering", ContactNumber = "+94 77 789 3456", VerificationStatus = "Verified", PackageName = "Authentic Sri Lankan Traditional Feast", PackagePrice = 3800, AdminRemarks = "Chicken, Fish, Dhal, 4 Salads, 4 Desserts per plate", UserId = userId },
            new() { BusinessName = "Golden Harvest Banquet Caterers - Malabe", Category = "Catering", ContactNumber = "+94 77 666 5544", VerificationStatus = "Verified", PackageName = "Classic Fried Rice & Noodle Banquet Buffet", PackagePrice = 4500, AdminRemarks = "2 Meats, Fish, Noodles, Action Station, 5 Desserts per plate", UserId = userId },
            new() { BusinessName = "Harpos Hospitality & Outdoor Catering", Category = "Catering", ContactNumber = "+94 77 890 4567", VerificationStatus = "Verified", PackageName = "Classic Asian & Sri Lankan Fusion Buffet", PackagePrice = 5000, AdminRemarks = "2 Meats, Action Station, 6 Desserts per plate", UserId = userId },
            new() { BusinessName = "Galadari Premier Gourmet Catering - Colombo", Category = "Catering", ContactNumber = "+94 77 777 6655", VerificationStatus = "Verified", PackageName = "Galadari Premier International Gourmet Buffet", PackagePrice = 6200, AdminRemarks = "Carvery, Seafood, International Dishes & Live Desserts per plate", UserId = userId },
            new() { BusinessName = "Ceylon Grand Banquet Caterers", Category = "Catering", ContactNumber = "+94 77 901 5678", VerificationStatus = "Verified", PackageName = "Executive 5-Course Carvery & Seafood Buffet", PackagePrice = 6800, AdminRemarks = "3 Meats, Seafood, Pasta, 8 Desserts per plate", UserId = userId },
            new() { BusinessName = "Mount Lavinia Premier Banquet Catering", Category = "Catering", ContactNumber = "+94 77 012 3344", VerificationStatus = "Verified", PackageName = "Royal 7-Course International Gala Buffet", PackagePrice = 8500, AdminRemarks = "5 Star luxury international carvery, sushi & live gourmet stations", UserId = userId },

            // 6. Refreshments & Beverage Stations (Tiers 1 - 4)
            new() { BusinessName = "Ceylon Tea Trails Mobile Brew Station", Category = "Refreshments", ContactNumber = "+94 77 012 6789", VerificationStatus = "Verified", PackageName = "Traditional Ceylon Ginger Tea, Coffee & Short Eats", PackagePrice = 250, AdminRemarks = "Traditional hot brews & Sri Lankan savories per head", UserId = userId },
            new() { BusinessName = "Tropical Splash Fresh Juice & Mocktail Bar", Category = "Refreshments", ContactNumber = "+94 77 123 6780", VerificationStatus = "Verified", PackageName = "Tropical Fresh Fruit Juices & Chilled Mocktail Bar", PackagePrice = 500, AdminRemarks = "Live fruit blends & chilled mocktail bar per head", UserId = userId },
            new() { BusinessName = "Barista & Bean Artisanal Espresso Lounge", Category = "Refreshments", ContactNumber = "+94 77 234 7891", VerificationStatus = "Verified", PackageName = "Artisanal Ceylon Tea & Italian Espresso Barista Lounge", PackagePrice = 800, AdminRemarks = "Italian espresso, barista brews & pastry bar per head", UserId = userId },
            new() { BusinessName = "Pilawoos & StreetEats Live Midnight Station", Category = "Refreshments", ContactNumber = "+94 77 345 8902", VerificationStatus = "Verified", PackageName = "Live Midnight Street Food Station (Kottu & Rotti)", PackagePrice = 950, AdminRemarks = "Live Kottu, cheese rotti & hopper station per head", UserId = userId },

            // 7. Marquee Tents & Weather Safeguards (Tiers 1 - 9)
            new() { BusinessName = "QuickShade Canopy Rentals - Kelaniya", Category = "MarqueeTent", ContactNumber = "+94 77 870 1144", VerificationStatus = "Verified", PackageName = "Economy Rain Canopy (10x10 ft)", PackagePrice = 18000, AdminRemarks = "Quick setup water-resistant canopy tent", UserId = userId },
            new() { BusinessName = "Gampaha Shade Masters Canopy Hire", Category = "MarqueeTent", ContactNumber = "+94 77 888 7766", VerificationStatus = "Verified", PackageName = "Pagoda Rain Canopy (15x15 ft)", PackagePrice = 30000, AdminRemarks = "Compact pagoda rain canopy", UserId = userId },
            new() { BusinessName = "Apex Canopies & Tents - Ragama", Category = "MarqueeTent", ContactNumber = "+94 77 889 3355", VerificationStatus = "Verified", PackageName = "Waterproof Canopy Shelter (15x20 ft)", PackagePrice = 35000, AdminRemarks = "Waterproof canopy shelter with side curtains", UserId = userId },
            new() { BusinessName = "Rohan Canopy Rentals Kaduwela", Category = "MarqueeTent", ContactNumber = "+94 77 456 9013", VerificationStatus = "Verified", PackageName = "Waterproof Pagoda / Rain Shelter Canopy (15x15 ft)", PackagePrice = 45000, AdminRemarks = "Waterproof pagoda / rain shelter canopy", UserId = userId },
            new() { BusinessName = "SunShade Canopies & Pergolas Colombo", Category = "MarqueeTent", ContactNumber = "+94 77 678 9900", VerificationStatus = "Verified", PackageName = "High-Peak Waterproof Stretch Canopy (20x30 ft)", PackagePrice = 80000, AdminRemarks = "High-peak waterproof stretch canopy with side rain curtains", UserId = userId },
            new() { BusinessName = "Lanka Marquee Structures & Event Hangars", Category = "MarqueeTent", ContactNumber = "+94 77 999 8877", VerificationStatus = "Verified", PackageName = "Heavy-Duty Waterproof Pavilion (20x30 ft)", PackagePrice = 110000, AdminRemarks = "Heavy-duty waterproof pavilion tent", UserId = userId },
            new() { BusinessName = "Ceylon WeatherShield Marquee Tents", Category = "MarqueeTent", ContactNumber = "+94 77 567 0124", VerificationStatus = "Verified", PackageName = "Heavy-Duty Waterproof Marquee Tent (20x40 ft)", PackagePrice = 150000, AdminRemarks = "Heavy-duty waterproof marquee weather safeguard", UserId = userId },
            new() { BusinessName = "Ceylon Royal German Hangar & Event Canopies", Category = "MarqueeTent", ContactNumber = "+94 77 111 3322", VerificationStatus = "Verified", PackageName = "Clear-Span Event Hangar (30x60 ft)", PackagePrice = 220000, AdminRemarks = "Clear-span waterproof event hangar", UserId = userId },
            new() { BusinessName = "Grand Royal German Hangar Marquees", Category = "MarqueeTent", ContactNumber = "+94 77 789 1122", VerificationStatus = "Verified", PackageName = "Air-Conditioned Transparent German Hangar Marquee (40x80 ft)", PackagePrice = 350000, AdminRemarks = "Luxury German structure air-conditioned transparent marquee", UserId = userId },

            // 8. Power Backup & Generators (Tiers 1 - 5)
            new() { BusinessName = "PowerGen Compact Mobile Hire - Borella", Category = "PowerBackup", ContactNumber = "+94 77 880 3311", VerificationStatus = "Verified", PackageName = "Portable Silent Generator 15 kVA", PackagePrice = 30000, AdminRemarks = "Ultra compact silent generator for small setups", UserId = userId },
            new() { BusinessName = "EcoPower Silent Mobile Generators", Category = "PowerBackup", ContactNumber = "+94 77 890 2233", VerificationStatus = "Verified", PackageName = "Silent Mobile Generator 30 kVA (Heavy Duty)", PackagePrice = 50000, AdminRemarks = "Ultra silent 30 kVA generator for outdoor events", UserId = userId },
            new() { BusinessName = "VoltMax Heavy Power Hire", Category = "PowerBackup", ContactNumber = "+94 77 678 1235", VerificationStatus = "Verified", PackageName = "Backup Diesel Silent Generator (60 kVA Heavy Duty)", PackagePrice = 90000, AdminRemarks = "Backup diesel silent 60 kVA generator unit", UserId = userId },
            new() { BusinessName = "SparkLine Industrial Power Systems", Category = "PowerBackup", ContactNumber = "+94 77 789 2346", VerificationStatus = "Verified", PackageName = "Industrial 100 kVA Synchronized Silent Dual Generator", PackagePrice = 160000, AdminRemarks = "Industrial 100 kVA synchronized dual generator", UserId = userId },
            new() { BusinessName = "PrimeGrid Synchronized Heavy Dual Generators", Category = "PowerBackup", ContactNumber = "+94 77 901 3344", VerificationStatus = "Verified", PackageName = "Synchronized Dual 250 kVA Industrial Generator Grid", PackagePrice = 280000, AdminRemarks = "Industrial dual 250 kVA generator grid for large concerts & luxury galas", UserId = userId }
        };

        try
        {
            var legacySpamVendors = await context.Vendors
                .Where(v => v.BusinessName.Contains("Sumane") ||
                            v.BusinessName.Contains("23yrw") ||
                            v.BusinessName.Contains("jeiwrk") ||
                            (v.PackageName == null && (v.BusinessName.Contains("Prestige") || v.BusinessName.Contains("Royal Crown VIP"))))
                .ToListAsync();
            if (legacySpamVendors.Any())
            {
                context.Vendors.RemoveRange(legacySpamVendors);
                await context.SaveChangesAsync();
            }
        }
        catch { }

        foreach (var pv in predefinedVendors)
        {
            var existing = await context.Vendors.FirstOrDefaultAsync(v => v.BusinessName == pv.BusinessName);
            if (existing == null)
            {
                context.Vendors.Add(pv);
            }
            else
            {
                existing.PackageName = pv.PackageName;
                existing.PackagePrice = pv.PackagePrice;
                existing.VerificationStatus = "Verified";
                existing.Category = pv.Category;
                existing.UserId = systemCatalogVendorId;
            }
        }
        await context.SaveChangesAsync();
    }
}