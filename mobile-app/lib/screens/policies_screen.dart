import 'package:flutter/material.dart';

class PoliciesScreen extends StatefulWidget {
  final int initialTabIndex;

  const PoliciesScreen({super.key, this.initialTabIndex = 0});

  /// Opens the policies view as a modern modal bottom sheet
  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.88,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: PoliciesScreen(initialTabIndex: initialTab),
        ),
      ),
    );
  }

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: Color(0xFF38BDF8), size: 22),
            SizedBox(width: 10),
            Text(
              'Legal & App Policies',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: const Color(0xFF38BDF8),
          indicatorWeight: 3,
          labelColor: const Color(0xFF38BDF8),
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.description_outlined, size: 18), text: 'Terms of Service'),
            Tab(icon: Icon(Icons.security_outlined, size: 18), text: 'Privacy Policy'),
            Tab(icon: Icon(Icons.auto_awesome_outlined, size: 18), text: 'AI Safety Policy'),
            Tab(icon: Icon(Icons.currency_exchange_rounded, size: 18), text: 'Refunds & Cancels'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTermsTab(),
          _buildPrivacyTab(),
          _buildAiSafetyTab(),
          _buildRefundsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF090D16),
          border: Border(top: BorderSide(color: Color(0xFF1E293B))),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'I Understand and Agree',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsTab() {
    return _buildContentList([
      _buildSectionHeader('1. Acceptance of Terms', Icons.handshake_outlined),
      _buildParagraph(
        'By registering for, accessing, or utilizing the EventCraft AI platform (including mobile and web applications), '
        'you signify your binding agreement to these Terms of Service. If you do not accept these terms, you must discontinue '
        'use of the platform immediately.',
      ),
      _buildSectionHeader('2. Event Creation & Quotation Workflow', Icons.event_note_outlined),
      _buildParagraph(
        'All automated proposals generated via EventCraft represent initial structural estimates. Official bookings, '
        'vendor disbursements, and resource reservations are finalized only upon explicit Manager Review, Client Digital Signature, '
        'and initial deposit confirmation.',
      ),
      _buildSectionHeader('3. Client Responsibilities', Icons.person_outline),
      _buildParagraph(
        'Clients agree to furnish accurate guest estimates, date preferences, and venue accessibility requirements. '
        'Special requests submitted outside predefined catalog parameters are subject to manual vendor quotation and '
        'operational availability.',
      ),
      _buildSectionHeader('4. Digital Signatures & Legal Enforceability', Icons.draw_outlined),
      _buildParagraph(
        'Digital signature captured through the EventCraft application constitutes a legally binding agreement under applicable '
        'Electronic Transactions legislation, committing both parties to agreed line-item pricing and schedule deliverables.',
      ),
    ]);
  }

  Widget _buildPrivacyTab() {
    return _buildContentList([
      _buildSectionHeader('1. Data Collection & Processing', Icons.data_usage_outlined),
      _buildParagraph(
        'EventCraft collects client contact particulars (full name, email address, telephone contact), event parameters '
        '(dates, attendee counts, guest dietary preferences), and device telemetry strictly necessary for providing event management services.',
      ),
      _buildSectionHeader('2. Payment & Financial Data Protection', Icons.lock_outline),
      _buildParagraph(
        'EventCraft adheres to strict industry payment standards. We do not store raw cardholder data on application servers. '
        'All payment processing is executed via tokenized, encrypted communication channels with certified financial gateways.',
      ),
      _buildSectionHeader('3. Third-Party Vendor Data Sharing', Icons.storefront_outlined),
      _buildParagraph(
        'Approved vendor partners (catering, photography, floral, venue operators) receive only essential operational logistics '
        '(e.g., event venue, headcount, schedule) required to fulfill contract deliverables. Client personal data is never monetized or sold.',
      ),
      _buildSectionHeader('4. Data Retention & Erasure', Icons.delete_outline_rounded),
      _buildParagraph(
        'You retain the right to inspect, update, or request the deletion of your account and personal event records '
        'subject to statutory auditing and accounting record requirements.',
      ),
    ]);
  }

  Widget _buildAiSafetyTab() {
    return _buildContentList([
      _buildHighlightCard(
        title: 'Agentic AI Transparency Guarantee',
        description:
            'EventCraft leverages multi-agent orchestrations (LangGraph) to draft optimized schedules, menu allocations, '
            'and vendor pairings. All AI operations are bounded by rigorous safety policies and human-in-the-loop oversight.',
        icon: Icons.verified_user_outlined,
      ),
      _buildSectionHeader('1. Hard Budget Ceiling Policy', Icons.monetization_on_outlined),
      _buildParagraph(
        'The Autonomous AI Planner is strictly constrained by a zero-overrun policy. Under no condition will the agentic '
        'optimizer recommend vendor packages that exceed your explicitly designated maximum budget ceiling without manual authorization.',
      ),
      _buildSectionHeader('2. Human Manager Supervised Verification', Icons.supervisor_account_outlined),
      _buildParagraph(
        'No AI-generated proposal is finalized autonomously. Certified Event Managers independently review line items, '
        'vendor availability, and venue compliance before issuing the final binding proposal to the client.',
      ),
      _buildSectionHeader('3. Explainability & Resource Disclosures', Icons.lightbulb_outline),
      _buildParagraph(
        'Clients have full visibility into the AI allocation rationale, including per-person catering rates, venue square footage '
        'safety buffers, and line-item tax calculations displayed inside the proposal viewer.',
      ),
    ]);
  }

  Widget _buildRefundsTab() {
    return _buildContentList([
      _buildSectionHeader('1. Deposit & Advance Payments', Icons.payments_outlined),
      _buildParagraph(
        'To secure venue calendar locks and reserve priority vendor dates, clients remit an initial advance payment. '
        'Unconfirmed proposal drafts incur zero financial commitment.',
      ),
      _buildSectionHeader('2. Cancellation Schedule', Icons.schedule_outlined),
      _buildParagraph(
        '• Cancellations made 30+ days prior to event date: 100% refund of refundable advance, minus non-recoverable supplier fees.\n'
        '• Cancellations made 14–29 days prior: 50% refund of total advance payment.\n'
        '• Cancellations made within 14 days: Advance payment is forfeited to compensate booked vendors and staff.',
      ),
      _buildSectionHeader('3. Force Majeure & Weather Rescheduling', Icons.thunderstorm_outlined),
      _buildParagraph(
        'In the event of severe inclement weather or unexpected government regulations, EventCraft provides complimentary '
        'date rescheduling within 6 months, subject to venue calendar availability.',
      ),
    ]);
  }

  Widget _buildContentList(List<Widget> children) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF38BDF8), size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 13.5,
          height: 1.55,
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0369A1).withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF38BDF8), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFE0F2FE),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFFBAE6FD),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
