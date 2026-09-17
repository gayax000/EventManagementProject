using EventManagement.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Infrastructure.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(AppDbContext context)
    {
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
                new() { Name = "Shangri-La Colombo - Lotus Ballroom", LocationAddress = "1 Galle Face, Colombo 02", MaxCapacity = 1200, BaseRentalPrice = 850000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Grand Colombo - Oak Room", LocationAddress = "77 Galle Road, Colombo 03", MaxCapacity = 600, BaseRentalPrice = 650000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Galle Face Hotel - Chequerboard Lawn", LocationAddress = "2 Galle Road, Colombo 03", MaxCapacity = 500, BaseRentalPrice = 750000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Lakeside - Waters Edge Lawn", LocationAddress = "115 Sir Chittampalam A Gardiner Mawatha, Colombo 02", MaxCapacity = 450, BaseRentalPrice = 550000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Hilton Colombo - Grand Ballroom", LocationAddress = "2 Sir Chittampalam A Gardiner Mawatha, Colombo 02", MaxCapacity = 700, BaseRentalPrice = 700000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "The Kingsbury Colombo - The Balmoral", LocationAddress = "48 Janadhipathi Mawatha, Colombo 01", MaxCapacity = 400, BaseRentalPrice = 500000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Water's Edge Battaramulla - Grand Lawn", LocationAddress = "316 Pannipitiya Road, Battaramulla", MaxCapacity = 1000, BaseRentalPrice = 600000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Mount Lavinia Hotel - Imperial Beach Lawn", LocationAddress = "100 Hotel Road, Mount Lavinia", MaxCapacity = 600, BaseRentalPrice = 580000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Mövenpick Hotel Colombo - Sky Lounge & Terrace", LocationAddress = "24 Dharmapala Mawatha, Colombo 03", MaxCapacity = 200, BaseRentalPrice = 400000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Marino Beach Colombo - Sky Ballroom", LocationAddress = "590 Marine Drive, Colombo 03", MaxCapacity = 350, BaseRentalPrice = 450000, IsOutdoor = false, ManagerId = manager.UserId },

                // Nuwara Eliya & Central Highlands (Cold & Rain Risk Locations)
                new() { Name = "The Grand Hotel Nuwara Eliya - Governors Lawn", LocationAddress = "Grand Hotel Road, Nuwara Eliya", MaxCapacity = 350, BaseRentalPrice = 450000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Heritance Tea Factory - Highland View Terrace", LocationAddress = "Kandapola, Nuwara Eliya", MaxCapacity = 200, BaseRentalPrice = 380000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Araliya Green City - Banquet Pavilion", LocationAddress = "Nuwara Eliya Town Center", MaxCapacity = 400, BaseRentalPrice = 420000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Jetwing St. Andrew's - Pine Lawn", LocationAddress = "St. Andrew's Drive, Nuwara Eliya", MaxCapacity = 180, BaseRentalPrice = 320000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Nuwara Eliya Golf Club - Heritage Club Grounds", LocationAddress = "Park Road, Nuwara Eliya", MaxCapacity = 300, BaseRentalPrice = 350000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Langdale Boutique Hotel - Valley View Lawn", LocationAddress = "Radella, Nuwara Eliya", MaxCapacity = 150, BaseRentalPrice = 280000, IsOutdoor = true, ManagerId = manager.UserId },

                // Kandy & Cultural Capital
                new() { Name = "Earl's Regency Kandy - Regent Ballroom", LocationAddress = "Tennekumbura, Kandy", MaxCapacity = 700, BaseRentalPrice = 550000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "The Grand Kandyan Hotel - Royal Ballroom", LocationAddress = "89/10 Lady Gordon's Drive, Kandy", MaxCapacity = 800, BaseRentalPrice = 600000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "Mahaweli Reach Hotel - River Lawn", LocationAddress = "35 P.B.A. Weerakoon Mawatha, Kandy", MaxCapacity = 400, BaseRentalPrice = 480000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Amaya Hills Kandy - Eagles Terrace", LocationAddress = "Heerassagala, Kandy", MaxCapacity = 300, BaseRentalPrice = 400000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Citadel Kandy - Riverside Pavilion", LocationAddress = "124 Srimath Kuda Ratwatte Mawatha, Kandy", MaxCapacity = 250, BaseRentalPrice = 380000, IsOutdoor = true, ManagerId = manager.UserId },

                // Down South & Coastal Venues
                new() { Name = "Jetwing Lighthouse Galle - Ocean Rocks Lawn", LocationAddress = "Dadella, Galle", MaxCapacity = 450, BaseRentalPrice = 620000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Heritance Ahungalla - Coconut Grove Lawn", LocationAddress = "Galle Road, Ahungalla", MaxCapacity = 500, BaseRentalPrice = 550000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Bentota Beach - Estuary Grand Lawn", LocationAddress = "Bentota Coastal Strip", MaxCapacity = 600, BaseRentalPrice = 680000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Weligama Bay Marriott Resort - Sunset Ballroom", LocationAddress = "700 Matara Road, Weligama", MaxCapacity = 550, BaseRentalPrice = 720000, IsOutdoor = false, ManagerId = manager.UserId },
                new() { Name = "The Fortress Resort & Spa - Beachfront Lawn", LocationAddress = "Koggala, Galle", MaxCapacity = 250, BaseRentalPrice = 520000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Anantara Peace Haven Tangalle - Cliffside View", LocationAddress = "Goyambokka Estate, Tangalle", MaxCapacity = 300, BaseRentalPrice = 750000, IsOutdoor = true, ManagerId = manager.UserId },

                // Cultural Triangle & North Central
                new() { Name = "Heritance Kandalama - Lakeview Observation Deck", LocationAddress = "Kandalama, Dambulla", MaxCapacity = 350, BaseRentalPrice = 580000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Cinnamon Lodge Habarana - Forest Lawn", LocationAddress = "Habarana", MaxCapacity = 400, BaseRentalPrice = 460000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Jetwing Lake Dambulla - Lakefront Grounds", LocationAddress = "Mirisgonioya, Dambulla", MaxCapacity = 300, BaseRentalPrice = 420000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Aliya Resort & Spa - Sigiriya View Lawn", LocationAddress = "Audangawa, Sigiriya", MaxCapacity = 450, BaseRentalPrice = 500000, IsOutdoor = true, ManagerId = manager.UserId },

                // Negombo & Airport Zone
                new() { Name = "Heritance Negombo - Golden Sands Lawn", LocationAddress = "Lewis Place, Negombo", MaxCapacity = 500, BaseRentalPrice = 540000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Jetwing Blue Negombo - Coastal Pavilion", LocationAddress = "Ethukale, Negombo", MaxCapacity = 400, BaseRentalPrice = 480000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Club Hotel Dolphin - Beachside Arena", LocationAddress = "Waikkal, Negombo", MaxCapacity = 600, BaseRentalPrice = 520000, IsOutdoor = true, ManagerId = manager.UserId },

                // Eastern & Northern Coast
                new() { Name = "Trinqua Blu by Cinnamon - Sandy Beach Arena", LocationAddress = "Sampalthivu Post, Trincomalee", MaxCapacity = 350, BaseRentalPrice = 440000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Jetwing Jaffna - Skyview Terrace", LocationAddress = "37 Mahatma Gandhi Road, Jaffna", MaxCapacity = 200, BaseRentalPrice = 320000, IsOutdoor = true, ManagerId = manager.UserId },
                new() { Name = "Uga Bay Passikudah - Palm Beach Lawn", LocationAddress = "Passikudah Bay, Kalkudah", MaxCapacity = 300, BaseRentalPrice = 560000, IsOutdoor = true, ManagerId = manager.UserId }
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
                    halls.Add(new BanquetHall { VenueId = v.VenueId, HallName = "Mountbatten Pavilion", MaxCapacity = 300, HallRentalPrice = 200000, PerPlatePrice = 4500, IsOutdoor = true });
                }
                else
                {
                    var hallName = v.IsOutdoor ? "Grand Garden Lawn" : "Main Banquet Hall";
                    halls.Add(new BanquetHall 
                    { 
                        VenueId = v.VenueId, 
                        HallName = hallName, 
                        MaxCapacity = v.MaxCapacity, 
                        HallRentalPrice = Math.Min(v.BaseRentalPrice, 300000m), 
                        PerPlatePrice = 5000m, 
                        IsOutdoor = v.IsOutdoor 
                    });
                }
            }

            context.BanquetHalls.AddRange(halls);
            await context.SaveChangesAsync();
        }
    }
}