import 'package:flutter/material.dart';
import 'package:fourtheplot/pages/settings/settings_shared.dart';

class SettingsSupportFeedbackPage extends StatefulWidget {
  const SettingsSupportFeedbackPage({super.key});

  @override
  State<SettingsSupportFeedbackPage> createState() =>
      _SettingsSupportFeedbackPageState();
}

class _SettingsSupportFeedbackPageState
    extends State<SettingsSupportFeedbackPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    _subjectController.clear();
    _messageController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback submitted.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsShell(
      title: 'Support & Feedback',
      subtitle: 'Help center and contact',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          const Text('FAQs', style: settingsSectionTitleStyle),
          const SizedBox(height: 10),
          _faq('How do I join an event?', 'Open an event and tap Join event.'),
          _faq('How do refunds work?', 'Contact support with your ticket details.'),
          _faq(
            'How do hosts become trusted?',
            'Hosts submit documents for admin review.',
          ),
          _faq('Can I edit my profile?', 'Yes, use the Profile settings page.'),
          const SizedBox(height: 18),
          const Text('Feedback', style: settingsSectionTitleStyle),
          const SizedBox(height: 10),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Send feedback'),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _ticket(String title, String status, String date) {
  //   return SettingsCard(
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Text(title, style: const TextStyle(color: Colors.white)),
  //         ),
  //         Text('$status - $date', style: const TextStyle(color: Colors.white54)),
  //       ],
  //     ),
  //   );
  // }

  Widget _faq(String question, String answer) {
    return SettingsCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(color: Colors.white)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(answer, style: const TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}
