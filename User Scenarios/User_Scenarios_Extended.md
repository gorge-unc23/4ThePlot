# User Scenarios Extended
*Steps to reach the desired output for each user scenario*

---

## Goer / Participant Scenarios

**GO-01: Follow Preferred Categories**
1. Goer opens the app and lands on the **Search / Discover Events** screen (bottom nav: Search tab).
2. Goer taps on their profile initials avatar (top-right corner) to access profile settings.
3. Goer navigates to the preferences section and browses available categories (e.g., Music, Fitness, Art, Tech).
4. Goer taps the desired categories to select them.
5. System saves the preferences and links them to the goer's account.
6. System updates the **Trending Events** and **Events Near You** sections on the Discover screen to prioritize selected categories.
7. If no categories are selected: System shows a default mixed feed with a prompt to personalize.

**GO-02: Check Host Credibility**
1. Goer opens the **Search / Discover Events** screen and browses the Trending Events cards.
2. Goer taps on an event card (e.g., "Summer Music Festival") to open the event detail page.
3. Goer taps on the host's name or profile picture within the event detail page.
4. System displays the host's profile including rating, number of past events, and reviews.
5. Goer reads through attendee reviews and star ratings.
6. Goer decides whether to tap the **Join** button on the event card.
7. If the host has no reviews: System shows a 'New Host' badge with a notice.

**GO-03: Enter Waitlist for Sold-Out Event**
1. Goer finds an event on the **Discover Events** screen showing a full attendee count badge (e.g., "2K+").
2. Goer taps the event card to open the event detail page.
3. System shows the event is at full capacity and displays a **Join Waitlist** button instead of the regular Join button.
4. Goer taps **Join Waitlist**; system registers the goer's position and sends a confirmation notification.
5. If a spot opens: System automatically notifies the goer and temporarily reserves the spot.
6. If the goer doesn't confirm within the time window: System passes the spot to the next person in line.

**GO-04: Use Map for Directions**
1. Goer taps the **Map** tab in the bottom navigation bar.
2. System opens the Map screen showing event pins within the current radius (e.g., "2.3 mi radius").
3. Goer taps an event pin on the map; system displays the event popup card (image, name, attendee count, **View Event** button).
4. Goer taps **View Event** to open the full event detail page and taps the venue address.
5. System prompts the goer to choose a navigation app (e.g., Google Maps, Apple Maps).
6. Selected app opens with the venue pre-filled as the destination.
7. If location permissions are denied: System shows a prompt requesting location access.

**GO-05: Share Event with Friends**
1. Goer opens an event card from the **Discover Events** screen or the **Saved Events** list on the Profile screen.
2. Goer taps the **Share** icon on the event detail page.
3. System generates a shareable link and displays sharing options (WhatsApp, Instagram, copy link, etc.).
4. Goer selects a method and sends the link to friends.
5. Friends receive the link and can open the event page directly in the app.
6. If the event is private: System only allows sharing with users who have been granted access.

**GO-06: Save Event Draft**
1. Goer taps the **+** or "Create Event" option (accessible from the Profile screen or Discover screen).
2. Goer fills in partial event details (title, date, description) but is not ready to publish.
3. Goer taps **Save as Draft** before completing all required fields.
4. System saves the draft linked to the goer's account and shows a confirmation message.
5. Goer can return to drafts at any time from the Profile screen to continue editing.
6. If the session expires: System auto-saves the draft to prevent data loss.

**GO-07: Limit Event Capacity**
1. Goer accesses the event creation or editing form from the Profile screen.
2. Goer navigates to the event settings and finds the **Capacity** field.
3. Goer enters the maximum number of participants allowed.
4. System validates the value (must be a positive integer) and saves it.
5. System enforces the cap during registration; the attendee count badge on the Discover screen updates in real time.
6. If capacity is reached: System closes new join requests and the Join button changes to reflect the full status.

