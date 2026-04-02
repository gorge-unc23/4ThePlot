# EventApp: Use Cases

This document defines how the system interacts with users to satisfy each goal from the scenarios list.

## Goer Use Cases

### UC-GO-01: Follow Preferred Categories

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-01 Follow Preferred Categories |
| Summary | A goer selects favorite categories so the discovery feed shows more relevant events. |
| Dependency | GO-01 (Follow Preferred Categories) |
| Actors | Primary: Goer. Secondary: Recommendation Service. |
| Preconditions | Goer is logged in and category catalog is available. |
| Description of the Main Sequence | 1. Goer opens preferences.<br>2. System shows available categories.<br>3. Goer selects categories and saves.<br>4. System stores preferences.<br>5. System refreshes personalized discovery results. |
| Description of the Alternative Sequence | A1. If no category is selected, system asks for at least one selection.<br>A2. If save fails, system shows an error and keeps old preferences. |
| Non functional requirements | Save action responds in less than 2 seconds; preference data is encrypted in transit. |
| Postconditions | Goer category preferences are saved and personalization is updated. |

### UC-GO-02: Check Host Credibility

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-02 Check Host Credibility |
| Summary | A goer reviews host ratings and feedback before joining an event. |
| Dependency | GO-02 (Check Host Credibility) |
| Actors | Primary: Goer. Secondary: Review Service. |
| Preconditions | Goer is viewing an event page and host profile exists. |
| Description of the Main Sequence | 1. Goer opens host profile from event page.<br>2. System shows host rating, review count, and recent feedback.<br>3. Goer reads reviews and returns to event page.<br>4. Goer decides whether to join. |
| Description of the Alternative Sequence | A1. If no reviews exist, system shows "No reviews yet" message.<br>A2. If review service is unavailable, system shows temporary warning. |
| Non functional requirements | Profile and review data loads in less than 3 seconds; displayed reviews must exclude blocked content. |
| Postconditions | Goer has enough trust information to make a join decision. |

### UC-GO-03: Enter Waitlist for Sold-Out Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-03 Enter Waitlist for Sold-Out Event |
| Summary | A goer joins a waitlist when an event has reached capacity. |
| Dependency | GO-03 (Enter Waitlist for Sold-Out Event) |
| Actors | Primary: Goer. Secondary: Waitlist Service, Notification Service. |
| Preconditions | Event is marked sold out and goer is logged in. |
| Description of the Main Sequence | 1. Goer opens sold-out event page.<br>2. System shows Join Waitlist option.<br>3. Goer confirms waitlist enrollment.<br>4. System adds goer to queue with timestamp.<br>5. System sends confirmation notification. |
| Description of the Alternative Sequence | A1. If goer is already waitlisted, system informs and does not duplicate entry.<br>A2. If waitlist is closed, system shows closure reason. |
| Non functional requirements | Waitlist join must be atomic to avoid duplicate positions; confirmation should be sent in less than 30 seconds. |
| Postconditions | Goer is placed in waitlist queue and can be notified when a spot opens. |

### UC-GO-04: Use Map for Directions

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-04 Use Map for Directions |
| Summary | A goer opens event location in a map app for navigation. |
| Dependency | GO-04 (Use Map for Directions) |
| Actors | Primary: Goer. Secondary: Map Provider API. |
| Preconditions | Event has valid location data and goer can access map services. |
| Description of the Main Sequence | 1. Goer opens event details.<br>2. Goer taps event address.<br>3. System sends coordinates/address to map provider.<br>4. Map app opens with route options. |
| Description of the Alternative Sequence | A1. If location is invalid, system shows error and fallback text address.<br>A2. If map app is unavailable, system copies address for manual use. |
| Non functional requirements | Map handoff should happen in less than 2 seconds; location data accuracy should meet provider geocoding standards. |
| Postconditions | Goer receives route guidance to the event location. |

