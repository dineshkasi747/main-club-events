import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/app_state.dart';
import '../widgets/premium_image.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isActionRunning = false;

  void _registerFree() async {
    setState(() {
      _isActionRunning = true;
    });

    final success = await Provider.of<AppState>(context, listen: false).registerForEvent(
      eventId: widget.event.id,
      type: 'participant',
      paymentMethod: 'free',
      transactionId: 'FREE_REG',
    );

    setState(() {
      _isActionRunning = false;
    });

    if (success) {
      _showSuccessDialog('Registration Successful!', 'You have secured a ticket for ${widget.event.title}.');
    } else {
      _showErrorSnackBar('Registration failed. Already registered or full.');
    }
  }

  void _registerVolunteer() async {
    setState(() {
      _isActionRunning = true;
    });

    final success = await Provider.of<AppState>(context, listen: false).registerForEvent(
      eventId: widget.event.id,
      type: 'volunteer',
      paymentMethod: 'free',
      transactionId: 'VOLUNTEER_REG',
    );

    setState(() {
      _isActionRunning = false;
    });

    if (success) {
      _showSuccessDialog('Volunteer Registered!', 'Thank you for volunteering! Your spot is confirmed.');
    } else {
      _showErrorSnackBar('Volunteering spots are full or you are already registered.');
    }
  }

  void _showPaymentSheet() {
    String selectedMethod = 'Card';
    final cardHolderController = TextEditingController(text: 'Teja K.');
    final cardNumberController = TextEditingController(text: '4111 2222 3333 4444');
    final upiIdController = TextEditingController(text: 'student@ybl');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Secure Payment Gateway',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount to Pay:', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                        Text(
                          '₹${widget.event.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Method Selection
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Credit Card'),
                          selected: selectedMethod == 'Card',
                          selectedColor: const Color(0xFFE0E7FF),
                          labelStyle: TextStyle(
                            color: selectedMethod == 'Card' ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                selectedMethod = 'Card';
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('PhonePe / UPI'),
                          selected: selectedMethod == 'UPI',
                          selectedColor: const Color(0xFFE0E7FF),
                          labelStyle: TextStyle(
                            color: selectedMethod == 'UPI' ? const Color(0xFF4F46E5) : const Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                selectedMethod = 'UPI';
                              });
                            }
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (selectedMethod == 'Card') ...[
                    TextField(
                      controller: cardHolderController,
                      decoration: const InputDecoration(
                        labelText: 'Cardholder Name',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        prefixIcon: Icon(Icons.credit_card, size: 20),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: upiIdController,
                      decoration: const InputDecoration(
                        labelText: 'Enter UPI ID',
                        prefixIcon: Icon(Icons.phone_iphone, size: 20),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // Close bottom sheet
                      setState(() {
                        _isActionRunning = true;
                      });

                      final randomTxn = 'TXN${Random().nextInt(90000000) + 10000000}';
                      
                      final success = await Provider.of<AppState>(context, listen: false).registerForEvent(
                        eventId: widget.event.id,
                        type: 'participant',
                        paymentMethod: selectedMethod,
                        transactionId: randomTxn,
                      );

                      setState(() {
                        _isActionRunning = false;
                      });

                      if (success) {
                        _showSuccessDialog(
                          'Payment Submitted!',
                          'Your booking payment has been submitted for verification. It will show in bookings as "PENDING" until approved by the club president.',
                        );
                      } else {
                        _showErrorSnackBar('Booking failed. Already registered.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Submit Transaction for Verification', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: Text(content, style: const TextStyle(color: Color(0xFF475569))),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop details page back to home
            },
            child: const Text('View Ticket Roster', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    // Count current volunteers for this event
    final volCount = appState.bookings.where((r) => r.eventId == widget.event.id && r.type == 'volunteer').length;
    final volunteerSpotsLeft = max(0, widget.event.volunteerLimit - volCount);

    final isAlreadyRegistered = appState.bookings.any((r) => r.eventId == widget.event.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Event Registration', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: _isActionRunning
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : ListView(
              children: [
                PremiumImage(
                  url: widget.event.imagePath,
                  category: widget.event.category,
                  height: 200,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header details
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.event.price > 0 ? '₹${widget.event.price.toStringAsFixed(2)}' : 'FREE ENTRY',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                            ),
                          ),
                          const Spacer(),
                          if (widget.event.volunteerRegistration)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                              ),
                              child: Text(
                                'Volunteers Wanted ($volunteerSpotsLeft left)',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.event.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 16),

                      // Location & Date cards
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF4F46E5), size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Venue Place', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                      const SizedBox(height: 2),
                                      Text(widget.event.venue, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const Divider(height: 24, color: Color(0xFFF1F5F9)),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Color(0xFF4F46E5), size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Scheduled Timing', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                      const SizedBox(height: 2),
                                      Text(widget.event.dateString, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'About the Event',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.event.description,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.6),
                      ),
                      const SizedBox(height: 40),

                      // Registration controls
                      if (isAlreadyRegistered)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF047857)),
                              SizedBox(width: 8),
                              Text(
                                'You are registered for this event',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                              )
                            ],
                          ),
                        )
                      else ...[
                        if (widget.event.price > 0) ...[
                          ElevatedButton(
                            onPressed: _showPaymentSheet,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Buy Ticket (₹${widget.event.price.toStringAsFixed(0)})',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ] else if (widget.event.volunteerRegistration) ...[
                          ElevatedButton(
                            onPressed: volunteerSpotsLeft > 0 ? _registerVolunteer : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF047857),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: Text(
                              volunteerSpotsLeft > 0
                                  ? 'Register as Event Volunteer ($volunteerSpotsLeft left)'
                                  : 'Volunteering Spots Full',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ] else ...[
                          ElevatedButton(
                            onPressed: _registerFree,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Register for Free Entry',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ]
                      ]
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
