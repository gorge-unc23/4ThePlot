import 'package:flutter/material.dart';
import 'package:fourtheplot/common/colors.dart';
import 'package:fourtheplot/common/credit_card_expiry_formatter.dart';
import 'package:fourtheplot/common/credit_card_number_formatter.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/widgets/info_card.dart';
import 'package:fourtheplot/widgets/tag_chip.dart';
import 'package:intl/intl.dart';

class JoinEventPage extends StatefulWidget {
  final Event event;

  const JoinEventPage({super.key, required this.event});

  @override
  State<JoinEventPage> createState() => _JoinEventPageState();
}

class _JoinEventPageState extends State<JoinEventPage> {
  int _ticketCount = 1;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool get _isPaid => widget.event.price > 0;

  double get _total => widget.event.price * _ticketCount;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _incrementTickets() {
    setState(() {
      _ticketCount += 1;
    });
  }

  void _decrementTickets() {
    if (_ticketCount <= 1) {
      return;
    }
    setState(() {
      _ticketCount -= 1;
    });
  }

  String _formatPrice(double value) {
    if (value <= 0) {
      return 'Free';
    }
    return '${widget.event.currency} ${value.toStringAsFixed(2)}';
  }

  void _handleConfirm() {
    final message = _isPaid
        ? 'Payment confirmed. Your ticket is secured.'
        : 'You are confirmed. See you there.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final dateLabel = DateFormat('EEE, MMM d').format(event.startAt);
    final timeLabel =
        '${DateFormat('h:mm a').format(event.startAt)} - ${DateFormat('h:mm a').format(event.endAt)}';
    final priceLabel = _formatPrice(event.price);
    final totalLabel = _formatPrice(_total);
    final ctaLabel = _isPaid ? 'Confirm payment' : 'Confirm';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Join event'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildEventSummary(event, dateLabel, timeLabel, priceLabel),
          const SizedBox(height: 18),
          _buildTicketSection(priceLabel),
          const SizedBox(height: 18),
          _buildPriceCards(priceLabel, totalLabel),
          const SizedBox(height: 18),
          if (_isPaid) _buildPaymentForm() else _buildFreeNotice(),
          const SizedBox(height: 110),
        ],
      ),
      bottomNavigationBar: _buildConfirmBar(totalLabel, ctaLabel),
    );
  }

  Widget _buildEventSummary(
    Event event,
    String dateLabel,
    String timeLabel,
    String priceLabel,
  ) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (event.isFree) TagChip(label: 'FREE', color: accentBlue),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(Icons.calendar_today, dateLabel),
          const SizedBox(height: 6),
          _buildSummaryRow(Icons.schedule, timeLabel),
          const SizedBox(height: 6),
          _buildSummaryRow(Icons.place, event.location.address),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Price per ticket',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                priceLabel,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketSection(String priceLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tickets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General admission',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      priceLabel,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              _QuantityButton(
                icon: Icons.remove,
                onPressed: _ticketCount > 1 ? _decrementTickets : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_ticketCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onPressed: _ticketCount < 6 ? _incrementTickets : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCards(String priceLabel, String totalLabel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: InfoCard(
                icon: Icons.sell,
                label: 'Price per ticket',
                value: priceLabel,
                accentColor: accentBlue,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: InfoCard(
                icon: Icons.receipt_long,
                label: 'Total',
                value: totalLabel,
                accentColor: accentPurple,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentForm() {
    return Column(
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
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _cardNumberController,
                inputFormatters: [CreditCardNumberFormatter()],
                maxLength: 19,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Card number', hint: 'XXXX XXXX XXXX XXXX'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      inputFormatters: [CreditCardExpiryFormatter()],
                      maxLength: 5,
                      keyboardType: TextInputType.datetime,
                      decoration: _inputDecoration('Expiry', hint: 'MM/YY'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('CVV', hint: '123'),
                      maxLength: 3,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('Name on card', hint: 'Full name'),
              ),
              const SizedBox(height: 12),
              Text(
                'Mock form only. No real payment is processed.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreeNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: accentBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This event is free. No payment details required.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmBar(String totalLabel, String ctaLabel) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ConfirmButton(label: ctaLabel, onPressed: _handleConfirm),
          ),
        ],
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isEnabled ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: isEnabled ? 0.2 : 0.08),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ConfirmButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF9B6CFF), Color(0xFF6EA8FF)]),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
