using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Text;
using System.Web;

namespace EventManagement.Api.Controllers;

/// <summary>
/// Public entry-pass verification page — no authentication required.
/// Hotel/venue staff scan the QR code with any camera → browser opens this page.
/// Route: GET /verify?ref=EV-2026-XXXX
/// </summary>
[ApiController]
[Route("verify")]
public class VerifyController : ControllerBase
{
    private readonly AppDbContext _context;

    public VerifyController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ContentResult> VerifyEntryPass()
    {
        // 'ref' is a C# keyword so read from raw query string
        var bookingRef = Request.Query["ref"].ToString();

        if (string.IsNullOrWhiteSpace(bookingRef))
            return HtmlResult(ErrorPage("No booking reference provided in the QR code."));

        // Look up EntryPass by booking reference code
        var pass = await _context.EntryPasses
            .Include(p => p.Booking)
                .ThenInclude(b => b!.Event)
                    .ThenInclude(e => e!.Customer)
            .Include(p => p.Booking)
                .ThenInclude(b => b!.Event)
                    .ThenInclude(e => e!.Venue)
            .Include(p => p.Booking)
                .ThenInclude(b => b!.Event)
                    .ThenInclude(e => e!.BanquetHall)
            .FirstOrDefaultAsync(p => p.Booking != null && p.Booking.BookingReferenceCode == bookingRef);

        if (pass == null)
            return HtmlResult(ErrorPage($"No entry pass found for booking reference: {HttpUtility.HtmlEncode(bookingRef)}"));

        var ev       = pass.Booking?.Event;
        var booking  = pass.Booking;
        var customer = ev?.Customer;

        // Get invoice
        var invoice = booking != null
            ? await _context.Invoices.FirstOrDefaultAsync(i => i.BookingId == booking.BookingId)
            : null;

        // Selected services
        var services = new List<string>();
        if (!string.IsNullOrEmpty(ev?.SelectedServicesJson))
        {
            try { services = System.Text.Json.JsonSerializer.Deserialize<List<string>>(ev.SelectedServicesJson) ?? new(); }
            catch { /* ignore */ }
        }

        // Mark as scanned if first time
        bool alreadyUsed = pass.IsScanned;
        if (!pass.IsScanned)
        {
            pass.IsScanned = true;
            pass.ScannedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }

        return HtmlResult(BuildVerifyPage(pass, ev, booking, customer, invoice, services, alreadyUsed));
    }

    // ─── HTML Builders ────────────────────────────────────────────────────────

    private static ContentResult HtmlResult(string html)
        => new ContentResult { Content = html, ContentType = "text/html; charset=utf-8", StatusCode = 200 };

    private static string FmtDate(DateTime? d)
        => d.HasValue ? d.Value.ToString("MMMM dd, yyyy") : "—";

    private static string FmtDT(DateTime? d)
        => d.HasValue ? d.Value.ToLocalTime().ToString("MMM dd, yyyy  hh:mm tt") : "—";

    private static string FmtMoney(decimal? v)
        => v.HasValue ? string.Format("LKR {0:N0}", v.Value) : "—";

    private static string H(string? s)
        => string.IsNullOrWhiteSpace(s) ? "—" : HttpUtility.HtmlEncode(s);

