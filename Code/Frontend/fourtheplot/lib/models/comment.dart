import 'event.dart';
import 'user.dart';

class Comment {
	final String id;
	final String userId;
	final String eventId;
	final String text;
	final DateTime createdAt;
	final User? author;
	final Event? event;

	const Comment({
		required this.id,
		required this.userId,
		required this.eventId,
		required this.text,
		required this.createdAt,
		this.author,
		this.event,
	});

	Comment copyWith({
		String? id,
		String? userId,
		String? eventId,
		String? text,
		DateTime? createdAt,
		User? author,
		Event? event,
	}) {
		return Comment(
			id: id ?? this.id,
			userId: userId ?? this.userId,
			eventId: eventId ?? this.eventId,
			text: text ?? this.text,
			createdAt: createdAt ?? this.createdAt,
			author: author ?? this.author,
			event: event ?? this.event,
		);
	}

	factory Comment.fromJson(Map<String, dynamic> json) {
		return Comment(
			id: (json['id'] as String?) ?? '',
			userId: (json['userId'] as String?) ?? (json['user_id']?.toString() ?? ''),
			eventId: (json['eventId'] as String?) ?? (json['event_id']?.toString() ?? ''),
			text: (json['text'] as String?) ?? '',
			createdAt: json['createdAt'] != null
					? DateTime.parse(json['createdAt'] as String)
					: DateTime.parse((json['created_at'] as String?) ?? DateTime.now().toIso8601String()),
			author: json['author'] != null ? User.fromJson(json['author'] as Map<String, dynamic>) : null,
			event: json['event'] != null ? Event.fromJson(json['event'] as Map<String, dynamic>) : null,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'userId': userId,
			'eventId': eventId,
			'text': text,
			'createdAt': createdAt.toIso8601String(),
			'author': author?.toJson(),
			'event': event?.toJson(),
		};
	}
}

