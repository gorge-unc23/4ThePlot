// Core event model for Flutter, aligned with UML lifecycle states.

enum EventStatus {
	draft,
	published,
	live,
	suspended,
	completed,
	archived,
}

EventStatus eventStatusFromString(String value) {
	switch (value) {
		case 'draft':
			return EventStatus.draft;
		case 'published':
			return EventStatus.published;
		case 'live':
			return EventStatus.live;
		case 'suspended':
			return EventStatus.suspended;
		case 'completed':
			return EventStatus.completed;
		case 'archived':
			return EventStatus.archived;
		default:
			return EventStatus.draft;
	}
}

String eventStatusToString(EventStatus status) {
	switch (status) {
		case EventStatus.draft:
			return 'draft';
		case EventStatus.published:
			return 'published';
		case EventStatus.live:
			return 'live';
		case EventStatus.suspended:
			return 'suspended';
		case EventStatus.completed:
			return 'completed';
		case EventStatus.archived:
			return 'archived';
	}
}

class EventLocation {
	final String address;
	final String? venueName;
	final double? latitude;
	final double? longitude;

	const EventLocation({
		required this.address,
		this.venueName,
		this.latitude,
		this.longitude,
	});

	factory EventLocation.fromJson(Map<String, dynamic> json) {
		return EventLocation(
			address: (json['address'] as String?) ?? '',
			venueName: json['venueName'] as String?,
			latitude: (json['latitude'] as num?)?.toDouble(),
			longitude: (json['longitude'] as num?)?.toDouble(),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'address': address,
			'venueName': venueName,
			'latitude': latitude,
			'longitude': longitude,
		};
	}
}

class EventCapacity {
	final int? maxAttendees;
	final int confirmedAttendees;
	final bool waitlistEnabled;

	const EventCapacity({
		this.maxAttendees,
		required this.confirmedAttendees,
		required this.waitlistEnabled,
	});

	factory EventCapacity.fromJson(Map<String, dynamic> json) {
		return EventCapacity(
			maxAttendees: json['maxAttendees'] as int?,
			confirmedAttendees: (json['confirmedAttendees'] as int?) ?? 0,
			waitlistEnabled: (json['waitlistEnabled'] as bool?) ?? false,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'maxAttendees': maxAttendees,
			'confirmedAttendees': confirmedAttendees,
			'waitlistEnabled': waitlistEnabled,
		};
	}
}

class RecurrenceRule {
	final String frequency; // daily, weekly, monthly
	final int interval;
	final DateTime? endDate;
	final int? count;
	final List<int>? byWeekday; // 1=Mon .. 7=Sun

	const RecurrenceRule({
		required this.frequency,
		required this.interval,
		this.endDate,
		this.count,
		this.byWeekday,
	});

	factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
		return RecurrenceRule(
			frequency: (json['frequency'] as String?) ?? 'weekly',
			interval: (json['interval'] as int?) ?? 1,
			endDate: json['endDate'] != null
					? DateTime.parse(json['endDate'] as String)
					: null,
			count: json['count'] as int?,
			byWeekday: (json['byWeekday'] as List<dynamic>?)
					?.map((e) => e as int)
					.toList(),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'frequency': frequency,
			'interval': interval,
			'endDate': endDate?.toIso8601String(),
			'count': count,
			'byWeekday': byWeekday,
		};
	}
}

class Event {
	final String id;
	final String title;
	final String description;
	final String hostId;
	final String? hostName;
	final EventStatus status;
	final DateTime startAt;
	final DateTime endAt;
	final EventLocation location;
	final EventCapacity capacity;
	final RecurrenceRule? recurrence;
	final List<String> categories;
	final List<String> tags;
	final String coverImageUrl;
	final DateTime createdAt;
	final DateTime updatedAt;

	const Event({
		required this.id,
		required this.title,
		required this.description,
		required this.hostId,
		this.hostName,
		required this.status,
		required this.startAt,
		required this.endAt,
		required this.location,
		required this.capacity,
		this.recurrence,
		required this.categories,
		required this.tags,
		required this.coverImageUrl,
		required this.createdAt,
		required this.updatedAt,
	});

	Event copyWith({
		String? id,
		String? title,
		String? description,
		String? hostId,
		String? hostName,
		EventStatus? status,
		DateTime? startAt,
		DateTime? endAt,
		EventLocation? location,
		EventCapacity? capacity,
		RecurrenceRule? recurrence,
		List<String>? categories,
		List<String>? tags,
		String? coverImageUrl,
		DateTime? createdAt,
		DateTime? updatedAt,
	}) {
		return Event(
			id: id ?? this.id,
			title: title ?? this.title,
			description: description ?? this.description,
			hostId: hostId ?? this.hostId,
			hostName: hostName ?? this.hostName,
			status: status ?? this.status,
			startAt: startAt ?? this.startAt,
			endAt: endAt ?? this.endAt,
			location: location ?? this.location,
			capacity: capacity ?? this.capacity,
			recurrence: recurrence ?? this.recurrence,
			categories: categories ?? this.categories,
			tags: tags ?? this.tags,
			coverImageUrl: coverImageUrl ?? this.coverImageUrl,
			createdAt: createdAt ?? this.createdAt,
			updatedAt: updatedAt ?? this.updatedAt,
		);
	}

	factory Event.fromJson(Map<String, dynamic> json) {
		return Event(
			id: (json['id'] as String?) ?? '',
			title: (json['title'] as String?) ?? '',
			description: (json['description'] as String?) ?? '',
			hostId: (json['hostId'] as String?) ?? '',
			hostName: json['hostName'] as String?,
			status: eventStatusFromString((json['status'] as String?) ?? 'draft'),
			startAt: DateTime.parse(json['startAt'] as String),
			endAt: DateTime.parse(json['endAt'] as String),
			location: EventLocation.fromJson(
				(json['location'] as Map<String, dynamic>?) ?? const {},
			),
			capacity: EventCapacity.fromJson(
				(json['capacity'] as Map<String, dynamic>?) ?? const {},
			),
			recurrence: json['recurrence'] != null
					? RecurrenceRule.fromJson(json['recurrence'] as Map<String, dynamic>)
					: null,
			categories: (json['categories'] as List<dynamic>?)
							?.map((e) => e as String)
							.toList() ??
					const [],
			tags: (json['tags'] as List<dynamic>?)
							?.map((e) => e as String)
							.toList() ??
					const [],
			coverImageUrl: json['coverImageUrl'] as String,
			createdAt: DateTime.parse(json['createdAt'] as String),
			updatedAt: DateTime.parse(json['updatedAt'] as String),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'title': title,
			'description': description,
			'hostId': hostId,
			'hostName': hostName,
			'status': eventStatusToString(status),
			'startAt': startAt.toIso8601String(),
			'endAt': endAt.toIso8601String(),
			'location': location.toJson(),
			'capacity': capacity.toJson(),
			'recurrence': recurrence?.toJson(),
			'categories': categories,
			'tags': tags,
			'coverImageUrl': coverImageUrl,
			'createdAt': createdAt.toIso8601String(),
			'updatedAt': updatedAt.toIso8601String(),
		};
	}
}
