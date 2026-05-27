BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "admin_audit_logs" (
	"id"	INTEGER NOT NULL,
	"admin_id"	INTEGER NOT NULL,
	"action"	VARCHAR NOT NULL,
	"target_type"	VARCHAR,
	"target_id"	INTEGER,
	"reason"	TEXT NOT NULL,
	"created_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("admin_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "alembic_version" (
	"version_num"	VARCHAR(32) NOT NULL,
	CONSTRAINT "alembic_version_pkc" PRIMARY KEY("version_num")
);
CREATE TABLE IF NOT EXISTS "business_profiles" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"name"	VARCHAR NOT NULL,
	"description"	VARCHAR,
	"website_url"	VARCHAR,
	"logo_url"	VARCHAR,
	"is_published"	BOOLEAN,
	PRIMARY KEY("id"),
	UNIQUE("user_id"),
	FOREIGN KEY("user_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "categories" (
	"id"	INTEGER NOT NULL,
	"name"	VARCHAR NOT NULL,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "comments" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER,
	"event_id"	INTEGER,
	"text"	VARCHAR,
	"created_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("event_id") REFERENCES "events"("id"),
	FOREIGN KEY("user_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "dispute_cases" (
	"id"	INTEGER NOT NULL,
	"event_id"	INTEGER,
	"host_user_id"	INTEGER,
	"goer_user_id"	INTEGER,
	"status"	VARCHAR,
	"reason"	TEXT,
	"decision"	VARCHAR,
	"decision_reason"	TEXT,
	"resolved_at"	DATETIME,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("event_id") REFERENCES "events"("id"),
	FOREIGN KEY("goer_user_id") REFERENCES "users"("id"),
	FOREIGN KEY("host_user_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "dispute_evidence" (
	"id"	INTEGER NOT NULL,
	"dispute_id"	INTEGER NOT NULL,
	"evidence_type"	VARCHAR,
	"content_url"	VARCHAR,
	"content_text"	TEXT,
	"complete"	BOOLEAN,
	"created_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("dispute_id") REFERENCES "dispute_cases"("id")
);
CREATE TABLE IF NOT EXISTS "event_capacities" (
	"id"	INTEGER NOT NULL,
	"event_id"	INTEGER NOT NULL,
	"max_attendees"	INTEGER,
	"confirmed_attendees"	INTEGER,
	"waitlist_enabled"	BOOLEAN,
	UNIQUE("event_id"),
	PRIMARY KEY("id"),
	FOREIGN KEY("event_id") REFERENCES "events"("id")
);
CREATE TABLE IF NOT EXISTS "event_categories" (
	"event_id"	INTEGER NOT NULL,
	"category_id"	INTEGER NOT NULL,
	PRIMARY KEY("event_id","category_id"),
	FOREIGN KEY("category_id") REFERENCES "categories"("id"),
	FOREIGN KEY("event_id") REFERENCES "events"("id")
);
CREATE TABLE IF NOT EXISTS "event_locations" (
	"id"	INTEGER NOT NULL,
	"event_id"	INTEGER NOT NULL,
	"address"	VARCHAR NOT NULL,
	"venue_name"	VARCHAR,
	"latitude"	FLOAT,
	"longitude"	FLOAT,
	"city"	VARCHAR,
	UNIQUE("event_id"),
	PRIMARY KEY("id"),
	FOREIGN KEY("event_id") REFERENCES "events"("id")
);
CREATE TABLE IF NOT EXISTS "event_tags" (
	"event_id"	INTEGER NOT NULL,
	"tag_id"	INTEGER NOT NULL,
	PRIMARY KEY("event_id","tag_id"),
	FOREIGN KEY("event_id") REFERENCES "events"("id"),
	FOREIGN KEY("tag_id") REFERENCES "tags"("id")
);
CREATE TABLE IF NOT EXISTS "events" (
	"id"	INTEGER NOT NULL,
	"title"	VARCHAR,
	"description"	VARCHAR,
	"status"	VARCHAR,
	"image_url"	VARCHAR,
	"start_at"	DATETIME,
	"end_at"	DATETIME,
	"price"	FLOAT,
	"currency"	VARCHAR,
	"organizer_id"	INTEGER,
	"host_name"	VARCHAR,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	"trending"	BOOLEAN NOT NULL DEFAULT '0',
	PRIMARY KEY("id"),
	FOREIGN KEY("organizer_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "global_notifications" (
	"id"	INTEGER NOT NULL,
	"title"	VARCHAR NOT NULL,
	"message"	TEXT NOT NULL,
	"status"	VARCHAR,
	"starts_at"	DATETIME,
	"ends_at"	DATETIME,
	"created_by_admin_id"	INTEGER NOT NULL,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("created_by_admin_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "goer_preference_categories" (
	"preference_id"	INTEGER NOT NULL,
	"category_id"	INTEGER NOT NULL,
	PRIMARY KEY("preference_id","category_id"),
	FOREIGN KEY("category_id") REFERENCES "categories"("id"),
	FOREIGN KEY("preference_id") REFERENCES "goer_preferences"("id")
);
CREATE TABLE IF NOT EXISTS "goer_preferences" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"updated_at"	DATETIME,
	PRIMARY KEY("id"),
	UNIQUE("user_id"),
	FOREIGN KEY("user_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "host_credibility" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"rating"	FLOAT,
	"review_count"	INTEGER,
	"trusted"	BOOLEAN,
	PRIMARY KEY("id"),
	UNIQUE("user_id"),
	FOREIGN KEY("user_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "host_verification_documents" (
	"id"	INTEGER NOT NULL,
	"request_id"	INTEGER NOT NULL,
	"document_type"	VARCHAR NOT NULL,
	"document_url"	VARCHAR NOT NULL,
	"status"	VARCHAR,
	"uploaded_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("request_id") REFERENCES "host_verification_requests"("id")
);
CREATE TABLE IF NOT EXISTS "host_verification_requests" (
	"id"	INTEGER NOT NULL,
	"host_user_id"	INTEGER NOT NULL,
	"status"	VARCHAR,
	"submitted_at"	DATETIME,
	"reviewed_at"	DATETIME,
	"reviewed_by_admin_id"	INTEGER,
	"review_reason"	TEXT,
	PRIMARY KEY("id"),
	FOREIGN KEY("host_user_id") REFERENCES "users"("id"),
	FOREIGN KEY("reviewed_by_admin_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "moderation_actions" (
	"id"	INTEGER NOT NULL,
	"report_id"	INTEGER NOT NULL,
	"admin_id"	INTEGER NOT NULL,
	"action"	VARCHAR NOT NULL,
	"reason"	TEXT NOT NULL,
	"created_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("admin_id") REFERENCES "users"("id"),
	FOREIGN KEY("report_id") REFERENCES "safety_reports"("id")
);
CREATE TABLE IF NOT EXISTS "recurrence_rules" (
	"id"	INTEGER NOT NULL,
	"event_id"	INTEGER NOT NULL,
	"frequency"	VARCHAR NOT NULL,
	"interval"	INTEGER,
	"end_date"	DATETIME,
	"count"	INTEGER,
	UNIQUE("event_id"),
	PRIMARY KEY("id"),
	FOREIGN KEY("event_id") REFERENCES "events"("id")
);
CREATE TABLE IF NOT EXISTS "recurrence_weekdays" (
	"id"	INTEGER NOT NULL,
	"rule_id"	INTEGER NOT NULL,
	"weekday"	INTEGER NOT NULL,
	PRIMARY KEY("id"),
	FOREIGN KEY("rule_id") REFERENCES "recurrence_rules"("id")
);
CREATE TABLE IF NOT EXISTS "registrations" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER,
	"event_id"	INTEGER,
	"registered_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("event_id") REFERENCES "events"("id"),
	FOREIGN KEY("user_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "report_evidence" (
	"id"	INTEGER NOT NULL,
	"report_id"	INTEGER NOT NULL,
	"evidence_type"	VARCHAR,
	"content_url"	VARCHAR,
	"content_text"	TEXT,
	"created_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("report_id") REFERENCES "safety_reports"("id")
);
CREATE TABLE IF NOT EXISTS "safety_reports" (
	"id"	INTEGER NOT NULL,
	"reporter_user_id"	INTEGER,
	"reported_user_id"	INTEGER,
	"reported_event_id"	INTEGER,
	"reported_comment_id"	INTEGER,
	"reason"	TEXT NOT NULL,
	"severity"	VARCHAR,
	"status"	VARCHAR,
	"evidence_complete"	BOOLEAN,
	"resolved_at"	DATETIME,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id"),
	FOREIGN KEY("reported_comment_id") REFERENCES "comments"("id"),
	FOREIGN KEY("reported_event_id") REFERENCES "events"("id"),
	FOREIGN KEY("reported_user_id") REFERENCES "users"("id"),
	FOREIGN KEY("reporter_user_id") REFERENCES "users"("id")
);
CREATE TABLE IF NOT EXISTS "tags" (
	"id"	INTEGER NOT NULL,
	"name"	VARCHAR NOT NULL,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "users" (
	"id"	INTEGER NOT NULL,
	"username"	VARCHAR NOT NULL,
	"display_name"	VARCHAR,
	"email"	VARCHAR NOT NULL,
	"hashed_password"	VARCHAR NOT NULL,
	"phone"	VARCHAR,
	"avatar_url"	VARCHAR,
	"role"	VARCHAR,
	"status"	VARCHAR,
	"is_active"	BOOLEAN,
	"created_at"	DATETIME,
	"updated_at"	DATETIME,
	PRIMARY KEY("id")
);
INSERT INTO "alembic_version" VALUES ('0003_add_event_trending');
INSERT INTO "business_profiles" VALUES (1,1,'string','string','string','string',0);
INSERT INTO "business_profiles" VALUES (2,2,'John Events','Organizing networking events and live music experiences.','https://johnevents.com','https://cdn.example.com/logos/johnevents.png',1);
INSERT INTO "business_profiles" VALUES (3,3,'Urban Vibes Events','Professional event organizer specializing in live music festivals, networking events, and cultural experiences across Albania.','https://www.urbanvibesevents.com','https://thumbs.dreamstime.com/b/urban-vibes-text-graffiti-style-brush-strokes-words-rendered-bold-colorful-letters-rough-spiky-stroke-effect-399908160.jpg',1);
INSERT INTO "categories" VALUES (1,'string');
INSERT INTO "categories" VALUES (2,'Music');
INSERT INTO "categories" VALUES (3,'Technology');
INSERT INTO "categories" VALUES (4,'Food & Drink');
INSERT INTO "categories" VALUES (5,'Networking');
INSERT INTO "categories" VALUES (6,'Startups');
INSERT INTO "categories" VALUES (7,'Health');
INSERT INTO "categories" VALUES (8,'Fitness');
INSERT INTO "categories" VALUES (9,'Wellness');
INSERT INTO "categories" VALUES (10,'Outdoor');
INSERT INTO "categories" VALUES (11,'Adventure');
INSERT INTO "categories" VALUES (12,'Business');
INSERT INTO "categories" VALUES (13,'Entertainment');
INSERT INTO "categories" VALUES (14,'Movies');
INSERT INTO "categories" VALUES (15,'Community');
INSERT INTO "categories" VALUES (16,'Photography');
INSERT INTO "categories" VALUES (17,'Art');
INSERT INTO "categories" VALUES (18,'Education');
INSERT INTO "categories" VALUES (19,'Food');
INSERT INTO "categories" VALUES (20,'Culture');
INSERT INTO "categories" VALUES (21,'Festival');
INSERT INTO "categories" VALUES (22,'Sports');
INSERT INTO "categories" VALUES (23,'Nightlife');
INSERT INTO "categories" VALUES (24,'Books');
INSERT INTO "categories" VALUES (25,'tiff');
INSERT INTO "categories" VALUES (26,'stood');
INSERT INTO "categories" VALUES (27,'hiho');
INSERT INTO "comments" VALUES (2,2,7,'Hahahahahahaa','2026-05-21 21:01:31.264963');
INSERT INTO "comments" VALUES (3,2,2,'so excited!','2026-05-22 10:38:56.394574');
INSERT INTO "event_capacities" VALUES (1,1,150,26,1);
INSERT INTO "event_capacities" VALUES (2,2,50,12,1);
INSERT INTO "event_capacities" VALUES (3,3,30,18,1);
INSERT INTO "event_capacities" VALUES (4,4,120,66,1);
INSERT INTO "event_capacities" VALUES (5,5,200,85,0);
INSERT INTO "event_capacities" VALUES (6,6,25,9,1);
INSERT INTO "event_capacities" VALUES (7,7,1000,420,0);
INSERT INTO "event_capacities" VALUES (8,8,700,520,0);
INSERT INTO "event_capacities" VALUES (9,9,900,650,1);
INSERT INTO "event_capacities" VALUES (10,10,3000,2100,1);
INSERT INTO "event_capacities" VALUES (11,11,25,0,0);
INSERT INTO "event_capacities" VALUES (12,12,NULL,0,0);
INSERT INTO "event_categories" VALUES (1,5);
INSERT INTO "event_categories" VALUES (1,6);
INSERT INTO "event_categories" VALUES (1,3);
INSERT INTO "event_categories" VALUES (2,7);
INSERT INTO "event_categories" VALUES (2,9);
INSERT INTO "event_categories" VALUES (2,8);
INSERT INTO "event_categories" VALUES (3,11);
INSERT INTO "event_categories" VALUES (3,10);
INSERT INTO "event_categories" VALUES (3,8);
INSERT INTO "event_categories" VALUES (4,3);
INSERT INTO "event_categories" VALUES (4,5);
INSERT INTO "event_categories" VALUES (4,12);
INSERT INTO "event_categories" VALUES (5,15);
INSERT INTO "event_categories" VALUES (5,13);
INSERT INTO "event_categories" VALUES (5,14);
INSERT INTO "event_categories" VALUES (6,17);
INSERT INTO "event_categories" VALUES (6,16);
INSERT INTO "event_categories" VALUES (6,18);
INSERT INTO "event_categories" VALUES (7,21);
INSERT INTO "event_categories" VALUES (7,20);
INSERT INTO "event_categories" VALUES (7,19);
INSERT INTO "event_categories" VALUES (8,15);
INSERT INTO "event_categories" VALUES (8,22);
INSERT INTO "event_categories" VALUES (9,2);
INSERT INTO "event_categories" VALUES (9,23);
INSERT INTO "event_categories" VALUES (10,2);
INSERT INTO "event_categories" VALUES (10,19);
INSERT INTO "event_categories" VALUES (11,27);
INSERT INTO "event_categories" VALUES (11,26);
INSERT INTO "event_categories" VALUES (11,25);
INSERT INTO "event_locations" VALUES (1,1,'Rruga Ibrahim Rugova, Sky Tower','Sky Tower Conference Hall',41.3275,19.8187,'Tirana');
INSERT INTO "event_locations" VALUES (2,2,'Shëtitorja Taulantia','Durrës Beach Promenade',41.3133,19.4458,'Durrës');
INSERT INTO "event_locations" VALUES (3,3,'Theth National Park','Theth Visitor Center',42.3952,19.7746,'Shkodër');
INSERT INTO "event_locations" VALUES (4,4,'Rruga Ibrahim Rugova','Sky Tower',41.3237,19.8175,'Tirana');
INSERT INTO "event_locations" VALUES (5,5,'Lungomare','Vlora Waterfront',40.4382,19.4897,'Vlorë');
INSERT INTO "event_locations" VALUES (6,6,'Skanderbeg Square','Skanderbeg Square',41.3275,19.8187,'Tirana');
INSERT INTO "event_locations" VALUES (7,7,'Bulevardi Republika','Korçë City Center',40.6186,20.7808,'Korçë');
INSERT INTO "event_locations" VALUES (8,8,'Stadium Bar','Stadium Bar',41.3186,19.8232,'Tirana');
INSERT INTO "event_locations" VALUES (9,9,'Pulse Club','Pulse Club',42.0683,19.5126,'Shkodër');
INSERT INTO "event_locations" VALUES (10,10,'Open Air Stage','Open Air Stage',40.4661,19.4914,'Vlorë');
INSERT INTO "event_locations" VALUES (11,11,'Tirane','Tel Aviv Rinas',41.3252628034962,19.8044491757868,'Tirana');
INSERT INTO "event_locations" VALUES (12,12,'ttttt',NULL,41.4284454662103,19.7117044836606,'rinas');
INSERT INTO "event_tags" VALUES (1,1);
INSERT INTO "event_tags" VALUES (1,2);
INSERT INTO "event_tags" VALUES (1,3);
INSERT INTO "event_tags" VALUES (1,4);
INSERT INTO "event_tags" VALUES (2,5);
INSERT INTO "event_tags" VALUES (2,6);
INSERT INTO "event_tags" VALUES (2,7);
INSERT INTO "event_tags" VALUES (2,8);
INSERT INTO "event_tags" VALUES (2,9);
INSERT INTO "event_tags" VALUES (3,10);
INSERT INTO "event_tags" VALUES (3,11);
INSERT INTO "event_tags" VALUES (3,12);
INSERT INTO "event_tags" VALUES (3,13);
INSERT INTO "event_tags" VALUES (4,2);
INSERT INTO "event_tags" VALUES (4,1);
INSERT INTO "event_tags" VALUES (4,4);
INSERT INTO "event_tags" VALUES (4,14);
INSERT INTO "event_tags" VALUES (5,15);
INSERT INTO "event_tags" VALUES (5,6);
INSERT INTO "event_tags" VALUES (5,16);
INSERT INTO "event_tags" VALUES (5,17);
INSERT INTO "event_tags" VALUES (6,18);
INSERT INTO "event_tags" VALUES (6,19);
INSERT INTO "event_tags" VALUES (6,20);
INSERT INTO "event_tags" VALUES (6,21);
INSERT INTO "event_tags" VALUES (7,22);
INSERT INTO "event_tags" VALUES (7,23);
INSERT INTO "event_tags" VALUES (7,24);
INSERT INTO "event_tags" VALUES (7,25);
INSERT INTO "event_tags" VALUES (7,26);
INSERT INTO "event_tags" VALUES (8,27);
INSERT INTO "event_tags" VALUES (8,28);
INSERT INTO "event_tags" VALUES (8,29);
INSERT INTO "event_tags" VALUES (9,30);
INSERT INTO "event_tags" VALUES (9,31);
INSERT INTO "event_tags" VALUES (9,32);
INSERT INTO "event_tags" VALUES (10,33);
INSERT INTO "event_tags" VALUES (10,24);
INSERT INTO "event_tags" VALUES (10,6);
INSERT INTO "event_tags" VALUES (11,37);
INSERT INTO "event_tags" VALUES (11,38);
INSERT INTO "events" VALUES (1,'Tech Networking Night Tirana','Join local developers, startup founders, and tech enthusiasts for an evening of networking, talks, and drinks.','published','https://images.trvl-media.com/lodging/4000000/3550000/3547700/3547618/badea6c2.jpg?impolicy=resizecrop&rw=575&rh=575&ra=fill','2026-06-15 18:00:00.000000','2026-06-15 21:00:00.000000',10.0,'EUR',1,'Tech Events Albania','2026-05-20 20:03:11.400085','2026-05-20 20:03:11.400085',0);
INSERT INTO "events" VALUES (2,'Sunset Beach Yoga Session','Relax and recharge with a guided yoga session by the beach. Suitable for all experience levels. Please bring a yoga mat and water bottle.','active','https://images.locationscout.net/2017/07/durres-sunset-albania.webp?h=1400&q=80','2026-07-10 17:30:00.000000','2026-07-10 19:00:00.000000',15.0,'EUR',7,'Wellness Albania','2026-05-20 20:04:02.791760','2026-05-20 20:04:02.791760',1);
INSERT INTO "events" VALUES (3,'Weekend Hiking Adventure in Theth','Explore the breathtaking Albanian Alps with a guided hike through Theth National Park. Suitable for intermediate hikers.','active','https://upload.wikimedia.org/wikipedia/commons/4/42/Theth_and_Theth_National_Park%2C_Albania_2017.jpg','2026-08-08 07:00:00.000000','2026-08-08 16:00:00.000000',25.0,'EUR',8,'Albanian Outdoor Club','2026-05-21 14:21:39.089144','2026-05-21 14:21:39.089144',0);
INSERT INTO "events" VALUES (4,'Startup Networking Night Tirana','Meet founders, developers, designers and investors from Albania''s growing startup ecosystem.','active','https://images.unsplash.com/photo-1511578314322-379afb476865','2026-09-03 18:30:00.000000','2026-09-03 22:00:00.000000',10.0,'EUR',11,'Startup Albania','2026-05-21 14:22:09.825205','2026-05-21 14:22:09.825205',0);
INSERT INTO "events" VALUES (5,'Open Air Cinema by the Sea','Enjoy a classic movie under the stars at Vlora''s waterfront. Snacks and drinks available on-site.','active','https://images.unsplash.com/photo-1489599849927-2ee91cede3ba','2026-07-25 20:30:00.000000','2026-07-25 23:00:00.000000',8.0,'EUR',13,'Cinema Albania','2026-05-21 14:22:28.712904','2026-05-21 14:22:28.712904',0);
INSERT INTO "events" VALUES (6,'Street Photography Walk','Capture Tirana''s architecture, markets and urban life while learning composition and storytelling techniques.','active','https://images.unsplash.com/photo-1502920917128-1aa500764cbd','2026-06-21 09:00:00.000000','2026-06-21 12:00:00.000000',12.0,'EUR',14,'Tirana Photography Club','2026-05-21 14:22:43.012299','2026-05-21 14:22:43.012299',0);
INSERT INTO "events" VALUES (7,'Korçë Food & Wine Festival','Taste traditional Albanian cuisine, local wines and craft products while enjoying live music and cultural performances.','active','https://images.unsplash.com/photo-1414235077428-338989a2e8c0','2026-10-17 15:00:00.000000','2026-10-17 23:00:00.000000',20.0,'EUR',20,'Taste Albania','2026-05-21 14:23:00.206087','2026-05-21 14:23:00.206087',1);
INSERT INTO "events" VALUES (8,'UCL Watch Party','Big screen, commentary, and fan chants.','active','https://images.unsplash.com/photo-1518091043644-c1d4457512c6','2026-03-28 20:45:00.000000','2026-03-28 23:00:00.000000',0.0,'EUR',5,'Stadium Bar','2026-05-21 17:21:43.737643','2026-05-21 17:21:43.737643',0);
INSERT INTO "events" VALUES (9,'Techno Rave','Late-night sets with international DJs.','active','https://images.unsplash.com/photo-1492684223066-81342ee5ff30','2026-06-07 22:00:00.000000','2026-06-08 04:00:00.000000',24.0,'EUR',4,'Pulse Club','2026-05-21 17:22:11.943509','2026-05-21 17:22:11.943509',0);
INSERT INTO "events" VALUES (10,'Festa e Birres','Live music, local brews, and street food.','draft','https://images.unsplash.com/photo-1532635241-17e820acc59f','2026-05-02 17:00:00.000000','2026-05-02 23:30:00.000000',12.0,'EUR',3,'Urban Vibes Events','2026-05-21 17:22:33.743777','2026-05-21 23:05:05.042842',0);
INSERT INTO "events" VALUES (11,'goon royale','sonion ring','published','http://192.168.100.8:8000/photos/9d29dd5388714373b21edbe63944f51a.jpg','2026-05-28 20:40:00.000000','2026-05-30 03:40:00.000000',0.0,'EUR',2,NULL,'2026-05-21 18:45:06.545485','2026-05-21 21:17:52.537953',0);
INSERT INTO "events" VALUES (12,'test2','tggvg','published','http://192.168.100.8:8000/photos/2d88dce4cb9d441ab5e6641632030074.jpg','2026-05-23 04:48:00.000000','2026-05-29 04:48:00.000000',3.0,'EUR',2,NULL,'2026-05-21 19:51:10.595629','2026-05-21 19:51:10.595629',0);
INSERT INTO "goer_preference_categories" VALUES (1,1);
INSERT INTO "goer_preference_categories" VALUES (2,2);
INSERT INTO "goer_preference_categories" VALUES (2,3);
INSERT INTO "goer_preference_categories" VALUES (2,4);
INSERT INTO "goer_preferences" VALUES (1,1,'2026-05-20 19:39:32.433594');
INSERT INTO "goer_preferences" VALUES (2,2,'2026-05-20 19:43:33.723232');
INSERT INTO "goer_preferences" VALUES (3,3,'2026-05-21 20:55:12.203538');
INSERT INTO "host_credibility" VALUES (1,1,0.0,0,1);
INSERT INTO "host_credibility" VALUES (2,2,4.8,125,0);
INSERT INTO "host_credibility" VALUES (3,3,4.8,127,1);
INSERT INTO "recurrence_rules" VALUES (1,1,'weekly',1,'2026-08-31 23:59:59.000000',12);
INSERT INTO "recurrence_rules" VALUES (2,2,'weekly',1,'2026-09-25 19:00:00.000000',12);
INSERT INTO "recurrence_rules" VALUES (3,3,'monthly',1,'2026-12-31 23:59:59.000000',5);
INSERT INTO "recurrence_rules" VALUES (4,4,'monthly',1,'2027-03-01 00:00:00.000000',6);
INSERT INTO "recurrence_rules" VALUES (5,5,'weekly',2,'2026-09-30 23:59:59.000000',6);
INSERT INTO "recurrence_rules" VALUES (6,6,'weekly',1,'2026-08-30 23:59:59.000000',10);
INSERT INTO "recurrence_rules" VALUES (7,7,'yearly',1,'2026-10-17 23:00:00.000000',1);
INSERT INTO "recurrence_weekdays" VALUES (1,1,3);
INSERT INTO "recurrence_weekdays" VALUES (2,2,5);
INSERT INTO "recurrence_weekdays" VALUES (3,3,6);
INSERT INTO "recurrence_weekdays" VALUES (4,4,4);
INSERT INTO "recurrence_weekdays" VALUES (5,5,6);
INSERT INTO "recurrence_weekdays" VALUES (6,6,0);
INSERT INTO "recurrence_weekdays" VALUES (7,7,6);
INSERT INTO "registrations" VALUES (1,2,1,'2026-05-21 20:55:30.608578');
INSERT INTO "tags" VALUES (1,'tech');
INSERT INTO "tags" VALUES (2,'startup');
INSERT INTO "tags" VALUES (3,'developers');
INSERT INTO "tags" VALUES (4,'business');
INSERT INTO "tags" VALUES (5,'yoga');
INSERT INTO "tags" VALUES (6,'outdoor');
INSERT INTO "tags" VALUES (7,'beach');
INSERT INTO "tags" VALUES (8,'wellness');
INSERT INTO "tags" VALUES (9,'community');
INSERT INTO "tags" VALUES (10,'hiking');
INSERT INTO "tags" VALUES (11,'nature');
INSERT INTO "tags" VALUES (12,'mountains');
INSERT INTO "tags" VALUES (13,'weekend');
INSERT INTO "tags" VALUES (14,'entrepreneurship');
INSERT INTO "tags" VALUES (15,'cinema');
INSERT INTO "tags" VALUES (16,'movie-night');
INSERT INTO "tags" VALUES (17,'summer');
INSERT INTO "tags" VALUES (18,'photography');
INSERT INTO "tags" VALUES (19,'street');
INSERT INTO "tags" VALUES (20,'camera');
INSERT INTO "tags" VALUES (21,'creative');
INSERT INTO "tags" VALUES (22,'food');
INSERT INTO "tags" VALUES (23,'wine');
INSERT INTO "tags" VALUES (24,'festival');
INSERT INTO "tags" VALUES (25,'music');
INSERT INTO "tags" VALUES (26,'culture');
INSERT INTO "tags" VALUES (27,'ucl');
INSERT INTO "tags" VALUES (28,'football');
INSERT INTO "tags" VALUES (29,'watch-party');
INSERT INTO "tags" VALUES (30,'techno');
INSERT INTO "tags" VALUES (31,'rave');
INSERT INTO "tags" VALUES (32,'dj');
INSERT INTO "tags" VALUES (33,'beer');
INSERT INTO "tags" VALUES (34,'books');
INSERT INTO "tags" VALUES (35,'fair');
INSERT INTO "tags" VALUES (36,'authors');
INSERT INTO "tags" VALUES (37,'tahi');
INSERT INTO "tags" VALUES (38,'po');
INSERT INTO "users" VALUES (1,'string','string','user@example.com','$bcrypt-sha256$v=2,t=2b,r=12$JpMnF8I4cYeGPqFR5m4VQ.$SmVbHFYMw0M15duHUebkAt8tHoUiBfq','string','string','goer','active',1,'2026-05-20 19:39:32.431596','2026-05-20 19:39:32.431596');
INSERT INTO "users" VALUES (2,'johndoe','John Doe','john.doe@example.com','$bcrypt-sha256$v=2,t=2b,r=12$fLb9xFi66aIotdW8FznTg.$Lh5C8XUDyqTrgqMJoCUNk6NkUrfNVP.','+355691234567','https://cdn.example.com/avatars/johndoe.jpg','goer','active',1,'2026-05-20 19:43:33.722232','2026-05-20 19:43:33.722232');
INSERT INTO "users" VALUES (3,'urbanvibes_events','Urban Vibes Events','contact@uv.com','$bcrypt-sha256$v=2,t=2b,r=12$dY2hs7fDfGhoVaPb4RnzRu$uYXqia7xQRs2t2LrySmTKXT2qGCmUGW','+355691234567','https://thumbs.dreamstime.com/b/urban-vibes-text-graffiti-style-brush-strokes-words-rendered-bold-colorful-letters-rough-spiky-stroke-effect-399908160.jpg','business','active',1,'2026-05-21 20:55:12.192772','2026-05-21 20:55:12.192772');
INSERT INTO "users" VALUES (4,'admin_master','System Administrator','admin@admin.com','$bcrypt-sha256$v=2,t=2b,r=12$VnHptCDG9qGXEkQ/.yLA5O$30ZWaOT9Ussjtx41.ek1pF1QnRSQr5O','+355692223344','https://cdn.example.com/avatars/admin-avatar.png','admin','active',1,'2026-05-21 23:24:54.524035','2026-05-21 23:24:54.524035');
CREATE INDEX IF NOT EXISTS "ix_admin_audit_logs_id" ON "admin_audit_logs" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_business_profiles_id" ON "business_profiles" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_categories_id" ON "categories" (
	"id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_categories_name" ON "categories" (
	"name"
);
CREATE INDEX IF NOT EXISTS "ix_comments_id" ON "comments" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_dispute_cases_id" ON "dispute_cases" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_dispute_evidence_id" ON "dispute_evidence" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_event_capacities_id" ON "event_capacities" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_event_locations_id" ON "event_locations" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_events_id" ON "events" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_global_notifications_id" ON "global_notifications" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_goer_preferences_id" ON "goer_preferences" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_host_credibility_id" ON "host_credibility" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_host_verification_documents_id" ON "host_verification_documents" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_host_verification_requests_id" ON "host_verification_requests" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_moderation_actions_id" ON "moderation_actions" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_recurrence_rules_id" ON "recurrence_rules" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_recurrence_weekdays_id" ON "recurrence_weekdays" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_registrations_id" ON "registrations" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_report_evidence_id" ON "report_evidence" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_safety_reports_id" ON "safety_reports" (
	"id"
);
CREATE INDEX IF NOT EXISTS "ix_tags_id" ON "tags" (
	"id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_tags_name" ON "tags" (
	"name"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_users_email" ON "users" (
	"email"
);
CREATE INDEX IF NOT EXISTS "ix_users_id" ON "users" (
	"id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "ix_users_username" ON "users" (
	"username"
);
COMMIT;
