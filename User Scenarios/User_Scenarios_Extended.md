# User Scenarios Extended
*Frontend-first steps to reach the desired output for each user scenario*

---

## Common Scenarios

**UC-COM-01: Register Account**
1. Visitor opens the landing page and taps **Sign up**.
2. System shows the multi-step signup form.
3. Visitor selects Goer or Business and enters account details.
4. Visitor selects required profile images and role-specific fields.
5. Visitor reviews the summary and taps **Create account**.
6. System creates the account, stores the session when available, and opens the role-specific main app.
7. If validation or upload fails: System keeps entered data visible and shows the error on the current step.

**UC-COM-02: Log In**
1. Registered user opens the login page.
2. User enters email and password.
3. User taps **Log in**.
4. System validates credentials and stores the session token.
5. System opens the role-specific main navigation.
6. If credentials or network access fail: System stays on the login page and shows an error.

**UC-COM-03: View Landing Page Entry Actions**
1. Visitor opens the app without an active session.
2. System shows the landing page with Login and Sign up actions.
3. Visitor taps **Login** or **Sign up**.
4. System opens the selected page.
5. If a stored session is available: System can skip the landing page and open the main app.

**UC-COM-04: Edit Profile**
1. Logged-in user opens Profile from the main navigation.
2. User opens Settings and taps **Profile**.
3. System shows editable profile fields and avatar controls.
4. User updates visible account information and taps **Save**.
5. System saves the profile and refreshes visible user details.
6. If saving fails: System keeps the form open and shows an error.

**UC-COM-05: Change Appearance Settings**
1. Logged-in user opens Settings.
2. User taps **Appearance**.
3. System shows appearance options.
4. User selects a preferred theme.
5. System applies the theme and stores the preference.
6. If storing fails: System keeps the previous preference visible.

**UC-COM-06: View Global Notifications**
1. Goer or business user opens Settings.
2. User taps **Announcements**.
3. System loads published global notifications.
4. User reads titles, messages, and timing details.
5. If no active announcements exist: System shows an empty state.
6. If loading fails: System shows an error or retry state.

---

## Goer Scenarios

**UC-GO-01: Discover Trending Events**
1. Goer logs in and opens the Discover tab.
2. System loads the Trending Events section.
3. Goer scrolls event cards.
4. Goer taps a card to open event details.
5. If no trending events are available: System shows a no-events message.
6. If loading fails: System shows a retry action.

**UC-GO-02: View Nearby Events**
1. Goer opens Discover.
2. System asks for location access when needed.
3. Goer allows location access.
4. System loads nearby events and shows the list.
5. Goer taps an event to open details.
6. If permission is denied or services are unavailable: System shows a clear location message without blocking other discovery content.

**UC-GO-03: Search Events**
1. Goer taps the search field in Discover.
2. Goer enters a search term.
3. Goer submits the search.
4. System shows matching event results.
5. Goer taps a result to open details.
6. If no results are found or loading fails: System shows an empty or retry state.

**UC-GO-04: View Event Details**
1. Goer taps an event from Discover, Calendar, Map, or host profile.
2. System opens the event details page.
3. System shows image, title, status, date, location, host, capacity, categories, tags, comments, and action buttons.
4. Goer scrolls the page and chooses an action such as join, share, report, comment, or view host.
5. If secondary data fails to load: System keeps the page visible and shows the affected section error.

**UC-GO-05: View Host Profile**
1. Goer opens an event details page.
2. Goer taps the host name or hosted-by link.
3. System opens the business or host profile page.
4. System shows host identity, credibility summary, and hosted events.
5. Goer opens another hosted event or reports the host.
6. If the profile cannot load: System shows an error or fallback host information.

**UC-GO-06: Join Event**
1. Goer opens an event details page.
2. Goer taps **Join event**.
3. System opens the join confirmation page.
4. Goer reviews event information and confirms.
5. System creates the registration and returns to event details.
6. If capacity or saving fails: System keeps the goer on the join flow and shows the failure.

**UC-GO-07: Unregister From Event**
1. Goer opens an event they already joined.
2. System shows the **Unregister** action.
3. Goer taps **Unregister**.
4. System removes the registration.
5. System refreshes the event details page and shows **Join event** again.
6. If removal fails: System keeps the registered state visible and shows an error.

**UC-GO-08: View Joined Events Calendar**
1. Goer opens the Calendar tab.
2. System loads events joined by the user.
3. System marks dates with event indicators.
4. Goer selects a date.
5. System shows joined events for that date and allows opening details.
6. If there are no joined events: System shows an empty calendar message.

**UC-GO-09: View Events on Map**
1. Goer opens the Map tab.
2. System loads visible events with location data.
3. System displays markers or location cards.
4. Goer selects an event location.
5. System opens or previews the selected event.
6. If events cannot load: System shows an error state.

