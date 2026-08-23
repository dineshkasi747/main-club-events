import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/app_state.dart';
import '../models/event.dart';
import '../models/registration.dart';

class SpheronixRegistrationScreen extends StatefulWidget {
  final Event event;

  const SpheronixRegistrationScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<SpheronixRegistrationScreen> createState() => _SpheronixRegistrationScreenState();
}

class _SpheronixRegistrationScreenState extends State<SpheronixRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _rollNumberController;
  late TextEditingController _fullNameController;
  late TextEditingController _currentYearController;
  late TextEditingController _branchController;
  late TextEditingController _collegeNameController;
  late TextEditingController _emailController;
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final List<TextEditingController> _inviteControllers = List.generate(4, (_) => TextEditingController());
  int _teamMembersCount = 2;

  String _selectedDomain = 'Full Stack Applications';
  String _selectedMode = 'Team';
  bool _isSubmitting = false;
  late Razorpay _razorpay;
  String _lastOrderId = '';

  final List<String> _domains = [
    'Bug Hunt',
    'Full Stack Applications',
    'Native Apps',
    'Ideathon'
  ];

  final List<String> _modes = [
    'Individual',
    'Team'
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.user ?? {};

    _rollNumberController = TextEditingController(text: user['rollNumber'] ?? '324108883001');
    _fullNameController = TextEditingController(text: user['name'] ?? 'Student');
    _currentYearController = TextEditingController(text: user['year'] ?? '3rd year');
    _branchController = TextEditingController(text: user['branch'] ?? 'CSE');
    _collegeNameController = TextEditingController(text: 'Gayatri Vidya Parishad College of Engineering (Autonomous)');
    _emailController = TextEditingController(text: user['email'] ?? 'student@gvpce.ac.in');

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _rollNumberController.dispose();
    _fullNameController.dispose();
    _currentYearController.dispose();
    _branchController.dispose();
    _collegeNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _teamNameController.dispose();
    for (var controller in _inviteControllers) {
      controller.dispose();
    }
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isSubmitting = true);
    
    final orderId = response.orderId ?? _lastOrderId;
    final paymentId = response.paymentId ?? '';
    final signature = response.signature ?? '';

    final appState = Provider.of<AppState>(context, listen: false);
    final List<String> invites = [];
    if (_selectedMode == 'Team') {
      for (int i = 0; i < _teamMembersCount - 1; i++) {
        final text = _inviteControllers[i].text.trim();
        if (text.isNotEmpty) invites.add(text);
      }
    }

    final success = await appState.verifyRazorpayPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
      eventId: widget.event.id,
      paymentMethod: _selectedPaymentMethod,
      extraFields: {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'contact': _mobileController.text.trim(),
        'rollNumber': _rollNumberController.text.trim(),
        'branch': _branchController.text.trim(),
        'currentYear': _currentYearController.text.trim(),
        'collegeName': _collegeNameController.text.trim(),
        'domain': _selectedDomain,
        'mode': _selectedMode,
        'teamName': _selectedMode == 'Team' ? _teamNameController.text.trim() : '',
        'invites': invites,
      },
    );
    
    setState(() => _isSubmitting = false);
    
    if (success) {
      _showTicketConfirmationModal(paymentId, orderId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verification failed. Please try again.')),
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
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  String _selectedPaymentMethod = 'Razorpay UPI Intent';

  Future<void> _registerTeamAndSendInvites() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_teamNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a team name.')),
      );
      return;
    }

    List<String> invites = [];
    for (int i = 0; i < _teamMembersCount - 1; i++) {
      final input = _inviteControllers[i].text.trim();
      if (input.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all team member roll numbers/emails.')),
        );
        return;
      }
      invites.add(input);
    }

    setState(() => _isSubmitting = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.registerForEvent(
      eventId: widget.event.id,
      type: 'participant',
      regMode: 'Team',
      extraFields: {
        'teamName': _teamNameController.text.trim(),
        'invites': invites,
        'domain': _selectedDomain,
        'fullName': _fullNameController.text.trim(),
        'rollNumber': _rollNumberController.text.trim(),
        'branch': _branchController.text.trim(),
        'collegeName': _collegeNameController.text.trim(),
        'mobileNumber': _mobileController.text.trim(),
      },
    );

    setState(() => _isSubmitting = false);

    if (success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Team Invitations Sent!', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Your team has been registered in pending state, and invitation emails have been dispatched to your team members.\n\nOnce all members accept their invites, you can finalize the payment on your bookings page to get your tickets.',
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
        const SnackBar(content: Text('Failed to register team. Please try again.')),
      );
    }
  }

  Future<void> _showRazorpayPaymentModal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    setState(() => _isSubmitting = true);

    final double finalAmount = _selectedMode == 'Team' ? (widget.event.price * _teamMembersCount) : widget.event.price;
    final orderData = await appState.createRazorpayOrder(
      amount: finalAmount,
      eventId: widget.event.id,
    );

    setState(() => _isSubmitting = false);

    final priceText = '₹${finalAmount.toStringAsFixed(0)}';
    final razorpayOrderId = orderData?['order_id'] ?? ('order_sph_' + DateTime.now().millisecondsSinceEpoch.toString().substring(5));
    final razorpayKey = orderData?['key'] ?? 'rzp_test_TSKYJjtfjh7sGM';

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C2340),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.payment, color: Color(0xFF00C853), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Razorpay Payment Intent',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0C2340)),
                              ),
                              Text(
                                'Spheronix Technology PVT LTD',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Amount Payable:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            Text(priceText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF059669))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Razorpay Order ID:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(razorpayOrderId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Payment Mode (UPI / Bank Account)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildPaymentOptionItem(
                    icon: Icons.qr_code_scanner,
                    title: 'UPI Payment Intent',
                    subtitle: 'GPay, PhonePe, Paytm, BHIM or any UPI App',
                    color: Colors.purple,
                    isSelected: _selectedPaymentMethod == 'Razorpay UPI Intent',
                    onTap: () => setModalState(() => _selectedPaymentMethod = 'Razorpay UPI Intent'),
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOptionItem(
                    icon: Icons.account_balance,
                    title: 'Bank Account / NetBanking Intent',
                    subtitle: 'SBI, HDFC, ICICI, Axis & Indian Banks',
                    color: Colors.teal,
                    isSelected: _selectedPaymentMethod == 'Razorpay Bank Account',
                    onTap: () => setModalState(() => _selectedPaymentMethod = 'Razorpay Bank Account'),
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOptionItem(
                    icon: Icons.credit_card,
                    title: 'Cards & Corporate Gateway',
                    subtitle: 'Visa, Mastercard, RuPay & Corporate NetBanking',
                    color: Colors.blue,
                    isSelected: _selectedPaymentMethod == 'Razorpay Card Intent',
                    onTap: () => setModalState(() => _selectedPaymentMethod = 'Razorpay Card Intent'),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _launchRazorpayCheckout(orderData!, razorpayOrderId, razorpayKey);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: Text(
                      'Pay $priceText via $_selectedPaymentMethod',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text('256-bit SSL Encrypted Razorpay Gateway', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : const Color(0xFFCBD5E1), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? color : Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _launchRazorpayCheckout(Map<String, dynamic> orderData, String razorpayOrderId, String razorpayKey) async {
    _lastOrderId = razorpayOrderId;
    
    final int amountInPaise = int.parse((orderData['amount'] ?? (widget.event.price * 100).toInt()).toString());

    final options = {
      'key': razorpayKey,
      'amount': 100, // Forced to 1 Rupee (100 paise) for transaction testing
      'name': 'GVP College Portal',
      'description': widget.event.title,
      'order_id': razorpayOrderId,
      'currency': 'INR',
      'prefill': {
        'contact': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Razorpay checkout: $e')),
      );
    }
  }

  void _showTicketConfirmationModal(String razorpayPaymentId, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFFEF3C7),
                child: Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706), size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Intent Completed!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: const Text(
                  'STATUS: PENDING ADMIN APPROVAL',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your payment intent has been processed. Your registration will be authorized by the Admin in the dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 130,
                      width: 130,
                      child: QrImageView(
                        data: 'SPHERONIX-2026-${_rollNumberController.text}-$razorpayPaymentId',
                        version: QrVersions.auto,
                        size: 130,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Payment ID: $razorpayPaymentId',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                    Text(
                      'Order ID: $orderId',
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Domain: $_selectedDomain | Mode: $_selectedMode',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Spheronix Hackathon Registration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing Razorpay Payment & Updating Dataset...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '8-HOUR INTERNATIONAL HACKATHON',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Spheronix Technology Hackathon 2026',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Prize Pool: ₹2,00,000 - ₹5,00,000 | Organized with Spheronix PVT LTD',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Student & Hackathon Registration Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 14),

                    _buildTextField(_rollNumberController, 'Roll Number *', 'e.g. 324108883001'),
                    const SizedBox(height: 14),

                    _buildTextField(_fullNameController, 'Full Name *', 'e.g. Teja K.'),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(child: _buildTextField(_currentYearController, 'Current Year *', 'e.g. 3rd year')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_branchController, 'Branch *', 'e.g. CSE with Data Science')),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildTextField(_collegeNameController, 'College Name *', 'Full College Name'),
                    const SizedBox(height: 14),

                    _buildTextField(_emailController, 'Gmail / Email Address *', 'student@gvpce.ac.in', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),

                    _buildTextField(_mobileController, 'Mobile Number *', 'Enter 10-digit phone number', keyboardType: TextInputType.phone, isRequired: true),
                    const SizedBox(height: 18),

                    // Domain Dropdown
                    const Text('Select Focus Domain *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedDomain,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                      items: _domains.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDomain = val);
                      },
                    ),
                    const SizedBox(height: 18),

                    // Mode Dropdown
                    const Text('Registration Mode *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedMode,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                      items: _modes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMode = val);
                      },
                    ),
                    const SizedBox(height: 18),

                    if (_selectedMode == 'Team') ...[
                      _buildTextField(_teamNameController, 'Team Name *', 'e.g. CodeCraft Squad', isRequired: true),
                      const SizedBox(height: 18),
                      const Text('Total Team Members (including Leader) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: _teamMembersCount,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        ),
                        items: [2, 3, 4, 5].map((c) => DropdownMenuItem(value: c, child: Text('$c Members'))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _teamMembersCount = val);
                        },
                      ),
                      const SizedBox(height: 18),
                      for (int i = 0; i < _teamMembersCount - 1; i++) ...[
                        _buildTextField(
                          _inviteControllers[i],
                          'Team Member ${i + 2} Roll Number / Email *',
                          'e.g. 22CSE108${i + 5}',
                          isRequired: true,
                          onSearch: () async {
                            final query = _inviteControllers[i].text.trim();
                            if (query.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a roll number or email to search.')),
                              );
                              return;
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Searching student database...')),
                            );

                            final appState = Provider.of<AppState>(context, listen: false);
                            final result = await appState.searchUser(query);
                            
                            if (!mounted) return;
                            
                            if (result != null && result['exists'] == true) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Student Found!', style: TextStyle(fontWeight: FontWeight.bold)),
                                  content: Text(
                                    'Name: ${result['name']}\nEmail: ${result['email']}\nRoll Number: ${result['rollNumber']}\nBranch: ${result['branch']}',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Student not found in database. Entering their email directly is allowed; they will receive an invitation to register.')),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                      ],
                    ],

                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _selectedMode == 'Team' ? _registerTeamAndSendInvites : _showRazorpayPaymentModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                      child: Text(
                        _selectedMode == 'Team'
                            ? 'Register & Send Team Invitations'
                            : 'Pay & Register (₹${widget.event.price.toStringAsFixed(0)})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    VoidCallback? onSearch,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (val) {
            if (isRequired && (val == null || val.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            suffixIcon: onSearch != null
                ? IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF0284C7)),
                    onPressed: onSearch,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
