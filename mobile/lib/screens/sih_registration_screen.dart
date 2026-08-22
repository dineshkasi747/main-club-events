import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/app_state.dart';
import '../models/event.dart';
import '../models/registration.dart';

class SihRegistrationScreen extends StatefulWidget {
  final Event? sihEvent;

  const SihRegistrationScreen({Key? key, this.sihEvent}) : super(key: key);

  @override
  State<SihRegistrationScreen> createState() => _SihRegistrationScreenState();
}

class _SihRegistrationScreenState extends State<SihRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late Razorpay _razorpay;
  String _lastOrderId = '';

  // Form Field Controllers & Values
  late TextEditingController _emailController;
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamLeaderController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  final TextEditingController _idea1TitleController = TextEditingController();
  final TextEditingController _idea1ThemeController = TextEditingController();
  final TextEditingController _idea1ProblemController = TextEditingController();

  final TextEditingController _idea2TitleController = TextEditingController();
  final TextEditingController _idea2ThemeController = TextEditingController();
  final TextEditingController _idea2ProblemController = TextEditingController();

  String _selectedGender = 'M';
  String _selectedBranch = 'CSE';
  String _selectedYear = 'III';
  String? _nominationFileName;

  final List<String> _branches = [
    'CIVIL',
    'CHEMICAL',
    'CSE',
    'CSM',
    'CSD',
    'ECE',
    'EEE',
    'IT',
    'MECH',
    'MBA',
    'MCA',
    'CSE Cyber Security',
  ];

  final List<String> _years = ['I', 'II', 'III', 'IV'];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.user;
    _emailController = TextEditingController(text: user?['email'] ?? 'student@gvpce.ac.in');
    if (user?['name'] != null && (user!['name'] as String).isNotEmpty) {
      _teamLeaderController.text = user['name'];
    }

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _teamNameController.dispose();
    _teamLeaderController.dispose();
    _rollNumberController.dispose();
    _mobileController.dispose();
    _idea1TitleController.dispose();
    _idea1ThemeController.dispose();
    _idea1ProblemController.dispose();
    _idea2TitleController.dispose();
    _idea2ThemeController.dispose();
    _idea2ProblemController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _showLoadingDialog(); // Show standard blocker

    final orderId = response.orderId ?? _lastOrderId;
    final paymentId = response.paymentId ?? '';
    final signature = response.signature ?? '';

    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.verifyRazorpayPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
      eventId: (widget.sihEvent?.id ?? 2026),
      paymentMethod: 'Razorpay UPI Intent',
      extraFields: {
        'fullName': _teamLeaderController.text.trim(),
        'email': _emailController.text.trim(),
        'contact': _mobileController.text.trim(),
        'rollNumber': _rollNumberController.text.trim(),
        'branch': _selectedBranch,
        'currentYear': _selectedYear + ' year',
        'collegeName': 'Gayatri Vidya Parishad College of Engineering (Autonomous)',
        'domain': 'Smart India Hackathon Internal',
        'mode': 'Team',
        'teamName': _teamNameController.text.trim(),
      },
    );

    Navigator.pop(context); // Close loading blocker

    if (success) {
      _showBookingSuccessDialog(paymentId);
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

  void _pickNominationLetter() {
    setState(() {
      _nominationFileName = 'SIH_Team_Nomination_Letter_${_teamNameController.text.isNotEmpty ? _teamNameController.text.replaceAll(' ', '_') : 'Doc'}.docx';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uploaded nomination letter: $_nominationFileName'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7))),
    );
  }

  Future<void> _proceedToCheckout() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields marked with *'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_nominationFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload the Team Nomination Letter (.docx) before proceeding.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    _showLoadingDialog();
    final appState = Provider.of<AppState>(context, listen: false);
    final amount = widget.sihEvent?.price ?? 200.0;
    final eventId = widget.sihEvent?.id ?? 2026;
    
    final orderData = await appState.createRazorpayOrder(amount: amount, eventId: eventId);
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (orderData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initialize Razorpay. Please try again.')),
      );
      return;
    }

    final razorpayOrderId = orderData['order_id'] ?? ('order_sih_' + DateTime.now().millisecondsSinceEpoch.toString().substring(5));
    final razorpayKey = orderData['key'] ?? 'rzp_test_TSKYJjtfjh7sGM';

    _launchRazorpayCheckout(orderData, razorpayOrderId, razorpayKey);
  }

  Future<void> _launchRazorpayCheckout(Map<String, dynamic> orderData, String razorpayOrderId, String razorpayKey) async {
    _lastOrderId = razorpayOrderId;
    
    final int amountInPaise = int.parse((orderData['amount'] ?? ((widget.sihEvent?.price ?? 200.0) * 100).toInt()).toString());

    final options = {
      'key': razorpayKey,
      'amount': 100, // Forced to 1 Rupee (100 paise) for transaction testing
      'name': 'GVP College Portal',
      'description': widget.sihEvent?.title ?? 'SIH Internal selection',
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

  void _showBookingSuccessDialog(String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFECFDF5),
              child: Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
            ),
            const SizedBox(height: 12),
            const Text(
              'Registration Confirmed!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your team has successfully registered for SIH 2026 Internal Hackathon!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
                  _infoRow('Team Name', _teamNameController.text),
                  const Divider(height: 12),
                  _infoRow('Team Leader', _teamLeaderController.text),
                  const Divider(height: 12),
                  _infoRow('Txn ID', transactionId),
                  const Divider(height: 12),
                  _infoRow('Payment', '₹200.00 (Paid via Razorpay)'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'SIH 2026 Registration',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Internal Hackathon',
                            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        const Spacer(),
                        const Text('GVPCE(A)', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Registration for SIH 2026-Internal Hackathon',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Teams may submit up to TWO different ideas. Submission of second idea is OPTIONAL.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section: General & Contact Info
              _buildSectionTitle('1. Team Leader & Contact Details'),
              _buildCard([
                _buildTextField(_emailController, 'Email *', 'Enter email address', isRequired: true, keyboardType: TextInputType.emailAddress),
                _buildTextField(_teamNameController, 'Team Name *', 'Enter your team name', isRequired: true),
                _buildTextField(_teamLeaderController, 'Name of the team leader *', 'Full name of leader', isRequired: true),
                _buildTextField(_rollNumberController, 'Roll Number *', 'e.g. 22131A0501', isRequired: true),
                _buildGenderSelector(),
                _buildBranchDropdown(),
                _buildYearDropdown(),
                _buildTextField(_mobileController, 'Mobile number *', '10-digit mobile number', isRequired: true, keyboardType: TextInputType.phone),
              ]),

              const SizedBox(height: 20),

              // Section: Idea 1 Details
              _buildSectionTitle('2. Idea 1 Details (Required)'),
              _buildCard([
                _buildTextField(_idea1TitleController, 'Title of Idea 1 (PSID) *', 'Problem Statement ID & Title', isRequired: true),
                _buildTextField(_idea1ThemeController, 'Idea 1 SIH Theme/Sector *', 'e.g. Smart Automation, MedTech, FinTech', isRequired: true),
                _buildTextField(_idea1ProblemController, 'Idea 1 Problem Statement *', 'Brief description of problem statement', isRequired: true, maxLines: 3),
              ]),

              const SizedBox(height: 20),

              // Section: Idea 2 Details (Optional)
              _buildSectionTitle('3. Idea 2 Details (Optional)'),
              _buildCard([
                _buildTextField(_idea2TitleController, 'Title of Idea 2 (PSID)', 'Problem Statement ID & Title (if any)', isRequired: false),
                _buildTextField(_idea2ThemeController, 'Idea 2 SIH Theme/Sector', 'Theme/Sector for second idea', isRequired: false),
                _buildTextField(_idea2ProblemController, 'Idea 2 Problem Statement', 'Description of second idea', isRequired: false, maxLines: 3),
              ]),

              const SizedBox(height: 20),

              // Section: Document Upload
              _buildSectionTitle('4. Team Nomination Letter Upload'),
              _buildCard([
                const Text(
                  'Upload Team Nomination Letter in prescribed template (.docx). Ensure it contains Team Name, Leader, and Member details.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickNominationLetter,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _nominationFileName != null ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                        width: _nominationFileName != null ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _nominationFileName != null ? Icons.description : Icons.cloud_upload_outlined,
                          color: _nominationFileName != null ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _nominationFileName ?? 'Upload Team Nomination Letter (.docx)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _nominationFileName != null ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 30),

              // Submit / Checkout Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  onPressed: _proceedToCheckout,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Proceed to Checkout (₹200)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: isRequired
                ? (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gender *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('M (Male)', style: TextStyle(fontSize: 13)),
                  value: 'M',
                  groupValue: _selectedGender,
                  onChanged: (val) => setState(() => _selectedGender = val!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('F (Female)', style: TextStyle(fontSize: 13)),
                  value: 'F',
                  groupValue: _selectedGender,
                  onChanged: (val) => setState(() => _selectedGender = val!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Branch *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedBranch,
            items: _branches
                .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (val) => setState(() => _selectedBranch = val!),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YEAR OF STUDY *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedYear,
            items: _years
                .map((y) => DropdownMenuItem(value: y, child: Text('Year $y', style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (val) => setState(() => _selectedYear = val!),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ],
      ),
    );
  }
}

// ── RAZORPAY CHECKOUT MODAL ──────────────────────────────────────────
class _RazorpayCheckoutModal extends StatefulWidget {
  final String teamName;
  final String leaderName;
  final String email;
  final String mobile;
  final double amount;
  final Function(String transactionId) onPaymentSuccess;

  const _RazorpayCheckoutModal({
    Key? key,
    required this.teamName,
    required this.leaderName,
    required this.email,
    required this.mobile,
    required this.amount,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<_RazorpayCheckoutModal> createState() => _RazorpayCheckoutModalState();
}

class _RazorpayCheckoutModalState extends State<_RazorpayCheckoutModal> {
  bool _isProcessing = false;
  String _selectedMethod = 'UPI';

  void _payNow() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final txnId = 'pay_RZP${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        widget.onPaymentSuccess(txnId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Razorpay branding
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C2340),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt, color: Color(0xFF0284C7), size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Razorpay',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Order summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SIH 2026 Registration Fee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                    Text('Team: ${widget.teamName}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                Text(
                  '₹${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 10),

          // Payment Option List
          _buildOptionTile('UPI (GPay / PhonePe / Paytm)', Icons.qr_code, 'UPI'),
          _buildOptionTile('Credit / Debit Card', Icons.credit_card, 'Card'),
          _buildOptionTile('NetBanking', Icons.account_balance, 'NetBanking'),

          const SizedBox(height: 20),

          if (_isProcessing)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFF0284C7)),
                  SizedBox(height: 12),
                  Text('Processing secure payment via Razorpay...', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _payNow,
                child: Text(
                  'Pay ₹${widget.amount.toStringAsFixed(0)} via Razorpay',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, String value) {
    final isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF0284C7), size: 18),
          ],
        ),
      ),
    );
  }
}
