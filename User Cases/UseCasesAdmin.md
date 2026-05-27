## Admin Use Cases

### UC-ADM-01: View Admin Dashboard

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-01 View Admin Dashboard |
| Summary | An admin views the dashboard tiles and operational metrics. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Admin. Secondary: Metrics Service. |
| Preconditions | User is authenticated with the Admin role. |
| Description of the Main Sequence | 1. Admin logs in.<br>2. System opens the Admin tab as the first screen.<br>3. System loads pending reports, host requests, new users, and new events metrics.<br>4. Admin taps a dashboard tile to open an admin workflow. |
| Description of the Alternative Sequence | A1. If metrics fail to load, system shows an admin error state with retry.<br>A2. If no metric values exist, counters show zero. |
| Non functional requirements | Dashboard tiles must remain tappable and readable on mobile screens. |
| Postconditions | Admin can navigate to moderation, verification, notification, metrics, dispute, audit, or event screens. |

### UC-ADM-02: View and Manage Events

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-02 View and Manage Events |
| Summary | An admin views all events from the admin event moderation screen. |
| Dependency | UC-ADM-01 (View Admin Dashboard) |
| Actors | Primary: Admin. Secondary: Event Listing Service. |
| Preconditions | Admin opens Event Moderation from dashboard or the Events tab. |
| Description of the Main Sequence | 1. Admin opens the Events admin screen.<br>2. System loads all events.<br>3. Admin reviews event cards or list rows.<br>4. Admin opens event details or chooses a moderation action available in the screen. |
| Description of the Alternative Sequence | A1. If no events exist, system shows an empty state.<br>A2. If loading fails, system shows an error and retry action. |
| Non functional requirements | Admin event lists should bypass stale cached data when moderation accuracy matters. |
| Postconditions | Admin can inspect or remove events from the admin UI. |

### UC-ADM-03: Delete Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-03 Delete Event |
| Summary | An admin deletes an event from an admin-visible event flow. |
| Dependency | UC-ADM-02 (View and Manage Events) |
| Actors | Primary: Admin. Secondary: Event Service, Audit Log Service. |
| Preconditions | Admin is viewing an event in the admin events page or event details page. |
| Description of the Main Sequence | 1. Admin selects a delete event action.<br>2. System asks for confirmation where the UI provides it.<br>3. Admin confirms deletion.<br>4. System removes the event.<br>5. System refreshes the visible event list or returns from details. |
| Description of the Alternative Sequence | A1. If admin cancels, the event remains visible.<br>A2. If deletion fails, system shows an error message. |
| Non functional requirements | Deletion should be auditable and show progress while active. |
| Postconditions | The deleted event is removed from admin event lists after refresh. |

### UC-ADM-04: Review Safety Reports

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-04 Review Safety Reports |
| Summary | An admin reviews safety reports submitted by users. |
| Dependency | UC-ADM-01 (View Admin Dashboard) |
| Actors | Primary: Admin. Secondary: Safety Report Service. |
| Preconditions | Admin opens Safety Reports from the dashboard. |
| Description of the Main Sequence | 1. Admin opens Safety Reports.<br>2. System loads reports with status and severity filters.<br>3. Admin filters by status or severity.<br>4. Admin taps a report card.<br>5. System opens report details with reporter, target, reason, evidence, and actions. |
| Description of the Alternative Sequence | A1. If no reports match filters, system shows No safety reports found.<br>A2. If report loading fails, system shows an error and retry action. |
| Non functional requirements | Filters should refresh report results without leaving the screen. |
| Postconditions | Admin has report context for moderation decisions. |

### UC-ADM-05: Apply Moderation Action

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-05 Apply Moderation Action |
| Summary | An admin applies a visible moderation action from report details. |
| Dependency | UC-ADM-04 (Review Safety Reports) |
| Actors | Primary: Admin. Secondary: Moderation Service, Audit Log Service. |
| Preconditions | Admin is viewing a report details page. |
| Description of the Main Sequence | 1. Admin selects a moderation action such as warn, suspend, deactivate event, delete comment, or dismiss where available.<br>2. System asks for an admin reason.<br>3. Admin enters the reason and confirms.<br>4. System applies the moderation action.<br>5. System refreshes the report details and action history. |
| Description of the Alternative Sequence | A1. If admin cancels the reason dialog, no action is applied.<br>A2. If action fails, system shows an error and leaves the report unchanged. |
| Non functional requirements | Every moderation action must require a reason and be audit logged. |
| Postconditions | Report contains the moderation action result and updated status where applicable. |

