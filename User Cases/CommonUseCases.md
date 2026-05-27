## Common Use Cases

### UC-COM-01: Register Account

| Section | Details |
| :--- | :--- |
| UC Name | UC-COM-01 Register Account |
| Summary | A new user creates an account from the signup flow. |
| Dependency | UC-COM-03 (View Landing Page Entry Actions) |
| Actors | Primary: Visitor. Secondary: Account Service, Media Upload Service. |
| Preconditions | Visitor is on the signup page and can reach the configured backend server. |
| Description of the Main Sequence | 1. Visitor selects Sign up from the landing or login page.<br>2. System shows the multi-step signup form.<br>3. Visitor chooses Goer or Business role and enters account details.<br>4. Visitor selects required profile images and role-specific details.<br>5. Visitor reviews the summary and taps Create account.<br>6. System creates the account and logs the user into the app. |
| Description of the Alternative Sequence | A1. If required fields are missing or invalid, system highlights the field and stays on the current step.<br>A2. If image upload or account creation fails, system shows an error and lets the visitor retry. |
| Non functional requirements | Form validation must give immediate feedback; network failures must not clear entered form data. |
| Postconditions | A user account exists and the user reaches the main app or is asked to log in manually. |

### UC-COM-02: Log In

| Section | Details |
| :--- | :--- |
| UC Name | UC-COM-02 Log In |
| Summary | A registered user signs in with email and password. |
| Dependency | UC-COM-03 (View Landing Page Entry Actions) |
| Actors | Primary: Registered User. Secondary: Authentication Service. |
| Preconditions | User has an existing account and the backend server is reachable. |
| Description of the Main Sequence | 1. User opens the login page.<br>2. User enters email and password.<br>3. User taps Log in.<br>4. System validates credentials and stores the session token.<br>5. System opens the role-specific main navigation. |
| Description of the Alternative Sequence | A1. If credentials are invalid, system shows an error on the login page.<br>A2. If the server is unreachable, system shows a network failure message. |
| Non functional requirements | Login should complete within the configured request timeout; stored tokens must use secure storage. |
| Postconditions | User is authenticated and routed to Goer, Business, or Admin screens. |

### UC-COM-03: View Landing Page Entry Actions

| Section | Details |
| :--- | :--- |
| UC Name | UC-COM-03 View Landing Page Entry Actions |
| Summary | A visitor uses the landing page to enter the app through login or signup. |
| Dependency | None |
| Actors | Primary: Visitor. |
| Preconditions | App has launched and no active session has moved the user into the main app. |
| Description of the Main Sequence | 1. Visitor opens the app.<br>2. System shows the landing page with the product message and entry actions.<br>3. Visitor taps Login or Sign up.<br>4. System opens the selected authentication page. |
| Description of the Alternative Sequence | A1. If a stored authenticated user is available, system can move directly to the main app.<br>A2. If navigation fails, visitor remains on the landing page. |
| Non functional requirements | Landing page must render quickly on mobile devices and keep entry buttons visible. |
| Postconditions | Visitor is taken to the selected authentication flow. |

### UC-COM-04: Edit Profile

| Section | Details |
| :--- | :--- |
| UC Name | UC-COM-04 Edit Profile |
| Summary | A logged-in user edits visible profile information from Settings. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Logged-in User. Secondary: Profile Service. |
| Preconditions | User is authenticated and opens Settings from the Profile area. |
| Description of the Main Sequence | 1. User opens Profile from the main navigation.<br>2. User opens Settings and taps Profile.<br>3. System shows editable profile fields such as name, email, phone, and avatar information.<br>4. User updates values and saves.<br>5. System stores the updated profile and refreshes visible user information. |
| Description of the Alternative Sequence | A1. If a value is invalid, system keeps the user on the form and shows validation feedback.<br>A2. If save fails, system shows an error and keeps the previous profile state. |
| Non functional requirements | Profile updates should complete within the request timeout and avoid losing unsaved edits on failure. |
| Postconditions | The user's profile information is updated in the app. |

### UC-COM-05: Change Appearance Settings

| Section | Details |
| :--- | :--- |
| UC Name | UC-COM-05 Change Appearance Settings |
| Summary | A user changes the app theme preference from Settings. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Logged-in User. Secondary: Local Theme Controller. |
| Preconditions | User is authenticated and opens Settings. |
| Description of the Main Sequence | 1. User opens Settings.<br>2. User taps Appearance.<br>3. System shows theme options.<br>4. User chooses the preferred appearance.<br>5. System applies and saves the theme setting. |
| Description of the Alternative Sequence | A1. If the setting cannot be saved, system keeps the current visible theme.<br>A2. If the user leaves without changing anything, system keeps the previous preference. |
| Non functional requirements | Theme changes should apply immediately and persist after app restart. |
| Postconditions | The app uses the selected appearance preference. |

### UC-COM-06: View Global Notifications

| Section | Details |
| :--- | :--- |
| UC Name | UC-COM-06 View Global Notifications |
| Summary | A non-admin user views published platform announcements from Settings. |
| Dependency | UC-COM-02 (Log In) |
| Actors | Primary: Goer or Business User. Secondary: Notification Service. |
| Preconditions | User is authenticated as a non-admin and opens Settings. |
| Description of the Main Sequence | 1. User opens Settings.<br>2. User taps Announcements.<br>3. System loads published global notifications.<br>4. User reads announcement titles, messages, and timing details. |
| Description of the Alternative Sequence | A1. If no announcements are active, system shows an empty state.<br>A2. If loading fails, system shows an error or retry state. |
| Non functional requirements | Announcement lists should filter out unpublished or inactive items and remain readable on mobile screens. |
| Postconditions | User has seen the current platform announcements. |
