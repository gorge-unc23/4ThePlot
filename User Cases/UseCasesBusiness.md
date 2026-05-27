## Business Use Cases

### UC-BIZ-01: Create Business Account

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-01 Create Business Account |
| Summary | A visitor creates a business account from the signup flow. |
| Dependency | UC-COM-01 (Register Account) |
| Actors | Primary: Visitor. Secondary: Account Service, Media Upload Service. |
| Preconditions | Visitor is on signup and selects the Business role. |
| Description of the Main Sequence | 1. Visitor selects Business in the signup role selector.<br>2. Visitor enters account details.<br>3. Visitor selects a profile photo and business logo.<br>4. Visitor enters business name, description, and optional website.<br>5. Visitor reviews the summary and creates the account.<br>6. System logs the business user into the hosted-events experience. |
| Description of the Alternative Sequence | A1. If business name or description is missing, system blocks the next step.<br>A2. If logo upload fails, system returns to the photo step and shows an error. |
| Non functional requirements | Business-specific required fields must be validated before account creation. |
| Postconditions | A business account and business profile are available in the app. |

### UC-BIZ-02: View Hosted Events Tab

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-02 View Hosted Events Tab |
| Summary | A business user views events hosted by their account. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Business User. Secondary: Event Listing Service. |
| Preconditions | Business user is authenticated and opens the Hosted tab. |
| Description of the Main Sequence | 1. Business user opens the Hosted tab.<br>2. System loads events where the business is the host.<br>3. System shows hosted event cards with image, title, date, and venue.<br>4. Business user taps an event to open details. |
| Description of the Alternative Sequence | A1. If no hosted events exist, system shows that the business is not hosting any events yet.<br>A2. If loading fails, system shows an error message. |
| Non functional requirements | Hosted event lists should be sorted for scanning and render cleanly on mobile screens. |
| Postconditions | Business user can inspect and manage hosted events. |

### UC-BIZ-03: Create Hosted Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-03 Create Hosted Event |
| Summary | A business user creates a hosted event from the Add tab. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Business User. Secondary: Event Service, Media Upload Service. |
| Preconditions | Business user is authenticated and opens the Add tab. |
| Description of the Main Sequence | 1. Business user opens Add.<br>2. System shows the add-event flow.<br>3. Business user enters event details, location, schedule, capacity, categories, tags, and price information shown by the form.<br>4. Business user selects event photos when prompted.<br>5. Business user reviews the summary.<br>6. Business user submits the event.<br>7. System creates the event and refreshes hosted-event screens. |
| Description of the Alternative Sequence | A1. If required event fields are missing, system blocks progress and shows validation feedback.<br>A2. If image upload or event creation fails, system shows an error and keeps the draft data in the flow. |
| Non functional requirements | Event creation should preserve entered form state across steps and show clear loading feedback during submission. |
| Postconditions | A new hosted event is visible in hosted-event and discovery contexts according to its status. |

### UC-BIZ-04: Upload Event or Profile Images

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-04 Upload Event or Profile Images |
| Summary | A business user selects visible images for account or event presentation. |
| Dependency | UC-BIZ-01 (Create Business Account), UC-BIZ-03 (Create Hosted Event) |
| Actors | Primary: Business User. Secondary: Device Image Picker, Media Upload Service. |
| Preconditions | Business user is in signup, add-event, or edit-event photo step. |
| Description of the Main Sequence | 1. Business user taps Select photo or image picker control.<br>2. System opens the device image picker.<br>3. Business user selects an image.<br>4. System previews the image in the form.<br>5. On submit, system uploads the image and uses the returned URL in the profile or event. |
| Description of the Alternative Sequence | A1. If user cancels image selection, the previous image state remains.<br>A2. If upload fails, system shows an error and blocks final submission when the image is required. |
| Non functional requirements | Image preview should work before upload; accepted image formats must match the backend media constraints. |
| Postconditions | The selected image appears in the relevant profile or event UI after save. |

### UC-BIZ-05: Edit Hosted Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-05 Edit Hosted Event |
| Summary | A business user edits an event they host from event details. |
| Dependency | UC-BIZ-02 (View Hosted Events Tab) |
| Actors | Primary: Business User. Secondary: Event Service. |
| Preconditions | Business user opens details for an event where they are the host. |
| Description of the Main Sequence | 1. Business user opens a hosted event details page.<br>2. System shows host actions instead of join actions.<br>3. Business user taps Edit event.<br>4. System opens the edit-event flow with current event data.<br>5. Business user changes details and reviews the summary.<br>6. System saves the updated event. |
| Description of the Alternative Sequence | A1. If validation fails, system keeps the user in the edit flow and marks the problem fields.<br>A2. If save fails, system shows an error and does not discard edits. |
| Non functional requirements | Editing should reuse existing event data and prevent accidental data loss on failed save. |
| Postconditions | Hosted event details show the updated information after refresh. |

