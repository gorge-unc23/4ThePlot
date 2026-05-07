import 'package:flutter/material.dart';
import 'package:fourtheplot/mock/mock_events.dart';
import 'package:fourtheplot/widgets/trending_event.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final GlobalKey<FormState> _searchFormKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final events = mockEvents;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Discover Events",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                    ),
                    Text(
                      "Find amazing experiences near you",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.shade300,
                  child: const Text(
                    'R',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Form(
              key: _searchFormKey,
              child: TextFormField(
                controller: _searchController,
                onTapOutside: (PointerDownEvent event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search events, venues...",
                ),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "✨ Trending Events",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 320,
                        child: TrendingEvent(event: events[index]),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemCount: events.length,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Events near you",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TrendingEvent(event: events[index]),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemCount: events.length,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
