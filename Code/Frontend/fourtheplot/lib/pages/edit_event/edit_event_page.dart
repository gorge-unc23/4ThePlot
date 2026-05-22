import 'package:flutter/material.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/pages/edit_event/edit_event_details_page.dart';
import 'package:fourtheplot/pages/edit_event/edit_event_draft.dart';
import 'package:provider/provider.dart';

class EditEventPage extends StatelessWidget {
  final Event event;

  const EditEventPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditEventDraft.fromEvent(event),
      child: const EditEventDetailsPage(),
    );
  }
}
