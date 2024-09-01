# Mobile Application Functional Requirements (Module 1)
## 1 - Permission Screen
Functionality:
- Check for location permissions and any other required permissions (location etc).
- Prompt the user to allow these permissions at the first launch and handle denial scenarios.
Requirements:
- Display a message if any permission is denied.
- Ensure permissions are granted before proceeding to the next step (registration or login).
- Option to re-enable permissions if disabled from device settings.
## 2 - Registration
Functionality:
- Allow DA (Delivery Agent) to register by entering:
  - Full Name
  - Mobile Number (validated with OTP for verification)
  - SAP Code (unique identifier)
  - Password (encrypted storage)
  - User Type (DA, Admin, etc.)
- Validate input fields to ensure all mandatory fields are filled in.
Requirements:
- Form validation for correct data format (e.g., valid mobile number format).
- Ensure the SAP code is unique and valid.
- Store user details securely in the backend.
## 3 - Login
Functionality:
- Users log in using their SAP ID and Password.
- Check credentials against the backend system.
- Display an error message for invalid login attempts.
Requirements:
- Enforce password security (e.g., minimum 6 characters).
- Integrate a 'forgot password' flow using the mobile number or email.
## 4 - Auto Login
Functionality:
- Implement a token-based login system.
- Upon the first successful login, store a session or token to allow automatic login on subsequent app launches.
- Verify user status (active/inactive) before automatic login.
Requirements:
- Token/session should expire after a certain period or on logout.
- Implement user inactivity detection to prevent auto login for inactive users.
- Allow manual logout to reset the auto-login functionality.
## 5 - Morning Attendance
Functionality:
- Require users to mark their attendance in the morning before accessing any other functionality.
- Capture and save:
  - Date and time of check-in.
  - GPS location (only if location permission is granted).
Requirements:
- Prevent access to the app's main features if the user has not marked their morning attendance.
- Display a message if attendance is not marked.
- Store attendance details in the backend.
## 6 - Evening Attendance
Functionality:
- Require users to mark their attendance at the end of the day.
- Capture and save:
  - Date and time of check-out.
  - GPS location (only if location permission is granted).
Requirements:
- Prevent closing the app or logging out without marking evening attendance.
- Notify the user if they try to exit without marking attendance.
- Store evening attendance details in the backend.


## 7 - Dashboard
Functionality:
- Display basic and relevant information about the user’s work.
Requirements:
- Fetch and display data in from the backend.
- Provide a clean, responsive layout for the dashboard.
-

**Full Changelog**: https://github.com/IsmailHosenIsmailJames/ODMS_app_rdl_radiant/commits/1.1.0+1

