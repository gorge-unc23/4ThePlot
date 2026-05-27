## Goer Use Cases

### UC-GO-01: Discover Trending Events

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-01 Discover Trending Events |
| Summary | A goer browses trending events from the Home tab. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Goer. Secondary: Event Listing Service. |
| Preconditions | Goer is authenticated and opens the Home tab. |
| Description of the Main Sequence | 1. Goer opens Discover Events.<br>2. System loads the Trending Events section.<br>3. Goer scrolls the horizontal event cards.<br>4. Goer taps a card to inspect an event. |
| Description of the Alternative Sequence | A1. If no trending events exist, system shows a no-events message.<br>A2. If loading fails, system shows an error and Try again action. |
| Non functional requirements | Event cards should load within the request timeout and avoid showing events hosted by the current user. |
| Postconditions | Goer can choose an event to view in detail. |

### UC-GO-02: View Nearby Events

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-02 View Nearby Events |
| Summary | A goer views events near the current device location. |
| Dependency | UC-GO-01 (Discover Trending Events) |
| Actors | Primary: Goer. Secondary: Location Service, Event Listing Service. |
| Preconditions | Goer is authenticated and the Discover page is open. |
| Description of the Main Sequence | 1. System asks for location service and permission when needed.<br>2. Goer grants location access.<br>3. System loads nearby events.<br>4. Goer scrolls the Events near you list and selects an event. |
| Description of the Alternative Sequence | A1. If location permission is denied, system shows a message explaining that permission is required.<br>A2. If no nearby events exist, system shows a no-events message. |
| Non functional requirements | Location lookup should time out gracefully; denied permissions must not block trending event browsing. |
| Postconditions | Goer sees nearby events or a clear reason why they are unavailable. |

### UC-GO-03: Search Events

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-03 Search Events |
| Summary | A goer searches visible events by text. |
| Dependency | UC-GO-01 (Discover Trending Events) |
| Actors | Primary: Goer. Secondary: Event Search Service. |
| Preconditions | Goer is authenticated and the Discover page is open. |
| Description of the Main Sequence | 1. Goer taps the search field.<br>2. Goer enters a search term for an event, venue, or city.<br>3. Goer submits the search.<br>4. System shows matching results.<br>5. Goer taps a result to open event details. |
| Description of the Alternative Sequence | A1. If the search field is cleared, system returns to normal discovery content.<br>A2. If there are no matches, system shows No results found.<br>A3. If search fails, system shows Search failed and a retry action. |
| Non functional requirements | Search must reject empty queries and keep the UI responsive while loading. |
| Postconditions | Goer sees search results or a visible empty/error state. |

### UC-GO-04: View Event Details

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-04 View Event Details |
| Summary | A goer opens a full event page from discovery, calendar, map, or host profile. |
| Dependency | UC-GO-01 (Discover Trending Events) |
| Actors | Primary: Goer. Secondary: Event Details Service. |
| Preconditions | Event is visible in a list, map, calendar, or hosted-events section. |
| Description of the Main Sequence | 1. Goer taps an event card or list item.<br>2. System opens the event details page.<br>3. System shows image, title, status, date, venue, capacity, host, description, categories, tags, and comments.<br>4. Goer chooses a next action such as join, share, report, or view host. |
| Description of the Alternative Sequence | A1. If details are stale or unavailable, system keeps available event data and shows errors for failed dependent sections.<br>A2. If comments fail to load, system shows a comment loading error without blocking the rest of the page. |
| Non functional requirements | Detail pages should remain scrollable while secondary data loads. |
| Postconditions | Goer has enough visible information to act on the event. |

### UC-GO-05: View Host Profile

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-05 View Host Profile |
| Summary | A goer opens a host profile from the event details page. |
| Dependency | UC-GO-04 (View Event Details) |
| Actors | Primary: Goer. Secondary: User Profile Service, Event Listing Service. |
| Preconditions | Event details show a tappable host link. |
| Description of the Main Sequence | 1. Goer taps Hosted by on the event details page.<br>2. System opens the business or host profile page.<br>3. System shows host identity, credibility information, and other hosted events.<br>4. Goer can open another hosted event or report the host. |
| Description of the Alternative Sequence | A1. If the host profile cannot load, system shows an error or fallback host name.<br>A2. If the host has no other events, system shows an empty hosted-events message. |
| Non functional requirements | Host profile loading must not freeze the event details page navigation. |
| Postconditions | Goer has reviewed visible host information. |