**UC-GO-10: Add Event Comment**
1. Goer opens an event details page.
2. System loads the comments section.
3. Goer enters a comment in the comment composer.
4. Goer taps the submit action.
5. System saves the comment and refreshes the visible list.
6. If the comment is empty or saving fails: System shows validation or error feedback.

**UC-GO-11: Share Event**
1. Goer opens an event details page.
2. Goer taps the share action.
3. System prepares the event share content.
4. Device share options appear.
5. Goer selects a share destination or cancels.
6. If sharing cannot open: System stays on event details.

**UC-GO-12: Report Event**
1. Goer opens an event details page.
2. Goer taps **Report**.
3. System opens the report dialog.
4. Goer selects or enters a reason.
5. System saves the event report and shows confirmation.
6. If the reason is missing or saving fails: System keeps the dialog open and shows feedback.

**UC-GO-13: Report Comment**
1. Goer opens an event details page with comments.
2. Goer opens the action for a specific comment.
3. Goer chooses **Report**.
4. System opens the report dialog.
5. Goer submits a reason and system saves the comment report.
6. If saving fails: System shows an error and keeps the user on the page.

**UC-GO-14: Report Host**
1. Goer opens a host profile.
2. Goer taps the report host action.
3. System opens the report dialog.
4. Goer enters a reason.
5. System saves the host report and shows confirmation.
6. If the dialog is cancelled: System returns to the host profile unchanged.

**UC-GO-15: Submit Host Verification Request**
1. Goer opens Settings.
2. Goer taps the verification option.
3. System shows existing verification requests and document controls.
4. Goer creates a request and selects a PDF document.
5. System uploads the document and attaches it to the request.
6. If upload or saving fails: System shows the failure and keeps the verification page open.

**UC-GO-16: Delete Host Verification Request**
1. Goer opens Settings verification.
2. System loads the user's verification requests.
3. Goer selects a request to remove.
4. Goer confirms deletion.
5. System deletes the request and refreshes the list.
6. If deletion fails: System keeps the request visible and shows an error.

---

## Business Scenarios

**UC-BIZ-01: Create Business Account**
1. Business user opens signup from the landing page.
2. User selects the Business role.
3. User enters account details, profile image, business logo, and business profile fields.
4. User reviews the signup summary and taps **Create account**.
5. System creates the account and opens the business navigation.
6. If validation or upload fails: System shows the error without clearing the entered information.

**UC-BIZ-02: View Hosted Events Tab**
1. Business user logs in.
2. User opens the Hosted tab.
3. System loads hosted events for the account.
4. User reviews hosted event cards and actions.
5. If no hosted events exist: System shows an empty state.
6. If loading fails: System shows a retry option.

**UC-BIZ-03: Create Hosted Event**
1. Business user opens the add event flow.
2. User enters event details, date, location, capacity, categories, and tags.
3. User selects event photos.
4. User reviews the summary.
5. User taps the create action and system saves the event.
6. If validation or saving fails: System keeps the form visible and shows feedback.

**UC-BIZ-04: Upload Event or Profile Images**
1. Business user opens signup, profile, add event, or edit event image controls.
2. User selects an image from the picker.
3. System previews the selected image.
4. User continues or saves the related form.
5. System uploads the image and stores the returned URL.
6. If the upload fails: System shows an upload error and allows retry.

**UC-BIZ-05: Edit Hosted Event**
1. Business user opens a hosted event.
2. User taps an edit action.
3. System opens the edit event form with current values.
4. User updates event details or images.
5. User reviews and saves changes.
6. If saving fails: System keeps the edit form open and shows an error.

**UC-BIZ-06: Delete Hosted Event**
1. Business user opens a hosted event or hosted event list.
2. User taps the delete action.
3. System shows a confirmation dialog.
4. User confirms deletion.
5. System deletes the event and refreshes hosted events.
6. If the user cancels or deletion fails: System keeps the event visible.

**UC-BIZ-07: View Hosted Events Calendar**
1. Business user opens the Calendar tab.
2. System loads events hosted by the business account.
3. System marks dates with hosted event indicators.
4. User selects a date.
5. System shows hosted events for that date.
6. If no hosted events exist: System shows an empty calendar state.

**UC-BIZ-08: Filter Hosted Events by City**
1. Business user opens the hosted events calendar.
2. User enters or selects a city filter.
3. System loads hosted events for that city.
4. Calendar and event list update to the filtered results.
5. User clears the filter to return to all hosted events.
6. If no city results exist: System shows an empty state.

**UC-BIZ-09: Promote Hosted Event as Trending**
1. Business user opens a hosted event or promotion screen.
2. User selects an event to promote.
3. System shows the promotion page.
4. User confirms the action to mark the event as trending.
5. System saves the trending status and shows confirmation.
6. If saving fails: System keeps the event unchanged and shows an error.

**UC-BIZ-10: View Business Profile and Hosted Event List**
1. User opens a business profile from a host link or profile area.
2. System loads business information.
3. System loads hosted events for the business.
4. User reviews profile details and hosted event cards.
5. User opens an event from the hosted list.
6. If hosted events cannot load: System shows an empty or error state within the profile.

