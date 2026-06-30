import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/registration.dart';

class TicketScreen extends StatelessWidget {
  final Registration booking;

  const TicketScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    if (booking.status == 'approved') {
      statusColor = const Color(0xFF047857);
      statusBg = const Color(0xFFD1FAE5);
    } else if (booking.status == 'attended') {
      statusColor = const Color(0xFF4F46E5);
      statusBg = const Color(0xFFE0E7FF);
    } else {
      statusColor = const Color(0xFFB45309);
      statusBg = const Color(0xFFFEF3C7);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate background
      appBar: AppBar(
        title: const Text('Entry Ticket', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ticket Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4F46E5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        booking.eventTitle.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Booking ID: #${booking.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ticket Details Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailBlock('VENUE PLACE', booking.eventVenue),
                      const SizedBox(height: 18),
                      _detailBlock('SCHEDULE DATE & TIME', booking.eventDate),
                      const SizedBox(height: 18),
                      
                      const Divider(color: Color(0xFFE2E8F0), height: 16),
                      const SizedBox(height: 8),

                      _detailRow('Student Name', booking.userName),
                      _detailRow('Roll Number', booking.userRollNumber),
                      _detailRow('Branch Name', booking.userBranch),
                      _detailRow('Graduation Year', '${booking.userYearOfPassing}'),
                      _detailRow('Booking Type', booking.type.toUpperCase()),
                      
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE2E8F0), height: 16),
                      const SizedBox(height: 16),

                      // Status Indicator Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            booking.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Verification instructions or QR code
                      Center(
                        child: Column(
                          children: [
                            if (booking.status == 'pending') ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFF59E0B)),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.hourglass_empty, color: Color(0xFFD97706), size: 28),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Payment Verification Pending',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309), fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Transaction Ref: ${booking.upiRefId.isNotEmpty ? booking.upiRefId : booking.transactionId}',
                                      style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'The club president will verify your UPI transaction ID shortly and approve your ticket.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(0xFFB45309), fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: QrImageView(
                                  data: '${booking.id}',
                                  version: QrVersions.auto,
                                  size: 150.0,
                                  gapless: false,
                                  errorStateBuilder: (cxt, err) {
                                    return const Center(child: Text("Error generating QR"));
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Present QR code at entry gate to gain admission.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              )
                            ],
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        )
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
