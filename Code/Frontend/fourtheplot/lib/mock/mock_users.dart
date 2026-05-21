import 'package:fourtheplot/models/user.dart';

final now = DateTime.now();

final List<User> mockUsers = [ 
  User(
    id: 'user_01',
    displayName: 'Alma K.',
    email: 'alma@example.com',
    role: UserRole.goer,
    status: UserStatus.active,
    createdAt: now.subtract(const Duration(days: 120)),
    updatedAt: now.subtract(const Duration(days: 2)),
  ),
  User(
    id: 'user_02',
    displayName: 'Erion D.',
    email: 'erion@example.com',
    role: UserRole.goer,
    status: UserStatus.active,
    createdAt: now.subtract(const Duration(days: 90)),
    updatedAt: now.subtract(const Duration(days: 1)),
  ),
  User(
    id: 'user_03',
    displayName: 'Luna P.',
    email: 'luna@example.com',
    role: UserRole.goer,
    status: UserStatus.active,
    createdAt: now.subtract(const Duration(days: 180)),
    updatedAt: now.subtract(const Duration(days: 4)),
  ),
];