### UC-ADM-06: Update Report Status

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-06 Update Report Status |
| Summary | An admin changes the status of a safety report from report details. |
| Dependency | UC-ADM-04 (Review Safety Reports) |
| Actors | Primary: Admin. Secondary: Safety Report Service, Audit Log Service. |
| Preconditions | Admin is viewing a report details page. |
| Description of the Main Sequence | 1. Admin taps the update status action.<br>2. System asks for a reason.<br>3. Admin enters the reason and confirms the selected status.<br>4. System updates the report status.<br>5. System reloads the report details. |
| Description of the Alternative Sequence | A1. If the reason is cancelled or empty, system does not update status.<br>A2. If update fails, system shows an error. |
| Non functional requirements | Status updates must be traceable through audit logs. |
| Postconditions | The report displays the updated status. |

### UC-ADM-07: Review Host Verification Requests

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-07 Review Host Verification Requests |
| Summary | An admin reviews submitted host verification requests. |
| Dependency | UC-ADM-01 (View Admin Dashboard) |
| Actors | Primary: Admin. Secondary: Verification Service. |
| Preconditions | Admin opens Host Verification from the dashboard. |
| Description of the Main Sequence | 1. Admin opens Host Verification.<br>2. System loads submitted requests.<br>3. Admin filters requests by status where available.<br>4. Admin taps a request.<br>5. System opens request details with host and document information. |
| Description of the Alternative Sequence | A1. If no requests exist, system shows an empty state.<br>A2. If loading fails, system shows an error and retry option. |
| Non functional requirements | Verification request lists should show status clearly for quick scanning. |
| Postconditions | Admin can inspect request details before a decision. |

### UC-ADM-08: Review Host Verification Details

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-08 Review Host Verification Details |
| Summary | An admin inspects host verification documents and request context. |
| Dependency | UC-ADM-07 (Review Host Verification Requests) |
| Actors | Primary: Admin. Secondary: Verification Service. |
| Preconditions | Admin selected a host verification request. |
| Description of the Main Sequence | 1. System opens the host verification details page.<br>2. Admin reviews host information, current status, submitted documents, and review history fields.<br>3. Admin prepares an approval or rejection decision. |
| Description of the Alternative Sequence | A1. If documents are missing, system shows the request without document rows or with submitted status information.<br>A2. If request details fail to load, system shows an error state. |
| Non functional requirements | Sensitive document links should only be visible to authorized admins. |
| Postconditions | Admin has enough visible detail to approve or reject the request. |

### UC-ADM-09: Approve or Reject Host Verification

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-09 Approve or Reject Host Verification |
| Summary | An admin records a decision for a host verification request. |
| Dependency | UC-ADM-08 (Review Host Verification Details) |
| Actors | Primary: Admin. Secondary: Verification Service, Audit Log Service. |
| Preconditions | Admin is viewing a host verification details page. |
| Description of the Main Sequence | 1. Admin chooses a verification decision such as approved, rejected, pending documents, or suspected fraud.<br>2. System asks for a reason.<br>3. Admin enters the reason and confirms.<br>4. System updates request status and host trusted state where applicable.<br>5. System reloads the details page. |
| Description of the Alternative Sequence | A1. If admin cancels the reason dialog, no decision is saved.<br>A2. If update fails, system shows an error. |
| Non functional requirements | Verification decisions must be audit logged and visible after refresh. |
| Postconditions | Host verification status reflects the admin decision. |

### UC-ADM-10: Publish or Edit Global Notification

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-10 Publish or Edit Global Notification |
| Summary | An admin creates or updates a platform announcement. |
| Dependency | UC-ADM-01 (View Admin Dashboard) |
| Actors | Primary: Admin. Secondary: Notification Service, Audit Log Service. |
| Preconditions | Admin opens Global Notifications from the dashboard. |
| Description of the Main Sequence | 1. Admin opens Global Notifications.<br>2. System lists existing notifications.<br>3. Admin taps add or opens an existing notification form.<br>4. Admin enters title, message, status, schedule, and reason.<br>5. Admin saves the notification.<br>6. System returns to the notification list. |
| Description of the Alternative Sequence | A1. If date values are invalid, system blocks save.<br>A2. If save fails, system shows an error and keeps the form open. |
| Non functional requirements | Notification forms must validate schedule order and require an admin reason. |
| Postconditions | The notification is created or updated and can be visible to non-admin users when published and active. |

### UC-ADM-11: Monitor Platform Metrics

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-11 Monitor Platform Metrics |
| Summary | An admin views platform growth and activity metrics. |
| Dependency | UC-ADM-01 (View Admin Dashboard) |
| Actors | Primary: Admin. Secondary: Metrics Service. |
| Preconditions | Admin opens Growth KPIs or views dashboard metric cards. |
| Description of the Main Sequence | 1. Admin opens Growth KPIs.<br>2. System loads overview metrics such as users, events, registrations, comments, reports, and host requests.<br>3. System loads daily metrics rows.<br>4. Admin reviews the metrics for operational monitoring. |
| Description of the Alternative Sequence | A1. If metrics are unavailable, system shows an admin error state.<br>A2. If no daily values exist, system shows empty or zero values. |
| Non functional requirements | Metric pages should load within the request timeout and label provisional values where the model provides them. |
| Postconditions | Admin has a current view of platform activity. |