### UC-GO-05: Share Event with Friends

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-05 Share Event with Friends |
| Summary | A goer shares event details through a generated invite link. |
| Dependency | GO-05 (Share Event with Friends) |
| Actors | Primary: Goer. Secondary: Share Service, Link Generator. |
| Preconditions | Event is visible and share permissions are enabled. |
| Description of the Main Sequence | 1. Goer taps Share on event page.<br>2. System generates shareable link.<br>3. Goer selects target app or contact.<br>4. System sends event link and summary. |
| Description of the Alternative Sequence | A1. If link generation fails, system retries and shows fallback copy option.<br>A2. If privacy settings block sharing, system explains restriction. |
| Non functional requirements | Generated link must be unique and secure; link creation should complete in less than 1 second. |
| Postconditions | Event link is shared and recipients can open event details. |

### UC-GO-06: Save Event Draft

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-06 Save Event Draft |
| Summary | A goer organizer saves incomplete event details as a draft for later editing. |
| Dependency | GO-06 (Save Event Draft) |
| Actors | Primary: Goer Organizer. Secondary: Event Service. |
| Preconditions | Goer organizer is authenticated and event creation form is open. |
| Description of the Main Sequence | 1. Goer organizer enters partial event details.<br>2. Goer organizer selects Save as Draft.<br>3. System validates minimum required draft fields.<br>4. System stores draft with Draft status.<br>5. System confirms draft was saved. |
| Description of the Alternative Sequence | A1. If required draft fields are missing, system highlights missing fields.<br>A2. If save fails, system keeps data on page and prompts retry. |
| Non functional requirements | Draft save should complete in less than 2 seconds; unsaved form data should be protected from accidental loss. |
| Postconditions | Draft event exists and can be edited and published later. |

### UC-GO-07: Limit Event Capacity

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-07 Limit Event Capacity |
| Summary | A goer organizer sets a maximum attendee count for event control. |
| Dependency | GO-07 (Limit Event Capacity) |
| Actors | Primary: Goer Organizer. Secondary: Registration Service. |
| Preconditions | Goer organizer is editing a draft or published event. |
| Description of the Main Sequence | 1. Goer organizer opens event settings.<br>2. Goer organizer enters capacity value.<br>3. System validates value range.<br>4. System saves capacity.<br>5. Registration closes automatically when limit is reached. |
| Description of the Alternative Sequence | A1. If capacity is lower than current joins, system asks to confirm and explains impact.<br>A2. If invalid number is entered, system rejects and shows rules. |
| Non functional requirements | Capacity checks on joins must be real-time; no oversubscription is allowed. |
| Postconditions | Event has enforced attendee limit and join behavior follows that limit. |

### UC-GO-08: Broadcast Update to Attendees

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-08 Broadcast Update to Attendees |
| Summary | A goer organizer sends one update message to all joined participants. |
| Dependency | GO-08 (Broadcast Update to Attendees) |
| Actors | Primary: Goer Organizer. Secondary: Messaging Service, Notification Service. |
| Preconditions | Event has at least one joined attendee and organizer owns the event. |
| Description of the Main Sequence | 1. Goer organizer opens attendee communication tool.<br>2. Organizer composes broadcast message.<br>3. Organizer sends message.<br>4. System delivers in-app notification to joined attendees.<br>5. System logs delivery status. |
| Description of the Alternative Sequence | A1. If message exceeds allowed length, system prompts organizer to shorten it.<br>A2. If some deliveries fail, system reports failed recipients and allows retry. |
| Non functional requirements | Broadcast should reach 95 percent of attendees in less than 60 seconds; message delivery logs must be auditable. |
| Postconditions | Attendees receive event update and system records message status. |