### UC-GO-06: Join Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-06 Join Event |
| Summary | A goer joins an event from the event details page. |
| Dependency | UC-GO-04 (View Event Details) |
| Actors | Primary: Goer. Secondary: Registration Service. |
| Preconditions | Goer is not the host, is not an admin, and has not already joined the event. |
| Description of the Main Sequence | 1. Goer taps Join event on the event details page.<br>2. System opens the join confirmation screen.<br>3. Goer reviews event, date, location, quantity, and cost display.<br>4. Goer confirms the join.<br>5. System registers the goer and returns to the event details page. |
| Description of the Alternative Sequence | A1. If event capacity is full, system shows an error from the join attempt.<br>A2. If registration fails, system keeps the goer on the join screen and displays the failure reason. |
| Non functional requirements | Registration requests must avoid duplicate visible joins and respect capacity limits. |
| Postconditions | Goer is registered and the event details page can show Unregister. |

### UC-GO-07: Unregister From Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-07 Unregister From Event |
| Summary | A goer leaves an event they previously joined. |
| Dependency | UC-GO-06 (Join Event) |
| Actors | Primary: Goer. Secondary: Registration Service. |
| Preconditions | Goer is authenticated and the event details page shows an existing registration. |
| Description of the Main Sequence | 1. Goer opens the joined event details page.<br>2. System shows the Unregister action.<br>3. Goer taps Unregister.<br>4. System removes the registration.<br>5. System updates the visible action back to Join event. |
| Description of the Alternative Sequence | A1. If unregister fails, system shows an error and keeps the registered state visible.<br>A2. If the registration no longer exists, system refreshes the visible state. |
| Non functional requirements | Unregister action should complete within the request timeout and update capacity display after refresh. |
| Postconditions | Goer is no longer registered for the event. |

### UC-GO-08: View Joined Events Calendar

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-08 View Joined Events Calendar |
| Summary | A goer views joined events grouped by date in the Calendar tab. |
| Dependency | UC-GO-06 (Join Event) |
| Actors | Primary: Goer. Secondary: Event Listing Service. |
| Preconditions | Goer is authenticated and opens the Calendar tab. |
| Description of the Main Sequence | 1. Goer opens Calendar.<br>2. System loads events joined by the goer.<br>3. System marks dates with event indicators.<br>4. Goer selects a date.<br>5. System shows events for the selected date and allows opening details. |
| Description of the Alternative Sequence | A1. If the goer has no joined events, system shows an empty calendar message.<br>A2. If loading fails, system shows an error and retry option. |
| Non functional requirements | Calendar date selection must remain responsive even when the event list is empty. |
| Postconditions | Goer can review joined events by date. |

### UC-GO-09: View Events on Map

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-09 View Events on Map |
| Summary | A goer views event locations from the Map tab. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Goer. Secondary: Map UI, Event Listing Service. |
| Preconditions | Goer is authenticated and opens the Map tab. |
| Description of the Main Sequence | 1. Goer opens Map.<br>2. System loads visible events with location data.<br>3. System displays event markers or location items.<br>4. Goer selects an event location to inspect or navigate to event details. |
| Description of the Alternative Sequence | A1. If events cannot load, system shows an error state.<br>A2. If an event has missing coordinates, system omits or degrades that map item. |
| Non functional requirements | Map interactions should remain usable on mobile screens and avoid blocking navigation. |
| Postconditions | Goer can inspect events geographically. |

### UC-GO-10: Add Event Comment

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-10 Add Event Comment |
| Summary | A goer posts a comment on an event details page. |
| Dependency | UC-GO-04 (View Event Details) |
| Actors | Primary: Goer. Secondary: Comment Service. |
| Preconditions | Goer is authenticated, is not the event host, is not an admin, and event details are open. |
| Description of the Main Sequence | 1. Goer scrolls to Comments.<br>2. Goer types text in the comment composer.<br>3. Goer taps the send icon or submits from the keyboard.<br>4. System saves the comment.<br>5. System adds the comment to the visible list. |
| Description of the Alternative Sequence | A1. If text is empty, system does not submit.<br>A2. If save fails, system shows an error and leaves the typed text available. |
| Non functional requirements | Comment posting should show a loading state and prevent duplicate taps while submitting. |
| Postconditions | The new comment appears in the event comments list. |

### UC-GO-11: Share Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-11 Share Event |
| Summary | A goer shares an event from the event details page. |
| Dependency | UC-GO-04 (View Event Details) |
| Actors | Primary: Goer. Secondary: Device Share Sheet. |
| Preconditions | Goer is viewing an event details page. |
| Description of the Main Sequence | 1. Goer taps the share icon near the event title.<br>2. System creates share text with the event title and link.<br>3. Device share sheet opens.<br>4. Goer selects a target app or cancels. |
| Description of the Alternative Sequence | A1. If the share sheet fails, system shows Could not share event.<br>A2. If goer cancels, no event data changes. |
| Non functional requirements | Sharing must use the platform share sheet and should not require extra backend calls. |
| Postconditions | Event information is handed to the selected sharing target or no change occurs. |

