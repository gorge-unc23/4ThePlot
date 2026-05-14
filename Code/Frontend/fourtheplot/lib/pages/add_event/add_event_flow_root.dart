import 'package:flutter/material.dart';
import 'package:fourtheplot/pages/add_event/add_event_details_page.dart';
import 'package:fourtheplot/pages/add_event/add_event_draft.dart';
import 'package:provider/provider.dart';

class AddEventFlowRoot extends StatelessWidget {
  const AddEventFlowRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddEventDraft(),
      child: const AddEventDetailsPage(),
    );
  }
}