### UC-GO-09: Set Recurring Schedule

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-09 Set Recurring Schedule |
| Summary | A goer organizer configures one event to repeat weekly or monthly. |
| Dependency | GO-09 (Set Recurring Schedule) |
| Actors | Primary: Goer Organizer. Secondary: Scheduling Service. |
| Preconditions | Organizer is creating or editing an event and recurrence options are enabled. |
| Description of the Main Sequence | 1. Organizer opens recurrence settings.<br>2. Organizer chooses frequency and end condition.<br>3. System previews generated instances.<br>4. Organizer confirms recurrence rule.<br>5. System creates recurring event instances. |
| Description of the Alternative Sequence | A1. If selected dates conflict with blocked dates, system flags conflicts and asks for adjustment.<br>A2. If recurrence rule is invalid, system prevents save. |
| Non functional requirements | Instance generation should scale for at least 12 months of recurrence; schedule generation must be consistent across time zones. |
| Postconditions | Recurrence rule is stored and future event instances are available. |

### UC-GO-10: Review Event Performance

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-10 Review Event Performance |
| Summary | A goer organizer reviews views versus joins after an event. |
| Dependency | GO-10 (Review Event Performance) |
| Actors | Primary: Goer Organizer. Secondary: Analytics Service. |
| Preconditions | Event has analytics data and organizer has permission to view it. |
| Description of the Main Sequence | 1. Organizer opens event analytics panel.<br>2. System displays total views, joins, and conversion rate.<br>3. Organizer filters by date or traffic source.<br>4. System refreshes chart and summary metrics. |
| Description of the Alternative Sequence | A1. If data is still processing, system shows pending status.<br>A2. If date range has no data, system shows zero-state analytics. |
| Non functional requirements | Dashboard queries should return in less than 3 seconds for standard date ranges; analytics must follow data privacy rules. |
| Postconditions | Organizer sees event performance metrics and can use them for planning. |

## Business Use Cases

### UC-BIZ-01: Promote Event Placement

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-01 Promote Event Placement |
| Summary | A business pays to boost event ranking for selected audiences. |
| Dependency | BIZ-01 (Promote Event Placement) |
| Actors | Primary: Business User. Secondary: Billing Service, Ad Placement Engine. |
| Preconditions | Business account is verified, payment method exists, and event is eligible for promotion. |
| Description of the Main Sequence | 1. Business user selects Promote Event.<br>2. System asks for target audience, duration, and budget.<br>3. Business user confirms settings and payment.<br>4. Billing service authorizes payment.<br>5. Ad placement engine activates campaign and updates feed rank. |
| Description of the Alternative Sequence | A1. If payment fails, system cancels activation and asks for another payment method.<br>A2. If policy validation fails, system blocks campaign and explains violation. |
| Non functional requirements | Payment processing must be PCI-compliant; campaign activation should complete in less than 2 minutes. |
| Postconditions | Promotion campaign is active and event receives boosted visibility. |

### UC-BIZ-02: Build Branded Profile

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-02 Build Branded Profile |
| Summary | A business creates or updates a brand profile with public links and identity details. |
| Dependency | BIZ-02 (Build Branded Profile) |
| Actors | Primary: Business User. Secondary: Profile Service, Media Storage. |
| Preconditions | Business user is authenticated and has profile edit permission. |
| Description of the Main Sequence | 1. Business user opens profile editor.<br>2. User uploads logo and cover image.<br>3. User adds website and social links.<br>4. System validates link format and saves profile.<br>5. Updated profile appears publicly. |
| Description of the Alternative Sequence | A1. If uploaded media is invalid, system rejects file and shows format constraints.<br>A2. If a link is malformed, system highlights the field and blocks save. |
| Non functional requirements | Profile updates should publish in less than 10 seconds; uploaded assets must be malware-scanned. |
| Postconditions | Branded profile is updated and visible to goers. |

### UC-BIZ-03: Capture Leads from Attendees

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-03 Capture Leads from Attendees |
| Summary | A business offers downloadable resources or coupons to collect qualified leads. |
| Dependency | BIZ-03 (Capture Leads from Attendees) |
| Actors | Primary: Business User. Secondary: Lead Form Service, Email Service. |
| Preconditions | Business event is published and lead offer is configured. |
| Description of the Main Sequence | 1. Business user creates a lead offer for event attendees.<br>2. Attendee submits contact details through lead form.<br>3. System validates consent and submission.<br>4. System delivers resource or coupon to attendee.<br>5. System records lead in business dashboard. |
| Description of the Alternative Sequence | A1. If consent is missing, system blocks submission.<br>A2. If delivery fails, system retries and logs failure for follow-up. |
| Non functional requirements | Lead data must comply with privacy law; form submission should complete in less than 2 seconds. |
| Postconditions | Valid lead is stored and business can track lead conversion. |

