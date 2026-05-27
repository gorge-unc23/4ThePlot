# 4ThePlot: Frontend-Aligned User Scenarios List

## Common Scenarios

| ID | Scenario Name | Scenario Description |
| :--- | :--- | :--- |
| UC-COM-01 | Register Account | A visitor completes the multi-step signup form, selects a role, uploads required images, and enters the app. |
| UC-COM-02 | Log In | A registered user enters credentials on the login page and is routed to the correct role-specific home screen. |
| UC-COM-03 | View Landing Page Entry Actions | A visitor opens the landing page and chooses Login or Sign up to start the app entry flow. |
| UC-COM-04 | Edit Profile | A logged-in user opens Settings Profile, updates visible account fields, and saves the changes. |
| UC-COM-05 | Change Appearance Settings | A logged-in user opens Appearance settings, selects a theme option, and sees the app update. |
| UC-COM-06 | View Global Notifications | A goer or business user opens Announcements from Settings and reads published global notifications. |

## Goer Scenarios

| ID | Scenario Name | Scenario Description |
| :--- | :--- | :--- |
| UC-GO-01 | Discover Trending Events | A goer opens Discover and browses trending event cards before opening an event. |
| UC-GO-02 | View Nearby Events | A goer grants location access and views nearby events, or sees a clear denied-permission state. |
| UC-GO-03 | Search Events | A goer enters a search term and reviews matching event results or an empty state. |
| UC-GO-04 | View Event Details | A goer opens event details and reviews event information, comments, and visible actions. |
| UC-GO-05 | View Host Profile | A goer taps the host link from event details and views the host profile and hosted events. |
| UC-GO-06 | Join Event | A goer confirms a join action and the app updates the event registration state. |
| UC-GO-07 | Unregister From Event | A goer removes an existing registration and sees the event action return to Join. |
| UC-GO-08 | View Joined Events Calendar | A goer opens Calendar and views joined events grouped by date. |
| UC-GO-09 | View Events on Map | A goer opens Map and inspects visible event locations. |
| UC-GO-10 | Add Event Comment | A goer submits a comment from the event details page and sees the comment list refresh. |
| UC-GO-11 | Share Event | A goer taps Share on an event and opens the device share options. |
| UC-GO-12 | Report Event | A goer reports an event through the report dialog and sees a saved confirmation or error. |
| UC-GO-13 | Report Comment | A goer reports a comment from the event discussion area. |
| UC-GO-14 | Report Host | A goer reports a host from the host profile flow. |
| UC-GO-15 | Submit Host Verification Request | A goer submits a host verification request from Settings with uploaded document evidence. |
| UC-GO-16 | Delete Host Verification Request | A goer deletes an existing verification request and the request list refreshes. |

## Business Scenarios

| ID | Scenario Name | Scenario Description |
| :--- | :--- | :--- |
| UC-BIZ-01 | Create Business Account | A business user completes signup with business-specific profile fields and images. |
| UC-BIZ-02 | View Hosted Events Tab | A business user opens Hosted and views their hosted events, empty state, or load error. |
| UC-BIZ-03 | Create Hosted Event | A business user completes the add event flow and creates a hosted event. |
| UC-BIZ-04 | Upload Event or Profile Images | A business user selects profile or event images and sees upload success or failure feedback. |
| UC-BIZ-05 | Edit Hosted Event | A business user opens a hosted event, edits details, and saves visible updates. |
| UC-BIZ-06 | Delete Hosted Event | A business user confirms event deletion and the hosted list refreshes. |
| UC-BIZ-07 | View Hosted Events Calendar | A business user opens Calendar and views hosted events by date. |
| UC-BIZ-08 | Filter Hosted Events by City | A business user enters or selects a city filter and sees hosted calendar events narrow to that city. |
| UC-BIZ-09 | Promote Hosted Event as Trending | A business user opens promotion for a hosted event and marks it as trending. |
| UC-BIZ-10 | View Business Profile and Hosted Event List | A business profile opens with visible business information and hosted event cards. |

## Admin Scenarios

| ID | Scenario Name | Scenario Description |
| :--- | :--- | :--- |
| UC-ADM-01 | View Admin Dashboard | An admin opens the dashboard and reviews metric cards and navigation tiles. |
| UC-ADM-02 | View and Manage Events | An admin opens Events, reviews all event cards, and opens details or actions. |
| UC-ADM-03 | Delete Event | An admin confirms an event delete action and sees the list refresh. |
| UC-ADM-04 | Review Safety Reports | An admin opens Safety Reports, applies filters, and opens a report detail page. |
| UC-ADM-05 | Apply Moderation Action | An admin selects a moderation action, enters a reason, and sees the report refresh. |
| UC-ADM-06 | Update Report Status | An admin changes report status with a reason and sees the updated status. |
| UC-ADM-07 | Review Host Verification Requests | An admin opens the host verification list, filters by status, and selects a request. |
| UC-ADM-08 | Review Host Verification Details | An admin reviews host information, uploaded documents, status, and history. |
| UC-ADM-09 | Approve or Reject Host Verification | An admin submits a verification decision with a reason and sees the updated request state. |
| UC-ADM-10 | Publish or Edit Global Notification | An admin creates or edits an announcement and saves it for user-facing display. |
| UC-ADM-11 | Monitor Platform Metrics | An admin opens metrics and reviews overview cards, charts, and table values. |
| UC-ADM-12 | Review Disputes | An admin opens Disputes, filters cases, and selects a case to inspect. |
| UC-ADM-13 | View Dispute Chat Logs | An admin opens chat logs from a dispute and reviews visible evidence entries. |
| UC-ADM-14 | Resolve Dispute | An admin submits a dispute decision, status, and reason so the case refreshes. |
| UC-ADM-15 | View Audit Logs | An admin opens Audit Logs and pages through actor, action, model, and time entries. |
| UC-ADM-16 | Navigate Admin Tabs | An admin uses the bottom navigation to switch between Admin, Events, Map, and Profile. |
