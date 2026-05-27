import 'package:flutter/material.dart';

class ReportDialogResult {
  final String reason;
  final String severity;

  const ReportDialogResult({
    required this.reason,
    required this.severity,
  });
}

Future<ReportDialogResult?> showReportDialog(
  BuildContext context, {
  required String title,
}) {
  return showDialog<ReportDialogResult>(
    context: context,
    builder: (context) => _ReportDialog(title: title),
  );
}

class _ReportDialog extends StatefulWidget {
  final String title;

  const _ReportDialog({required this.title});

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _severity = 'medium';

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      ReportDialogResult(
        reason: _reasonController.text.trim(),
        severity: _severity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _reasonController,
              autofocus: true,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Describe what should be reviewed',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Reason is required' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _severity,
              decoration: const InputDecoration(labelText: 'Severity'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) => setState(() => _severity = value ?? 'medium'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Submit report'),
        ),
      ],
    );
  }
}