    private static string PageShell(string statusColor, string statusBg, string statusBorder,
        string statusEmoji, string statusTitle, string statusSub, string bodyContent)
    {
        var sb = new StringBuilder();
        sb.Append("<!DOCTYPE html><html lang=\"en\"><head>");
        sb.Append("<meta charset=\"UTF-8\"/>");
        sb.Append("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"/>");
        sb.Append("<title>EventCraft — Entry Pass Verification</title>");
        sb.Append("<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">");
        sb.Append("<link href=\"https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap\" rel=\"stylesheet\">");
        sb.Append("<style>");
        sb.Append("*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}");
        sb.Append("body{font-family:'Inter',sans-serif;background:#0f172a;color:#e2e8f0;min-height:100vh;padding-bottom:48px}");
        sb.Append(".hdr{background:linear-gradient(135deg,#1e293b,#0f172a);border-bottom:1px solid #1e293b;padding:18px 20px;display:flex;align-items:center;gap:12px}");
        sb.Append(".hdr-logo{width:40px;height:40px;background:linear-gradient(135deg,#06b6d4,#3b82f6);border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:20px}");
        sb.Append(".hdr-t{font-size:17px;font-weight:700;color:#fff}.hdr-s{font-size:12px;color:#06b6d4;font-weight:500;margin-top:2px}");
        sb.Append(".wrap{max-width:480px;margin:20px auto;padding:0 14px}");
        sb.AppendFormat(".status-card{{background:{0};border:1.5px solid {1};border-radius:16px;padding:26px 20px;text-align:center;margin-bottom:18px;box-shadow:0 0 28px {2}22}}", statusBg, statusBorder, statusColor);
        sb.Append(".s-emoji{font-size:48px;margin-bottom:10px;line-height:1}");
        sb.AppendFormat(".s-title{{font-size:20px;font-weight:800;color:{0};letter-spacing:.3px}}", statusColor);
        sb.AppendFormat(".s-sub{{font-size:13px;color:{0}cc;margin-top:8px;line-height:1.5}}", statusColor);
        sb.Append(".card{background:#1e293b;border:1px solid #334155;border-radius:13px;padding:16px;margin-bottom:12px}");
        sb.Append(".card-lbl{font-size:10px;font-weight:700;letter-spacing:1.2px;color:#64748b;text-transform:uppercase;margin-bottom:10px}");
        sb.Append(".row{display:flex;justify-content:space-between;align-items:flex-start;padding:7px 0;border-bottom:1px solid #0f172a;gap:10px}");
        sb.Append(".row:last-child{border-bottom:none;padding-bottom:0}");
        sb.Append(".rl{font-size:12px;color:#64748b;flex-shrink:0}.rv{font-size:13px;font-weight:600;color:#e2e8f0;text-align:right;word-break:break-word}");
        sb.Append(".cy{color:#22d3ee}.gr{color:#4ade80}.am{color:#fbbf24}.pu{color:#a78bfa}.te{color:#2dd4bf}");
        sb.Append(".chips{display:flex;flex-wrap:wrap;gap:8px;margin-top:4px}");
        sb.Append(".chip{background:rgba(236,72,153,.1);border:1px solid rgba(236,72,153,.35);color:#f472b6;font-size:12px;font-weight:500;padding:5px 12px;border-radius:20px}");
        sb.Append(".foot{text-align:center;margin-top:24px;color:#475569;font-size:11px;line-height:1.7}");
        sb.Append(".pow{display:inline-flex;align-items:center;gap:6px;background:#1e293b;border:1px solid #334155;border-radius:20px;padding:5px 14px;margin-bottom:6px;font-size:11px;color:#94a3b8}");
        sb.Append("</style></head><body>");

        // Header
        sb.Append("<div class=\"hdr\"><div class=\"hdr-logo\">🎪</div><div><div class=\"hdr-t\">EventCraft</div><div class=\"hdr-s\">Entry Pass Verification System</div></div></div>");
        sb.Append("<div class=\"wrap\">");

        // Status card
        sb.Append("<div class=\"status-card\">");
        sb.AppendFormat("<div class=\"s-emoji\">{0}</div>", statusEmoji);
        sb.AppendFormat("<div class=\"s-title\">{0}</div>", statusTitle);
        sb.AppendFormat("<div class=\"s-sub\">{0}</div>", statusSub);
        sb.Append("</div>");

        // Body content
        sb.Append(bodyContent);

        // Footer
        sb.Append("<div class=\"foot\"><div class=\"pow\">🔒 Powered by EventCraft AI Platform</div><br>");
        sb.Append("SE3090 Software Engineering Frameworks &bull; University Project<br>");
        sb.AppendFormat("Verified at: {0} UTC", HttpUtility.HtmlEncode(DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss")));
        sb.Append("</div>");
        sb.Append("</div></body></html>");
        return sb.ToString();
    }

    private static string Row(string label, string value, string cls = "")
        => $"<div class=\"row\"><span class=\"rl\">{HttpUtility.HtmlEncode(label)}</span><span class=\"rv {cls}\">{value}</span></div>";

    private static string Card(string icon, string label, string rows)
        => $"<div class=\"card\"><div class=\"card-lbl\">{icon} {HttpUtility.HtmlEncode(label)}</div>{rows}</div>";

    // ── Error page ────────────────────────────────────────────────────────────

    private static string ErrorPage(string msg)
    {
        return PageShell(
            statusColor: "#ef4444",
            statusBg: "rgba(239,68,68,0.08)",
            statusBorder: "#ef444444",
            statusEmoji: "❌",
            statusTitle: "Invalid QR Code",
            statusSub: HttpUtility.HtmlEncode(msg),
            bodyContent: ""
        );
    }

    // ── Verification page ─────────────────────────────────────────────────────

    private static string BuildVerifyPage(
        EventManagement.Core.Entities.EntryPass pass,
        EventManagement.Core.Entities.Event? ev,
        EventManagement.Core.Entities.Booking? booking,
        EventManagement.Core.Entities.User? customer,
        EventManagement.Core.Entities.Invoice? invoice,
        List<string> services,
        bool alreadyUsed)
    {
        string statusColor = alreadyUsed ? "#f59e0b" : "#22c55e";
        string statusBg    = alreadyUsed ? "rgba(245,158,11,0.08)" : "rgba(34,197,94,0.08)";
        string statusBorder = alreadyUsed ? "#f59e0b44" : "#22c55e44";
        string statusEmoji  = alreadyUsed ? "⚠️" : "✅";
        string statusTitle  = alreadyUsed ? "Pass Already Scanned" : "Entry Cleared";
        string statusSub    = alreadyUsed
            ? $"This pass was previously scanned on {HttpUtility.HtmlEncode(FmtDT(pass.ScannedAt))}."
            : $"Guest verified and cleared for entry. Scanned at {HttpUtility.HtmlEncode(FmtDT(pass.ScannedAt))}.";

        var body = new StringBuilder();

        // Client info
        body.Append(Card("👤", "Client Information",
            Row("Client Name", $"<span class='cy'>{H(customer?.FullName ?? "EventCraft Client")}</span>") +
            (string.IsNullOrWhiteSpace(customer?.PhoneNumber) ? "" :
                Row("Phone", $"<span class='cy'>{H(customer!.PhoneNumber)}</span>"))
        ));

        // Booking details
        body.Append(Card("📋", "Booking Details",
            Row("Booking Ref", $"<span class='am'>{H(booking?.BookingReferenceCode)}</span>") +
            (invoice != null ? Row("Invoice", $"<span class='am'>{H(invoice.InvoiceNumber)}</span>") : "") +
            Row("Total Paid", $"<span class='gr'>{HttpUtility.HtmlEncode(FmtMoney(booking?.TotalAgreedAmount))}</span>") +
            Row("Confirmed On", $"<span class='gr'>{HttpUtility.HtmlEncode(FmtDT(booking?.ConfirmedAt))}</span>")
        ));

        // Event details
        body.Append(Card("🎉", "Event Details",
            Row("Event Name", H(ev?.Title)) +
            Row("Event Type", H(ev?.EventType)) +
            Row("Event Date", $"<span class='pu'>{HttpUtility.HtmlEncode(FmtDate(ev?.TargetDate))}</span>") +
            Row("Guest Count", $"<span class='pu'>{ev?.GuestCount ?? 0} Guests</span>")
        ));

        // Venue
        body.Append(Card("📍", "Venue & Hall",
            Row("Venue", $"<span class='te'>{H(ev?.Venue?.Name ?? "EventCraft Venue")}</span>") +
            (ev?.BanquetHall != null ? Row("Hall / Lawn", $"<span class='te'>{H(ev.BanquetHall.HallName)}</span>") : "")
        ));

        // Services
        if (services.Count > 0)
        {
            var chips = new StringBuilder();
            chips.Append("<div class=\"chips\">");
            foreach (var s in services)
                chips.Append($"<span class=\"chip\">{HttpUtility.HtmlEncode(s)}</span>");
            chips.Append("</div>");
            body.Append(Card("🌸", "Booked Services", chips.ToString()));
        }

        return PageShell(statusColor, statusBg, statusBorder, statusEmoji, statusTitle, statusSub, body.ToString());
    }
}