### UC-ADM-12: Review Disputes

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-12 Review Disputes |
| Summary | An admin reviews dispute cases from the admin dashboard. |
| Dependency | UC-ADM-01 (View Admin Dashboard) |
| Actors | Primary: Admin. Secondary: Dispute Service. |
| Preconditions | Admin opens Disputes from the dashboard. |
| Description of the Main Sequence | 1. Admin opens Disputes.<br>2. System loads dispute cases.<br>3. Admin filters by status where available.<br>4. Admin taps a dispute case.<br>5. System opens dispute details with event, host, goer, reason, evidence, and decision controls. |
| Description of the Alternative Sequence | A1. If no disputes exist, system shows an empty state.<br>A2. If loading fails, system shows an error and retry option. |
| Non functional requirements | Dispute status labels should be visible in the list for fast triage. |
| Postconditions | Admin can inspect a dispute case. |

### UC-ADM-13: View Dispute Chat Logs

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-13 View Dispute Chat Logs |
| Summary | An admin opens chat-log evidence from a dispute details page. |
| Dependency | UC-ADM-12 (Review Disputes) |
| Actors | Primary: Admin. Secondary: Dispute Evidence Service. |
| Preconditions | Admin is viewing dispute details. |
| Description of the Main Sequence | 1. Admin taps the chat logs action or section.<br>2. System loads chat-log evidence linked to the dispute.<br>3. System shows whether evidence is complete and displays available entries.<br>4. Admin reviews the evidence before decision. |
| Description of the Alternative Sequence | A1. If no chat logs exist, system shows incomplete or empty evidence state.<br>A2. If loading fails, system shows an error. |
| Non functional requirements | Chat-log evidence must be available only to authorized admins. |
| Postconditions | Admin has reviewed available chat evidence for the dispute. |

### UC-ADM-14: Resolve Dispute

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-14 Resolve Dispute |
| Summary | An admin records a dispute decision from dispute details. |
| Dependency | UC-ADM-12 (Review Disputes) |
| Actors | Primary: Admin. Secondary: Dispute Service, Audit Log Service. |
| Preconditions | Admin is viewing dispute details and has reviewed available evidence. |
| Description of the Main Sequence | 1. Admin enters or selects a decision.<br>2. Admin provides a reason and status.<br>3. Admin submits the decision.<br>4. System updates the dispute.<br>5. System reloads the dispute details with the recorded decision. |
| Description of the Alternative Sequence | A1. If required decision text is missing, system blocks submission.<br>A2. If update fails, system shows an error. |
| Non functional requirements | Dispute decisions must be auditable and preserve the submitted reason. |
| Postconditions | Dispute details show the latest decision and status. |

### UC-ADM-15: View Audit Logs

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-15 View Audit Logs |
| Summary | An admin reviews audit log entries from the dashboard. |
| Dependency | UC-ADM-01 (View Admin Dashboard) |
| Actors | Primary: Admin. Secondary: Audit Log Service. |
| Preconditions | Admin opens Audit Logs from the dashboard. |
| Description of the Main Sequence | 1. Admin opens Audit Logs.<br>2. System loads paged audit entries.<br>3. Admin reviews action, model, actor, timestamp, and recorded values shown in the UI.<br>4. Admin moves through pages where available. |
| Description of the Alternative Sequence | A1. If no audit entries exist, system shows an empty state.<br>A2. If loading fails, system shows an error and retry option. |
| Non functional requirements | Audit log pages should respect page size limits and load without blocking other admin screens. |
| Postconditions | Admin has visibility into recorded platform actions. |

### UC-ADM-16: Navigate Admin Tabs

| Section | Details |
| :--- | :--- |
| UC Name | UC-ADM-16 Navigate Admin Tabs |
| Summary | An admin moves between Admin, Events, Map, and Profile tabs. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Admin. |
| Preconditions | Admin is authenticated and main navigation is visible. |
| Description of the Main Sequence | 1. Admin views the bottom navigation bar.<br>2. Admin taps Admin, Events, Map, or Profile.<br>3. System switches to the selected screen.<br>4. Admin continues the relevant workflow from that tab. |
| Description of the Alternative Sequence | A1. If a selected screen cannot load its data, only that screen shows an error state.<br>A2. If the admin logs out from Profile settings, system clears the session and returns to landing. |
| Non functional requirements | Tab navigation must preserve a consistent role-specific navigation structure. |
| Postconditions | Admin is on the selected admin-accessible screen. |
