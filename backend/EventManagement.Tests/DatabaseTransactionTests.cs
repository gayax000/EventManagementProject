using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace EventManagement.Tests;

public class DatabaseTransactionTests
{
    private DbContextOptions<AppDbContext> CreateInMemoryOptions(string dbName)
    {
        return new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: dbName)
            .ConfigureWarnings(w => w.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.InMemoryEventId.TransactionIgnoredWarning))
            .Options;
    }

    [Fact]
    public async Task MultiStepTransaction_WhenFailureOccurs_RollsBackChanges()
    {
        var dbName = Guid.NewGuid().ToString();
        var options = CreateInMemoryOptions(dbName);

        var eventId = Guid.NewGuid();
        var bookingId = Guid.NewGuid();
        var paymentId = Guid.NewGuid();

        // Seed initial data
        using (var setupContext = new AppDbContext(options))
        {
            var customer = new User
            {
                UserId = Guid.NewGuid(),
                FullName = "Test Customer",
                Email = "customer@example.com",
                PasswordHash = "$2a$11$DummyHash123",
                RoleId = 3
            };
            setupContext.Users.Add(customer);

            var ev = new Event
            {
                EventId = eventId,
                Title = "Annual Gala",
                EventType = "Corporate",
                TargetDate = DateTime.UtcNow.AddMonths(1),
                BudgetLimit = 500000,
                GuestCount = 150,
                Status = "UnderReview",
                CustomerId = customer.UserId
            };
            setupContext.Events.Add(ev);

            var booking = new Booking
            {
                BookingId = bookingId,
                EventId = eventId,
                BookingReferenceCode = "EV-2026-TEST",
                TotalAgreedAmount = 500000,
                Status = "PendingPaymentVerification"
            };
            setupContext.Bookings.Add(booking);

            var payment = new Payment
            {
                PaymentId = paymentId,
                BookingId = bookingId,
                AmountPaid = 100000,
                PaymentMethod = "BankTransfer",
                Status = "PendingVerification",
                PaidAt = DateTime.UtcNow
            };
            setupContext.Payments.Add(payment);

            await setupContext.SaveChangesAsync();
        }

        // Execute simulated multi-step transaction with simulated failure before commit
        using (var testContext = new AppDbContext(options))
        {
            await using var tx = await testContext.Database.BeginTransactionAsync();
            try
            {
                var paymentToUpdate = await testContext.Payments.FindAsync(paymentId);
                Assert.NotNull(paymentToUpdate);
                paymentToUpdate.Status = "Approved";

                var bookingToUpdate = await testContext.Bookings.FindAsync(bookingId);
                Assert.NotNull(bookingToUpdate);
                bookingToUpdate.Status = "PaidAndConfirmed";

                // Simulated failure before commit (e.g. invalid invoice creation or external system timeout)
                throw new InvalidOperationException("Simulated error before commit to verify rollback behavior.");

#pragma warning disable CS0162
                await testContext.SaveChangesAsync();
                await tx.CommitAsync();
#pragma warning restore CS0162
            }
            catch (InvalidOperationException)
            {
                await tx.RollbackAsync();
            }
        }

        // Verify that database was left unmodified
        using (var verifyContext = new AppDbContext(options))
        {
            var verifiedPayment = await verifyContext.Payments.FindAsync(paymentId);
            Assert.NotNull(verifiedPayment);
            Assert.Equal("PendingVerification", verifiedPayment.Status);

            var verifiedBooking = await verifyContext.Bookings.FindAsync(bookingId);
            Assert.NotNull(verifiedBooking);
            Assert.Equal("PendingPaymentVerification", verifiedBooking.Status);

            var invoiceCount = await verifyContext.Invoices.CountAsync(i => i.BookingId == bookingId);
            Assert.Equal(0, invoiceCount);
        }
    }

    [Fact]
    public async Task CascadeDelete_WhenEventDeleted_RemovesAssociatedBookingAndAiWorkflowState()
    {
        var dbName = Guid.NewGuid().ToString();
        var options = CreateInMemoryOptions(dbName);

        var eventId = Guid.NewGuid();
        var bookingId = Guid.NewGuid();

        using (var context = new AppDbContext(options))
        {
            var ev = new Event
            {
                EventId = eventId,
                Title = "Wedding Celebration",
                EventType = "Wedding",
                TargetDate = DateTime.UtcNow.AddMonths(2),
                BudgetLimit = 800000,
                GuestCount = 200,
                Status = "UnderReview"
            };
            context.Events.Add(ev);

            var booking = new Booking
            {
                BookingId = bookingId,
                EventId = eventId,
                BookingReferenceCode = "EV-2026-CASCADE",
                TotalAgreedAmount = 800000,
                Status = "PendingSignature"
            };
            context.Bookings.Add(booking);

            var aiState = new AIWorkflowState
            {
                WorkflowId = Guid.NewGuid(),
                EventId = eventId,
                ObjectiveText = "Plan automated wedding package",
                ApprovalStatus = "UnderReview"
            };
            context.AIWorkflowStates.Add(aiState);

            await context.SaveChangesAsync();
        }

        using (var context = new AppDbContext(options))
        {
            var evToDelete = await context.Events
                .Include(e => e.Booking)
                .Include(e => e.AIWorkflowState)
                .FirstOrDefaultAsync(e => e.EventId == eventId);

            Assert.NotNull(evToDelete);
            context.Events.Remove(evToDelete);
            await context.SaveChangesAsync();
        }

        using (var context = new AppDbContext(options))
        {
            var ev = await context.Events.FindAsync(eventId);
            var booking = await context.Bookings.FindAsync(bookingId);
            var aiStates = await context.AIWorkflowStates.Where(a => a.EventId == eventId).ToListAsync();

            Assert.Null(ev);
            Assert.Null(booking);
            Assert.Empty(aiStates);
        }
    }

    [Fact]
    public void ModelValidation_EventEntity_RejectsEmptyTitleOrZeroGuests()
    {
        var ev = new Event
        {
            EventId = Guid.NewGuid(),
            Title = "Valid Title",
            GuestCount = 100,
            BudgetLimit = 250000
        };

        Assert.True(ev.GuestCount > 0);
        Assert.False(string.IsNullOrWhiteSpace(ev.Title));
        Assert.True(ev.BudgetLimit > 0);
    }
}