### UC-BIZ-06: Delete Hosted Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-06 Delete Hosted Event |
| Summary | A business user deletes an event they host from event details. |
| Dependency | UC-BIZ-02 (View Hosted Events Tab) |
| Actors | Primary: Business User. Secondary: Event Service. |
| Preconditions | Business user opens details for an event they host. |
| Description of the Main Sequence | 1. Business user opens hosted event details.<br>2. Business user chooses the delete event action where available.<br>3. System asks for confirmation.<br>4. Business user confirms deletion.<br>5. System removes the event and returns from the details page. |
| Description of the Alternative Sequence | A1. If user cancels confirmation, no event is removed.<br>A2. If deletion fails, system shows an error and keeps the event visible. |
| Non functional requirements | Event deletion must require confirmation and show progress while the request is active. |
| Postconditions | The event no longer appears in hosted event lists after refresh. |

### UC-BIZ-07: View Hosted Events Calendar

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-07 View Hosted Events Calendar |
| Summary | A business user views hosted events by date in Calendar. |
| Dependency | UC-BIZ-02 (View Hosted Events Tab) |
| Actors | Primary: Business User. Secondary: Event Listing Service. |
| Preconditions | Business user is authenticated and opens Calendar. |
| Description of the Main Sequence | 1. Business user opens Calendar.<br>2. System loads events hosted by the business.<br>3. System marks dates with hosted-event indicators.<br>4. Business user selects a date.<br>5. System shows hosted events for that date and allows opening details. |
| Description of the Alternative Sequence | A1. If no hosted events exist, system shows the hosted-events empty state.<br>A2. If loading fails, system shows an error. |
| Non functional requirements | Calendar should distinguish hosted events from goer joined-event behavior through role-specific text. |
| Postconditions | Business user can review hosted events by date. |

### UC-BIZ-08: Filter Hosted Events by City

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-08 Filter Hosted Events by City |
| Summary | A business user filters hosted calendar events by city. |
| Dependency | UC-BIZ-07 (View Hosted Events Calendar) |
| Actors | Primary: Business User. Secondary: Event Listing Service. |
| Preconditions | Business user is on the Calendar tab. |
| Description of the Main Sequence | 1. Business user enters or selects a city filter in Calendar.<br>2. System loads hosted events for that city.<br>3. System updates date indicators and selected-date event list.<br>4. Business user opens a filtered hosted event. |
| Description of the Alternative Sequence | A1. If the city has no hosted events, system shows a no-events message for that city.<br>A2. If the city query fails, system shows an error. |
| Non functional requirements | City filtering should refresh the calendar without requiring logout or tab reset. |
| Postconditions | Calendar shows hosted events limited to the selected city. |

### UC-BIZ-09: Promote Hosted Event as Trending

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-09 Promote Hosted Event as Trending |
| Summary | A business user marks a hosted event as trending from event details. |
| Dependency | UC-BIZ-05 (Edit Hosted Event) |
| Actors | Primary: Business User. Secondary: Event Service. |
| Preconditions | Business user owns the event and the event is not already trending. |
| Description of the Main Sequence | 1. Business user opens hosted event details.<br>2. System shows Promote event next to host actions.<br>3. Business user taps Promote event.<br>4. System opens the promotion screen and shows event summary fields.<br>5. Business user confirms promotion.<br>6. System updates the event so it appears as trending. |
| Description of the Alternative Sequence | A1. If the event ID is invalid, system shows an invalid event message.<br>A2. If update fails, system shows Could not promote event with the reason. |
| Non functional requirements | Promotion must show a submitting state and prevent repeated confirmation taps. |
| Postconditions | Event is marked trending and can appear in the Discover trending section. |

### UC-BIZ-10: View Business Profile and Hosted Event List

| Section | Details |
| :--- | :--- |
| UC Name | UC-BIZ-10 View Business Profile and Hosted Event List |
| Summary | A business profile page displays host identity and other hosted events. |
| Dependency | UC-BIZ-02 (View Hosted Events Tab) |
| Actors | Primary: Business User or Goer. Secondary: User Profile Service, Event Listing Service. |
| Preconditions | User opens a business or host profile from event details or profile navigation. |
| Description of the Main Sequence | 1. User opens a host or business profile page.<br>2. System loads the host details and hosted events.<br>3. System displays profile summary and other hosted events.<br>4. User taps another hosted event to open its details. |
| Description of the Alternative Sequence | A1. If hosted events cannot load, system shows an error or empty state.<br>A2. If the host has no other events, system shows This host has no other events yet. |
| Non functional requirements | Profile and hosted-event sections should load independently where possible and keep the page scrollable. |
| Postconditions | User can evaluate the business profile and navigate to other hosted events. |