**GO-08: Broadcast Update to Attendees**
1. Goer (as event host) navigates to their hosted event via the **Profile** tab (bottom nav).
2. Goer opens the hosted event and taps **Send Update** or **Broadcast Message**.
3. Goer types the update message (e.g., a change in time or location).
4. System previews the message and shows the number of recipients.
5. Goer confirms the send action.
6. System delivers a push notification to all joined participants simultaneously.
7. If no participants have joined yet: System informs the host that there are no recipients available.

**GO-09: Set Recurring Schedule**
1. Goer opens an existing event or creates a new one from the Profile screen.
2. Goer enables the **Recurring Event** toggle in the event settings.
3. Goer selects a recurrence pattern (e.g., weekly, bi-weekly, monthly).
4. Goer sets the end date or total number of occurrences.
5. System generates all recurring event instances; they appear as separate dots on the **Calendar** screen.
6. System allows the goer to edit individual occurrences without affecting the full series.
7. If a conflict exists on a recurring date: System flags it and asks the goer to resolve it.

**GO-10: Review Event Performance**
1. Goer navigates to the **Profile** tab (bottom nav) and opens their hosted event from the events list.
2. System displays the event's performance metrics: total views, join count, and conversion rate.
3. Goer filters results by date range or specific event.
4. Goer compares metrics across events to identify trends.
5. System visualizes data with graphs or summary cards.
6. If the event had no views: System shows a zero-state message with tips to improve reach.

---

## Business Scenarios

**BIZ-01: Promote Event Placement**
1. Business user logs in and navigates to their event dashboard via the **Profile** tab.
2. Business selects an event to promote and taps into the **Promote** section.
3. System displays pricing tiers for different visibility levels (e.g., placement in the Trending Events section on the Discover screen).
4. Business enters payment details and confirms the purchase.
5. System boosts the event's position in the **Trending Events** carousel on the Discover screen for the selected duration.
6. If the payment fails: System notifies the business and keeps the event in its current position.

**BIZ-02: Build Branded Profile**
1. Business user taps the **Profile** tab in the bottom navigation bar.
2. Business taps the settings icon (top-right gear icon) to open profile settings.
3. Business uploads a logo/banner and fills in the brand description.
4. Business adds website URL and social media links.
5. System validates the URLs and saves the branded profile.
6. System displays the branded profile publicly on all hosted event cards.
7. If the logo dimensions are invalid: System prompts the business to upload a correctly-sized image.

**BIZ-03: Capture Leads from Attendees**
1. Business user opens a hosted event from the **Profile** screen.
2. Business navigates to the **Lead Capture** settings within the event management panel.
3. Business sets up a coupon code or downloadable resource for attendees.
4. System attaches the lead capture form to the event registration flow (triggered when a goer taps **Join**).
5. Attendees complete the form to receive the offer; system stores the data in the business's leads dashboard.
6. If an attendee skips the form: System marks the registration as complete but without lead data.

**BIZ-04: Co-Host with Partners**
1. Business user opens an event from the **Profile** screen and navigates to the **Co-Hosts** section.
2. Business searches for a partner account and sends a co-host invitation.
3. Partner receives a notification and accepts or declines.
4. If accepted: System displays both brand names on the event card visible on the Discover screen.
5. If declined: System notifies the business and removes the pending co-host tag.

**BIZ-05: Measure Ad Conversion ROI**
1. Business user opens the **Profile** tab and navigates to the analytics section of their account.
2. Business selects a promoted event to review.
3. System displays a report: ad spend, impressions, clicks, and join count.
4. System calculates the cost-per-join and conversion percentage.
5. Business downloads or shares the report with the marketing team.
6. If no ad spend was recorded: System shows organic metrics only with a prompt to start promoting.

**BIZ-06: Save Event Draft**
1. Business event manager starts creating a new event from the **Profile** screen.
2. Manager fills in available details and taps **Save as Draft**.
3. System saves the draft linked to the business account with a last-saved timestamp.
4. Manager can return to the draft at any time from the Profile screen to finalize and publish.
5. If a team member tries to edit the same draft simultaneously: System shows a conflict warning.

