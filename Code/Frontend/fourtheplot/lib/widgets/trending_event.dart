import 'package:flutter/material.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:intl/intl.dart';

class TrendingEvent extends StatelessWidget {
  final Event event;

  const TrendingEvent({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => DetailsPage(
        //     ),
        //   ),
        // );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              event.coverImageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat.yMMMMd().format(event.startAt),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.place,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.location.address,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 26,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.pink.shade300,
                                  child: const Text(
                                    'A',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.blue.shade300,
                                  child: const Text(
                                    'M',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 32,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.purple.shade300,
                                  child: const Text(
                                    'G',
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 52,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: const Text(
                                    '2k+',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 65,
                    height: 35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.pink.shade300],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Join',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
