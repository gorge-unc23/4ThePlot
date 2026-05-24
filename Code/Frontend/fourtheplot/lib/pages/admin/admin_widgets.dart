import 'package:flutter/material.dart';

class AdminStatusChip extends StatelessWidget {
  final String label;
  final Color? color;

  const AdminStatusChip({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? _colorFor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _colorFor(String value) {
    switch (value) {
      case 'open':
      case 'pending':
      case 'scheduled':
        return const Color(0xFFFACC15);
      case 'resolved':
      case 'approved':
      case 'published':
        return const Color(0xFF34D399);
      case 'rejected':
      case 'suspected_fraud':
      case 'suspended':
        return const Color(0xFFFF6B6B);
      case 'pending_documents':
      case 'needs_evidence':
      case 'pending_communication':
      case 'escalated':
        return const Color(0xFF22D3EE);
      default:
        return const Color(0xFF6EA8FF);
    }
  }
}

class AdminSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdminSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  final String message;

  const AdminEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      child: Text(
        message,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
      ),
    );
  }
}

class AdminErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AdminErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class AdminFilterBar extends StatelessWidget {
  final List<String> values;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const AdminFilterBar({
    super.key,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, null, 'All'),
          ...values.map((value) => _buildChip(context, value, value.replaceAll('_', ' '))),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String? value, String label) {
    final isSelected = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (_) => onChanged(value),
      ),
    );
  }
}

Future<String?> showAdminReasonDialog(
  BuildContext context, {
  required String title,
  String hintText = 'Reason',
}) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final reason = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(hintText: hintText),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Reason is required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
  // controller.dispose();
  return reason;
}