---

## Admin Scenarios

**UC-ADM-01: View Admin Dashboard**
1. Admin logs in and enters the admin navigation.
2. System opens the dashboard.
3. System loads metric summary cards.
4. Admin reviews dashboard tiles.
5. Admin taps a tile to open an admin tool.
6. If metrics fail to load: System shows an error or zero-state card.

**UC-ADM-02: View and Manage Events**
1. Admin opens the Events tab.
2. System loads all visible events.
3. Admin reviews event cards and details.
4. Admin opens an event or action menu.
5. If no events exist: System shows an empty state.
6. If loading fails: System shows a retry option.

**UC-ADM-03: Delete Event**
1. Admin opens an event from the admin events page.
2. Admin taps the delete action.
3. System shows a confirmation dialog.
4. Admin confirms deletion.
5. System deletes the event and refreshes the list.
6. If cancelled or failed: System keeps the event visible.

**UC-ADM-04: Review Safety Reports**
1. Admin opens Safety Reports.
2. System loads report cards.
3. Admin applies status or severity filters.
4. System refreshes the filtered list.
5. Admin opens a report detail page.
6. If no reports match: System shows an empty state.

**UC-ADM-05: Apply Moderation Action**
1. Admin opens a safety report detail page.
2. Admin selects a moderation action.
3. System opens a reason dialog.
4. Admin enters a reason and confirms.
5. System saves the action and refreshes report details.
6. If the reason is missing or save fails: System shows validation or error feedback.

**UC-ADM-06: Update Report Status**
1. Admin opens a report detail page.
2. Admin chooses a new status.
3. System asks for a reason when required.
4. Admin confirms the update.
5. System saves the status and reloads the detail view.
6. If cancelled or failed: System keeps the previous status visible.

**UC-ADM-07: Review Host Verification Requests**
1. Admin opens Host Verification.
2. System loads verification request cards.
3. Admin filters requests by status.
4. System refreshes the filtered list.
5. Admin selects a request to inspect.
6. If no requests match: System shows an empty state.

**UC-ADM-08: Review Host Verification Details**
1. Admin opens a host verification request.
2. System loads host details, documents, current status, and history.
3. Admin reviews the visible information.
4. Admin opens document links where available.
5. Admin prepares a decision.
6. If a document is missing or loading fails: System shows a visible warning.

**UC-ADM-09: Approve or Reject Host Verification**
1. Admin opens verification details.
2. Admin selects approve, reject, pending, or fraud.
3. System opens a reason input when required.
4. Admin submits the decision.
5. System updates the request and visible trusted state where applicable.
6. If validation or saving fails: System keeps the detail page open.

**UC-ADM-10: Publish or Edit Global Notification**
1. Admin opens Notifications.
2. System loads existing notifications.
3. Admin taps create or edit.
4. Admin fills title, message, status, timing, and reason fields.
5. Admin saves the notification.
6. If validation or saving fails: System keeps the form open and shows feedback.

**UC-ADM-11: Monitor Platform Metrics**
1. Admin opens Growth KPIs or Metrics.
2. System loads overview metrics and daily metrics.
3. Admin reviews cards, charts, and tables.
4. Admin changes date filters when available.
5. System refreshes the displayed metrics.
6. If data is unavailable: System shows empty or error states.

**UC-ADM-12: Review Disputes**
1. Admin opens Disputes.
2. System loads dispute cases.
3. Admin filters cases by status.
4. System refreshes the list.
5. Admin opens a dispute detail page.
6. If there are no cases: System shows an empty state.

**UC-ADM-13: View Dispute Chat Logs**
1. Admin opens dispute details.
2. Admin selects the chat logs section.
3. System loads visible chat evidence entries.
4. Admin reviews messages and timestamps.
5. Admin returns to the dispute details page.
6. If logs are unavailable: System shows a no-logs or error message.

**UC-ADM-14: Resolve Dispute**
1. Admin opens a dispute detail page.
2. Admin chooses a decision and status.
3. Admin enters a reason.
4. Admin submits the resolution.
5. System saves the decision and reloads dispute details.
6. If required information is missing or saving fails: System shows feedback and keeps the form open.

**UC-ADM-15: View Audit Logs**
1. Admin opens Audit Logs.
2. System loads the first page of log entries.
3. Admin reviews actor, action, model, time, and value fields.
4. Admin moves to another page.
5. System loads the selected page.
6. If logs cannot load: System shows an error state.

**UC-ADM-16: Navigate Admin Tabs**
1. Admin opens the main admin navigation.
2. Admin taps Admin, Events, Map, or Profile in the bottom navigation.
3. System switches to the selected screen.
4. Admin uses Profile to access account actions.
5. Admin can log out from Profile.
6. If a selected screen fails to load: System shows that screen's error state while navigation remains usable.
