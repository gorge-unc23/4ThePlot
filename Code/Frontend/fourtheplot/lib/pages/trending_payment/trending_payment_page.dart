import 'package:flutter/material.dart';
import 'package:fourtheplot/common/colors.dart';
import 'package:fourtheplot/common/credit_card_expiry_formatter.dart';
import 'package:fourtheplot/common/credit_card_number_formatter.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';

class TrendingPaymentPage extends StatefulWidget {
  final Event event;

  const TrendingPaymentPage({super.key, required this.event});

  @override
  State<TrendingPaymentPage> createState() => _TrendingPaymentPageState();
}

class _TrendingPaymentPageState extends State<TrendingPaymentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handlePromote() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }

    final eventId = int.tryParse(widget.event.id);
    if (eventId == null) {
      _showMessage('Could not promote event: invalid event id.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final payload = widget.event.toJson();
    payload['hostId'] = int.tryParse(widget.event.hostId) ?? widget.event.hostId;
    payload['trending'] = true;

    final result = await DatabaseHelper.instance.updateEvent(eventId, payload);
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (!result.success) {
      _showMessage('Could not promote event: ${result.message}');
      return;
    }

    MainWrapper.refresh();
    _showMessage('Event promoted successfully.');
    Navigator.of(context).pop(true);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final ctaLabel = _isSubmitting ? 'Promoting...' : 'Promote event';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Promote event'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildExplanation(),
          const SizedBox(height: 18),
          _buildPaymentForm(),
          const SizedBox(height: 110),
        ],
      ),
      bottomNavigationBar: _buildConfirmBar(ctaLabel),
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appear in Trending',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Promoting this event marks it as trending, making it appear in the trending section for users.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72), height: 1.45),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.event, color: accentBlue, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cardNumberController,
              inputFormatters: [CreditCardNumberFormatter()],
              maxLength: 19,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Card number', hint: 'XXXX XXXX XXXX XXXX'),
              validator: (value) {
                final digits = (value ?? '').replaceAll(' ', '');
                return digits.length < 16 ? 'Enter a valid card number.' : null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    inputFormatters: [CreditCardExpiryFormatter()],
                    maxLength: 5,
                    keyboardType: TextInputType.datetime,
                    decoration: _inputDecoration('Expiry', hint: 'MM/YY'),
                    validator: (value) {
                      return RegExp(r'^\d{2}/\d{2}$').hasMatch(value ?? '')
                          ? null
                          : 'Invalid expiry.';
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: true,
                    decoration: _inputDecoration('CVV', hint: '123'),
                    validator: (value) {
                      return RegExp(r'^\d{3}$').hasMatch(value ?? '')
                          ? null
                          : 'Invalid CVV.';
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('Name on card', hint: 'Full name'),
              validator: (value) {
                return value == null || value.trim().isEmpty ? 'Name is required.' : null;
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Mock form only. No real payment is processed.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmBar(String ctaLabel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF171C38), Color(0xFF101428)]),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: _PromoteButton(
        label: ctaLabel,
        onPressed: _isSubmitting ? null : _handlePromote,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {required String hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
      filled: true,
      counterText: '',
      fillColor: Colors.white.withValues(alpha: 0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accentBlue.withValues(alpha: 0.8)),
      ),
    );
  }
}

class _PromoteButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PromoteButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return SizedBox(
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Ink(
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? const LinearGradient(colors: [Color(0xFF9B6CFF), Color(0xFF6EA8FF)])
                    : null,
                color: isEnabled ? null : Colors.white.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: isEnabled ? 1 : 0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