### UC-GO-12: Report Event

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-12 Report Event |
| Summary | A goer reports an event from the event details page. |
| Dependency | UC-GO-04 (View Event Details) |
| Actors | Primary: Goer. Secondary: Safety Report Service. |
| Preconditions | Goer is authenticated, is not the event host, and event details are open. |
| Description of the Main Sequence | 1. Goer taps Report event.<br>2. System opens the report dialog.<br>3. Goer selects severity and enters a reason.<br>4. Goer submits the report.<br>5. System saves the report and confirms submission. |
| Description of the Alternative Sequence | A1. If the dialog is cancelled, no report is created.<br>A2. If submission fails, system shows an error and keeps the user on the event page. |
| Non functional requirements | Report submission should prevent duplicate taps while the request is active. |
| Postconditions | A safety report for the event is available for admin review. |

### UC-GO-13: Report Comment

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-13 Report Comment |
| Summary | A goer reports another user's event comment. |
| Dependency | UC-GO-04 (View Event Details) |
| Actors | Primary: Goer. Secondary: Safety Report Service. |
| Preconditions | Goer is authenticated, comments are visible, and the target comment was not written by the goer. |
| Description of the Main Sequence | 1. Goer taps the flag icon on a comment.<br>2. System opens the report dialog.<br>3. Goer enters a reason and severity.<br>4. Goer submits the report.<br>5. System confirms that the report was submitted for review. |
| Description of the Alternative Sequence | A1. If the report dialog is cancelled, no report is created.<br>A2. If submission fails, system shows an error message. |
| Non functional requirements | Only eligible comments should show the report control to the current goer. |
| Postconditions | A safety report for the comment is available for admin review. |

### UC-GO-14: Report Host

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-14 Report Host |
| Summary | A goer reports a host from the host profile page. |
| Dependency | UC-GO-05 (View Host Profile) |
| Actors | Primary: Goer. Secondary: Safety Report Service. |
| Preconditions | Goer is viewing a host profile that can be reported. |
| Description of the Main Sequence | 1. Goer taps the report host action.<br>2. System opens the report dialog.<br>3. Goer provides reason and severity.<br>4. Goer submits the report.<br>5. System confirms that the host report was submitted. |
| Description of the Alternative Sequence | A1. If host data is unavailable, system disables or blocks the report action.<br>A2. If submission fails, system shows an error. |
| Non functional requirements | Host reporting should show progress while submitting and prevent duplicate submissions. |
| Postconditions | A safety report for the host is available for admin review. |

### UC-GO-15: Submit Host Verification Request

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-15 Submit Host Verification Request |
| Summary | A user submits documents for host verification from Settings. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Logged-in User. Secondary: Verification Service, Document Upload Service. |
| Preconditions | User opens Settings and taps Verification. |
| Description of the Main Sequence | 1. User opens the Verification settings page.<br>2. System shows trusted status and existing requests.<br>3. User starts a new verification request.<br>4. User selects a PDF document.<br>5. System uploads the document and attaches it to the request.<br>6. System shows the request in the verification page. |
| Description of the Alternative Sequence | A1. If a PDF is not selected, system does not submit the request.<br>A2. If an active request already exists or upload fails, system shows an error. |
| Non functional requirements | Only PDF documents should be accepted; submission progress must be visible. |
| Postconditions | A host verification request is visible with submitted document details. |

### UC-GO-16: Delete Host Verification Request

| Section | Details |
| :--- | :--- |
| UC Name | UC-GO-16 Delete Host Verification Request |
| Summary | A user deletes one of their host verification requests from Settings. |
| Dependency | UC-GO-15 (Submit Host Verification Request) |
| Actors | Primary: Logged-in User. Secondary: Verification Service. |
| Preconditions | User has at least one visible verification request. |
| Description of the Main Sequence | 1. User opens Settings and taps Verification.<br>2. System lists the user's verification requests.<br>3. User taps delete on a request.<br>4. System asks for confirmation.<br>5. User confirms deletion.<br>6. System removes the request from the visible list. |
| Description of the Alternative Sequence | A1. If user cancels confirmation, the request remains.<br>A2. If deletion fails, system shows an error and keeps the request visible. |
| Non functional requirements | Deleting a request must require confirmation to avoid accidental removal. |
| Postconditions | The selected verification request is no longer listed for the user. |
