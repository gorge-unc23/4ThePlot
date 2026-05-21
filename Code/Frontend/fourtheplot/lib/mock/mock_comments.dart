import 'package:fourtheplot/mock/mock_users.dart';
import 'package:fourtheplot/models/comment.dart';

final now = DateTime.now();
List<Comment> mockComments = [
  Comment(
    id: 1,
    userId: mockUsers[0].id,
    eventId: 1,
    text: 'Love the lineup so far. The venue looks amazing.',
    createdAt: now.subtract(const Duration(hours: 5)),
    author: mockUsers[0],
  ),
  Comment(
    id: 2,
    userId: mockUsers[1].id,
    eventId: 2,
    text: 'Anyone else coming from Durres? Happy to carpool.',
    createdAt: now.subtract(const Duration(days: 1, hours: 2)),
    author: mockUsers[1],
  ),
  Comment(
    id: 3,
    userId: mockUsers[2].id,
    eventId: 3,
    text: 'The last edition was legendary. Do not miss this.',
    createdAt: now.subtract(const Duration(days: 2, hours: 6)),
    author: mockUsers[2],
  ),
];
