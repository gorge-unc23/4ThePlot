import 'package:fourtheplot/mock/mock_users.dart';
import 'package:fourtheplot/models/comment.dart';

final now = DateTime.now();
List<Comment> mockComments = [
  Comment(
    id: 'comment_01',
    userId: mockUsers[0].id,
    eventId: "",
    text: 'Love the lineup so far. The venue looks amazing.',
    createdAt: now.subtract(const Duration(hours: 5)),
    author: mockUsers[0],
  ),
  Comment(
    id: 'comment_02',
    userId: mockUsers[1].id,
    eventId: "eventId",
    text: 'Anyone else coming from Durres? Happy to carpool.',
    createdAt: now.subtract(const Duration(days: 1, hours: 2)),
    author: mockUsers[1],
  ),
  Comment(
    id: 'comment_03',
    userId: mockUsers[2].id,
    eventId: "eventId",
    text: 'The last edition was legendary. Do not miss this.',
    createdAt: now.subtract(const Duration(days: 2, hours: 6)),
    author: mockUsers[2],
  ),
];