**BIZ-07: Control Event Capacity**
1. Business organizer opens the event creation or editing form from the **Profile** screen.
2. Organizer enters the maximum number of attendees in the **Capacity** field.
3. System validates and saves the limit; it is reflected in the attendee count badge on all event cards.
4. System tracks real-time attendance and compares it against the cap.
5. When capacity is reached: System blocks new registrations and updates the event status across the Discover and Map screens.
6. If the organizer increases the cap later: System reopens registration automatically.

**BIZ-08: Send Bulk Attendee Notice**
1. Business organizer opens the event management panel from the **Profile** tab.
2. Organizer taps **Broadcast Message** and writes the update content.
3. System shows a preview and the number of registered recipients.
4. Organizer confirms the send.
5. System delivers push notifications to all registered attendees.
6. System logs the broadcast with a timestamp.
7. If the message contains restricted content: System flags it and requests revision.

**BIZ-09: Run Recurring Campaign Event**
1. Business organizer opens a published or draft event from the **Profile** screen.
2. Organizer enables the **Recurring** option and sets the schedule (monthly, weekly, etc.).
3. Organizer sets campaign start and end dates.
4. System creates all future event instances; they appear as individual event dots on the **Calendar** screen for attendees.
5. System allows the organizer to update individual instances or the entire series.
6. If a recurring date has a conflict: System alerts the organizer and offers rescheduling.

**BIZ-10: Analyze Post-Event Results**
1. Business organizer navigates to a completed event via the **Profile** tab.
2. System displays a post-event report: views, joins, no-shows, and engagement rate.
3. Organizer compares the event performance against previous campaigns.
4. System provides improvement recommendations based on performance patterns.
5. Organizer exports the report as PDF or CSV for internal review.
6. If no data is available: System shows a placeholder indicating that data is still being processed.

---

## Admin Scenarios

**ADM-01: Process Safety Reports**
1. Admin logs into the admin dashboard (separate from the goer/business app interface).
2. Admin navigates to the **Reports** section; system displays flagged content sorted by severity and date.
3. Admin opens a specific report and reviews the flagged event or user content.
4. Admin chooses an action: remove content, warn host, or dismiss the report.
5. System executes the action and updates the report status.
6. System sends an automated notification to the reporting user about the outcome.
7. If the flagged content is illegal: System escalates the case to the legal review queue.

**ADM-02: Approve Verified Hosts**
1. Admin opens the **Verification Requests** panel in the admin dashboard.
2. System lists all pending host verification submissions with uploaded documents.
3. Admin reviews each submission including identity and business credentials.
4. Admin approves or rejects the request with a stated reason.
5. If approved: System adds a **Verified** badge to the host's profile, visible on all their event cards.
6. If rejected: System notifies the host with the reason and option to resubmit.

**ADM-03: Publish Global Notification**
1. Admin navigates to the **Notifications** section of the admin panel.
2. Admin taps **Create Global Banner** and writes the message (e.g., scheduled maintenance alert).
3. Admin sets the display duration and target audience (all users or specific roles).
4. System previews the banner as it will appear across the app screens.
5. Admin publishes the notification.
6. System immediately displays the banner across all active user sessions.
7. If the admin sets an expiry time: System automatically removes the banner after expiration.

**ADM-04: Review Dispute Evidence**
1. Admin navigates to the **Disputes** section and opens a pending refund or conflict case.
2. System presents the goer's complaint alongside the host's response.
3. Admin reviews the conversation logs between the host and goer.
4. Admin examines timestamps, messages, and attached evidence (screenshots, receipts).
5. Admin makes a decision: approve refund, deny refund, or escalate to senior review.
6. System notifies both parties of the decision.
7. If the logs are missing or deleted: System flags the case as incomplete and escalates it.

**ADM-05: Monitor Platform Growth**
1. Admin opens the **Analytics** dashboard on the admin panel.
2. System displays daily, weekly, and monthly metrics: active users, new registrations, and new events.
3. Admin filters data by date range, region, or user role.
4. System renders graphs and trend lines for visual comparison.
5. Admin exports the report or pins key metrics for the team.
6. If a metric shows an unusual drop or spike: System highlights it with an anomaly alert.