### UC-BIZ-04: Co-Host with Partners

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-04 Co-Host with Partners |
| Summary | A business invites partner hosts for cross-promotion of a shared event. |
| Dependency | BIZ-04 (Co-Host with Partners) |
| Actors | Primary: Business User. Secondary: Partner Host, Notification Service. |
| Preconditions | Business event exists and partner account is discoverable. |
| Description of the Main Sequence | 1. Business user opens partner section in event editor.<br>2. User searches and selects partner host.<br>3. System sends co-host invitation.<br>4. Partner host accepts invitation.<br>5. System marks both accounts as co-hosts and shares event visibility. |
| Description of the Alternative Sequence | A1. If partner declines, system keeps original host only.<br>A2. If partner account is invalid, system blocks invitation. |
| Non functional requirements | Invitation delivery should complete in less than 30 seconds; co-host permissions must follow role-based access rules. |
| Postconditions | Event is linked to accepted co-hosts for shared promotion. |

### UC-BIZ-05: Measure Ad Conversion ROI

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-05 Measure Ad Conversion ROI |
| Summary | A business compares ad spend and joins to evaluate campaign returns. |
| Dependency | BIZ-05 (Measure Ad Conversion ROI) |
| Actors | Primary: Business User. Secondary: Analytics Service, Billing Service. |
| Preconditions | Campaign has active or historical spend and event join data exists. |
| Description of the Main Sequence | 1. Business user opens campaign analytics dashboard.<br>2. System displays spend, impressions, clicks, and joins.<br>3. System calculates conversion and ROI metrics.<br>4. User applies filters by date and audience segment.<br>5. System refreshes metric views. |
| Description of the Alternative Sequence | A1. If spend data sync is delayed, system flags report as partial.<br>A2. If selected period has no campaign data, system shows empty-state report. |
| Non functional requirements | Report generation should complete in less than 5 seconds; financial metrics must be accurate and auditable. |
| Postconditions | Business can assess campaign performance and adjust budget strategy. |

### UC-BIZ-06: Save Event Draft

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-06 Save Event Draft |
| Summary | A business organizer saves an unfinished event before final approval. |
| Dependency | BIZ-06 (Save Event Draft) |
| Actors | Primary: Business Organizer. Secondary: Event Service. |
| Preconditions | Business organizer is authenticated and editing an event form. |
| Description of the Main Sequence | 1. Organizer enters partial event details.<br>2. Organizer clicks Save as Draft.<br>3. System validates minimum draft fields.<br>4. System stores draft with owner and timestamp.<br>5. System confirms draft availability for later editing. |
| Description of the Alternative Sequence | A1. If required fields for draft are missing, system highlights fields.<br>A2. If save fails, system retains local input and prompts retry. |
| Non functional requirements | Draft save should finish in less than 2 seconds; autosave fallback should prevent data loss. |
| Postconditions | Draft event is stored and not publicly visible. |

### UC-BIZ-07: Control Event Capacity

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-07 Control Event Capacity |
| Summary | A business organizer defines attendee limit for operational control and safety. |
| Dependency | BIZ-07 (Control Event Capacity) |
| Actors | Primary: Business Organizer. Secondary: Registration Service. |
| Preconditions | Event exists and organizer has edit rights. |
| Description of the Main Sequence | 1. Organizer opens ticketing and capacity settings.<br>2. Organizer sets maximum attendee value.<br>3. System validates and saves the value.<br>4. Registration service enforces limit during joins. |
| Description of the Alternative Sequence | A1. If new limit is below confirmed joins, system asks for override confirmation.<br>A2. If value exceeds platform maximum, system rejects input. |
| Non functional requirements | Capacity enforcement must be transactional to prevent race-condition overbooking. |
| Postconditions | Event capacity is enforced consistently for new join attempts. |

