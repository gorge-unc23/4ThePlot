import 'event.dart';
import 'user.dart';

class Registration {
	final String id;
	final String userId;
	final String eventId;
	final DateTime registeredAt;
	final User? user;
	final Event? event;

	const Registration({
		required this.id,
		required this.userId,
		required this.eventId,
		required this.registeredAt,
		this.user,
		this.event,
	});

	Registration copyWith({
		String? id,
		String? userId,
		String? eventId,
		DateTime? registeredAt,
		User? user,
		Event? event,
	}) {
		return Registration(
			id: id ?? this.id,
			userId: userId ?? this.userId,
			eventId: eventId ?? this.eventId,
			registeredAt: registeredAt ?? this.registeredAt,
			user: user ?? this.user,
			event: event ?? this.event,
		);
	}

	factory Registration.fromJson(Map<String, dynamic> json) {
		return Registration(
			id: (json['id'] as String?) ?? (json['id']?.toString() ?? ''),
			userId: (json['userId'] as String?) ?? (json['user_id']?.toString() ?? ''),
			eventId: (json['eventId'] as String?) ?? (json['event_id']?.toString() ?? ''),
			registeredAt: json['registeredAt'] != null
					? DateTime.parse(json['registeredAt'] as String)
					: DateTime.parse((json['registered_at'] as String?) ?? DateTime.now().toIso8601String()),
			user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
			event: json['event'] != null ? Event.fromJson(json['event'] as Map<String, dynamic>) : null,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'userId': userId,
			'eventId': eventId,
			'registeredAt': registeredAt.toIso8601String(),
			'user': user?.toJson(),
			'event': event?.toJson(),
		};
	}
}

