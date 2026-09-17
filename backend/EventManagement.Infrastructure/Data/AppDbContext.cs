using EventManagement.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Infrastructure.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    // Member 1 Tables
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Venue> Venues => Set<Venue>();
    public DbSet<BanquetHall> BanquetHalls => Set<BanquetHall>();
    public DbSet<Vendor> Vendors => Set<Vendor>();

    // Member 2 Tables
    public DbSet<Event> Events => Set<Event>();
    public DbSet<Booking> Bookings => Set<Booking>();
    public DbSet<EntryPass> EntryPasses => Set<EntryPass>();

    // Member 3 Tables
    public DbSet<Resource> Resources => Set<Resource>();
    public DbSet<EventResource> EventResources => Set<EventResource>();
    public DbSet<AIWorkflowState> AIWorkflowStates => Set<AIWorkflowState>();

    // Member 4 Tables
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<Invoice> Invoices => Set<Invoice>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // 1. Role Seed Data
        modelBuilder.Entity<Role>().HasData(
            new Role { RoleId = 1, RoleName = "Admin" },
            new Role { RoleId = 2, RoleName = "Manager" },
            new Role { RoleId = 3, RoleName = "Customer" },
            new Role { RoleId = 4, RoleName = "Vendor" }
        );

        // 2. Unique Constraints
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();

        modelBuilder.Entity<Booking>()
            .HasIndex(b => b.BookingReferenceCode)
            .IsUnique();

        modelBuilder.Entity<EntryPass>()
            .HasIndex(ep => ep.QrCodeData)
            .IsUnique();

        modelBuilder.Entity<Invoice>()
            .HasIndex(i => i.InvoiceNumber)
            .IsUnique();

        // 3. PostgreSQL JSONB Mapping for Agentic AI State (Spec LO4 requirement)
        modelBuilder.Entity<AIWorkflowState>(entity =>
        {
            entity.Property(e => e.GeneratedPlanJson).HasColumnType("jsonb");
            entity.Property(e => e.ToolExecutionLogsJson).HasColumnType("jsonb");
            entity.Property(e => e.WeatherAssessmentJson).HasColumnType("jsonb");
        });

        // 4. One-to-One Relationships
        modelBuilder.Entity<Event>()
            .HasOne(e => e.Booking)
            .WithOne(b => b.Event)
            .HasForeignKey<Booking>(b => b.EventId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Event>()
            .HasOne(e => e.AIWorkflowState)
            .WithOne(a => a.Event)
            .HasForeignKey<AIWorkflowState>(a => a.EventId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Booking>()
            .HasOne(b => b.EntryPass)
            .WithOne(ep => ep.Booking)
            .HasForeignKey<EntryPass>(ep => ep.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Venue>()
            .HasMany(v => v.Halls)
            .WithOne(h => h.Venue)
            .HasForeignKey(h => h.VenueId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Event>()
            .HasOne(e => e.BanquetHall)
            .WithMany()
            .HasForeignKey(e => e.BanquetHallId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}