### UC-BIZ-08: Send Bulk Attendee Notice

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-08 Send Bulk Attendee Notice |
| Summary | A business organizer sends one update to all joined goers. |
| Dependency | BIZ-08 (Send Bulk Attendee Notice) |
| Actors | Primary: Business Organizer. Secondary: Messaging Service, Notification Service. |
| Preconditions | Event has joined attendees and organizer communication permissions are active. |
| Description of the Main Sequence | 1. Organizer opens attendee messaging panel.<br>2. Organizer writes update message.<br>3. Organizer clicks Send to All.<br>4. System distributes notifications to joined goers.<br>5. System reports delivery summary. |
| Description of the Alternative Sequence | A1. If message content violates moderation rules, system blocks send and shows reason.<br>A2. If partial delivery fails, system queues retry for failed recipients. |
| Non functional requirements | Bulk send should process large attendee groups without timeout; message logs must be retained for audit. |
| Postconditions | Joined attendees receive update and send activity is recorded. |

### UC-BIZ-09: Run Recurring Campaign Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-09 Run Recurring Campaign Event |
| Summary | A business creates recurring event instances for repeating campaigns. |
| Dependency | BIZ-09 (Run Recurring Campaign Event) |
| Actors | Primary: Business Organizer. Secondary: Scheduling Service. |
| Preconditions | Organizer has an editable event and recurrence feature is enabled. |
| Description of the Main Sequence | 1. Organizer selects recurring setup.<br>2. Organizer defines frequency, interval, and end rule.<br>3. System validates recurrence input.<br>4. System previews upcoming event instances.<br>5. Organizer confirms and system creates recurring schedule. |
| Description of the Alternative Sequence | A1. If recurrence conflicts with blackout dates, system asks for date adjustments.<br>A2. If generated instances exceed platform limit, system asks for shorter period. |
| Non functional requirements | Recurring instance generation should complete in less than 5 seconds for 100 instances; timezone handling must be deterministic. |
| Postconditions | Recurring campaign events are created and visible in organizer dashboard. |

### UC-BIZ-10: Analyze Post-Event Results

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-10 Analyze Post-Event Results |
| Summary | A business organizer reviews view-to-join performance after event completion. |
| Dependency | BIZ-10 (Analyze Post-Event Results) |
| Actors | Primary: Business Organizer. Secondary: Analytics Service. |
| Preconditions | Event has completed and analytics data is available. |
| Description of the Main Sequence | 1. Organizer opens post-event report page.<br>2. System shows views, joins, conversion rate, and trend chart.<br>3. Organizer applies segment filters.<br>4. System recalculates and displays filtered metrics.<br>5. Organizer exports summary for internal reporting. |
| Description of the Alternative Sequence | A1. If analytics data is delayed, system marks report as processing.<br>A2. If export fails, system allows retry and logs error. |
| Non functional requirements | Analytics metrics should have daily data freshness; report views should load in less than 3 seconds. |
| Postconditions | Business organizer obtains actionable performance insight for future campaigns. |

## Admin Use Cases

### UC-ADM-01: Process Safety Reports

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-01 Process Safety Reports |
| Summary | An admin reviews flagged content and takes moderation action. |
| Dependency | ADM-01 (Process Safety Reports) |
| Actors | Primary: Admin. Secondary: Moderation Queue Service. |
| Preconditions | Admin is authenticated with moderation permissions and reports exist. |
| Description of the Main Sequence | 1. Admin opens moderation queue.<br>2. System lists reported events ordered by severity and time.<br>3. Admin opens a report and reviews evidence.<br>4. Admin chooses action (remove, warn, dismiss).<br>5. System applies action and logs decision. |
| Description of the Alternative Sequence | A1. If report lacks evidence, admin requests more information.<br>A2. If content owner appeals, system opens appeal workflow. |
| Non functional requirements | Queue loading should complete in less than 3 seconds; all moderation actions must be audit logged. |
| Postconditions | Report is resolved with documented moderation outcome. |

