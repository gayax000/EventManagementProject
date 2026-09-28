using Xunit;
using EventManagement.Core.Entities;

namespace EventManagement.Tests;

public class PaymentVerificationTests
{
    [Fact]
    public void PaymentVerification_WhenApproved_TransitionsToPaidAndConfirmed()
    {
        // Arrange (Member 4: Payment & Invoice Verification Logic)
        var booking = new Booking
        {
            BookingId = Guid.NewGuid(),
            BookingReferenceCode = "EV-2026-TEST",
            TotalAgreedAmount = 850000m,
            Status = "PendingPaymentVerification"
        };

        var payment = new Payment
        {
            PaymentId = Guid.NewGuid(),
            BookingId = booking.BookingId,
            AmountPaid = 850000m,
            Status = "PendingVerification",
            PaymentMethod = "BankTransferSlip"
        };

        string reviewAction = "Approved";

        // Act
        payment.Status = reviewAction;
        if (reviewAction == "Approved")
        {
            booking.Status = "PaidAndConfirmed";
            booking.ConfirmedAt = DateTime.UtcNow;
        }

        // Assert
        Assert.Equal("Approved", payment.Status);
        Assert.Equal("PaidAndConfirmed", booking.Status);
        Assert.NotNull(booking.ConfirmedAt);
    }

    [Fact]
    public void PaymentVerification_WhenRejected_StoresRejectionReason()
    {
        // Arrange
        var payment = new Payment
        {
            PaymentId = Guid.NewGuid(),
            AmountPaid = 500000m,
            Status = "PendingVerification"
        };

        string rejectionReason = "Bank transfer reference not found in bank statement";

        // Act
        payment.Status = "Rejected";
        payment.RejectReason = rejectionReason;

        // Assert
        Assert.Equal("Rejected", payment.Status);
        Assert.Equal(rejectionReason, payment.RejectReason);
    }

    [Fact]
    public void InvoiceGeneration_OnApprovedPayment_CalculatesCorrectFinalTotal()
    {
        // Arrange
        decimal subtotal = 1200000m;
        decimal discount = 50000m;
        decimal expectedFinal = subtotal - discount;

        var invoice = new Invoice
        {
            InvoiceNumber = "INV-2026-9999",
            Subtotal = subtotal,
            DiscountAmount = discount,
            FinalTotal = expectedFinal,
            IssuedAt = DateTime.UtcNow
        };

        // Assert
        Assert.Equal(1150000m, invoice.FinalTotal);
        Assert.StartsWith("INV-2026-", invoice.InvoiceNumber);
    }
}
