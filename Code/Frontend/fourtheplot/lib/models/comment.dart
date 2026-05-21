import 'event.dart';
import 'user.dart';

class Comment {
	final int id;
	final int userId;
	final int eventId;
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
		int? id,
		int? userId,
		int? eventId,
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
			id: json['id'],
			userId: json['userId'],
			eventId: json['eventId'],
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