### UC-ADM-02: Approve Verified Hosts

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-02 Approve Verified Hosts |
| Summary | An admin grants verified status to trusted professional hosts. |
| Dependency | ADM-02 (Approve Verified Hosts) |
| Actors | Primary: Admin. Secondary: Verification Service. |
| Preconditions | Host has submitted verification request and required documents. |
| Description of the Main Sequence | 1. Admin opens verification requests dashboard.<br>2. System displays host profile and submitted documents.<br>3. Admin checks authenticity criteria.<br>4. Admin approves request.<br>5. System assigns verified badge and notifies host. |
| Description of the Alternative Sequence | A1. If documents are incomplete, admin marks request as pending and asks for more documents.<br>A2. If request is fraudulent, admin rejects and flags account. |
| Non functional requirements | Document access must be permission-restricted; verification decision log must be immutable. |
| Postconditions | Host verification status is updated and visible across the platform. |

### UC-ADM-03: Publish Global Notification

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-03 Publish Global Notification |
| Summary | An admin publishes a system-wide banner for important platform updates. |
| Dependency | ADM-03 (Publish Global Notification) |
| Actors | Primary: Admin. Secondary: Notification Service. |
| Preconditions | Admin has broadcast permission and announcement content is prepared. |
| Description of the Main Sequence | 1. Admin opens global announcement panel.<br>2. Admin enters title, message, start time, and end time.<br>3. System validates schedule and content.<br>4. Admin publishes announcement.<br>5. System displays banner to all active users. |
| Description of the Alternative Sequence | A1. If schedule is invalid, system blocks publish and highlights date issue.<br>A2. If content violates policy, system requests edits before publishing. |
| Non functional requirements | Announcement propagation should complete in less than 60 seconds platform-wide; banner display must be responsive on mobile and desktop. |
| Postconditions | Active global banner is visible to users during scheduled time window. |

### UC-ADM-04: Review Dispute Evidence

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-04 Review Dispute Evidence |
| Summary | An admin checks host-goer chat evidence to resolve refund disputes fairly. |
| Dependency | ADM-04 (Review Dispute Evidence) |
| Actors | Primary: Admin. Secondary: Chat Log Service, Dispute Service. |
| Preconditions | Dispute ticket exists and related conversation logs are available. |
| Description of the Main Sequence | 1. Admin opens dispute ticket.<br>2. System loads event details and chat transcript.<br>3. Admin reviews timeline and policy rules.<br>4. Admin records resolution decision.<br>5. System notifies both parties and stores decision rationale. |
| Description of the Alternative Sequence | A1. If chat logs are incomplete, admin requests additional evidence from parties.<br>A2. If policy is unclear, admin escalates case to senior moderation. |
| Non functional requirements | Sensitive chat data must be access-controlled and encrypted; decision history must be traceable. |
| Postconditions | Dispute is resolved, communicated, and archived with supporting evidence. |

### UC-ADM-05: Monitor Platform Growth

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-05 Monitor Platform Growth |
| Summary | An admin reviews daily active users and new event creation trends. |
| Dependency | ADM-05 (Monitor Platform Growth) |
| Actors | Primary: Admin. Secondary: Metrics Service, Reporting Service. |
| Preconditions | Admin has analytics access and daily metrics pipeline is running. |
| Description of the Main Sequence | 1. Admin opens growth dashboard.<br>2. System shows DAU, new events, and trend comparisons.<br>3. Admin selects date range and segment filters.<br>4. System updates charts and KPI cards.<br>5. Admin saves or exports report snapshot. |
| Description of the Alternative Sequence | A1. If metric source is delayed, system labels values as provisional.<br>A2. If selected range is too large, system prompts narrower range. |
| Non functional requirements | Dashboard interactions should stay under 3-second response for standard filters; metrics integrity checks must run daily. |
| Postconditions | Admin obtains an updated growth view to support planning and decision-making. |
