import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/registration.dart';
import '../providers/app_state.dart';

class PendingTeamPaymentScreen extends StatefulWidget {
  final Registration booking;

  const PendingTeamPaymentScreen({super.key, required this.booking});

  @override
  State<PendingTeamPaymentScreen> createState() => _PendingTeamPaymentScreenState();
}

class _PendingTeamPaymentScreenState extends State<PendingTeamPaymentScreen> {
  late Razorpay _razorpay;
  List<dynamic> _invitations = [];
  bool _isLoadingInvites = true;
  bool _isPaying = false;
  String _selectedPaymentMethod = 'Razorpay UPI Intent';
  String _lastOrderId = '';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadInvitations();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoadingInvites = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final invites = await appState.fetchSentInvitations(widget.booking.eventId);
    setState(() {
      _invitations = invites;
      _isLoadingInvites = false;
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isPaying = true);
    final appState = Provider.of<AppState>(context, listen: false);
    final orderId = response.orderId ?? _lastOrderId;
    final paymentId = response.paymentId ?? '';
    final signature = response.signature ?? '';

    final success = await appState.verifyRazorpayPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
      eventId: widget.booking.eventId,
      paymentMethod: _selectedPaymentMethod,
      extraFields: {
        'registrationId': widget.booking.id,
        'teamName': widget.booking.teamName,
      },
    );

    setState(() => _isPaying = false);

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Payment Complete!', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Your payment was verified successfully and your team registration is now approved!\n\nTickets have been generated for you and all team members.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verification failed. Please contact support.')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message ?? "User cancelled"}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet selected: ${response.walletName}')),
    );
  }

  Future<void> _startCheckout() async {
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() => _isPaying = true);

    final orderData = await appState.createRazorpayOrder(
      amount: widget.booking.eventPrice,
      eventId: widget.booking.eventId,
    );

    setState(() => _isPaying = false);

    if (orderData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not initiate payment order. Please try again.')),
      );
      return;
    }

    final razorpayOrderId = orderData['order_id'] ?? '';
    final razorpayKey = orderData['key'] ?? '';
    _lastOrderId = razorpayOrderId;

    final options = {
      'key': razorpayKey,
      'amount': (widget.booking.eventPrice * 100).toInt(),
      'name': 'CampusLink Portal',
      'description': 'Payment for ${widget.booking.eventTitle}',
      'order_id': razorpayOrderId,
      'prefill': {
        'contact': '9876543210',
        'email': appState.user?['email'] ?? 'student@gvpce.ac.in'
      },
      'theme': {
        'color': '#6366f1'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching payment SDK: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userEmail = appState.user?['email'] ?? '';
    final isLeader = (widget.booking.teamLeaderEmail != null &&
        widget.booking.teamLeaderEmail!.toLowerCase() == userEmail.toLowerCase());

    bool allAccepted = _invitations.isNotEmpty;
    for (var invite in _invitations) {
      if (invite['status'] != 'accepted') {
        allAccepted = false;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Team Details & Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvitations,
          )
        ],
      ),
      body: _isPaying
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366f1))),
                  SizedBox(height: 16),
                  Text('Processing checkout... Please wait', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.booking.eventTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(widget.booking.eventVenue, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(widget.booking.eventDate, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Team info
                  const Text('Team Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Team Name', widget.booking.teamName ?? 'Unnamed Team'),
                        _infoRow('Team Leader', widget.booking.teamLeaderEmail ?? 'N/A'),
                        _infoRow('Status', widget.booking.status.toUpperCase(), isStatus: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Invitations list
                  const Text('Invited Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  if (_isLoadingInvites)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_invitations.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text(
                          'No invitations found.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _invitations.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final invite = _invitations[index];
                          final email = invite['inviteeEmail'] as String;
                          final status = invite['status'] as String;

                          Color badgeColor = const Color(0xFFFEF3C7);
                          Color textBadgeColor = const Color(0xFFB45309);
                          if (status == 'accepted') {
                            badgeColor = const Color(0xFFD1FAE5);
                            textBadgeColor = const Color(0xFF047857);
                          } else if (status == 'declined') {
                            badgeColor = const Color(0xFFFEE2E2);
                            textBadgeColor = const Color(0xFFDC2626);
                          }

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            title: Text(email, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textBadgeColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Checkout Action Section
                  if (isLeader) ...[
                    if (allAccepted) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Checkout',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'All members have accepted their invitations. You can now pay for the team registration fee.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            const Divider(height: 24, color: Color(0xFFCBD5E1)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text(
                                  '₹${widget.booking.eventPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF6366f1)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _startCheckout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366f1),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Pay & Finalize Team Registration',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: Color(0xFFD97706), size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Waiting for all team members to accept the email invitations before checkout opens.',
                                style: TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Color(0xFF2563EB), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Waiting for the team leader (${widget.booking.teamLeaderEmail}) to make the payment.',
                              style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String val, {bool isStatus = false}) {
    Color valColor = const Color(0xFF0F172A);
    if (isStatus) {
      valColor = val == 'APPROVED' ? const Color(0xFF059669) : const Color(0xFFD97706);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(
            val,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }
}
