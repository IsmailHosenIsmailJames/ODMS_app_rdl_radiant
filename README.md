# ODMS App - Radiant Pharmaceuticals Limited

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://your-build-pipeline-url)  <!-- Replace with your build pipeline URL if you have one -->
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) <!--  Add a LICENSE file and link it here -->
[![Last Commit](https://img.shields.io/github/last-commit/IsmailHosenIsmailJames/ODMS_app_rdl_radiant)](https://github.com/IsmailHosenIsmailJames/ODMS_app_rdl_radiant/commits/main)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/IsmailHosenIsmailJames/ODMS_app_rdl_radiant/releases) <!-- Update version number -->

This repository contains the source code for the **Order Delivery Management System (ODMS)** Android application, developed for **Radiant Pharmaceuticals Limited**. This app is a critical tool used by Radiant's delivery personnel (1000-2000+ daily users) to manage and track medicine deliveries to pharmacies and other customers.  It streamlines the delivery process, providing real-time tracking, efficient order management, and robust reporting capabilities.

## Key Features

This app is built with Flutter, providing a consistent and performant experience on Android devices.  It focuses on providing a user-friendly interface while handling the complex requirements of a large-scale delivery operation.  Here's a breakdown of its core functionalities:

*   **Order Management:**
    *   **Delivery Remaining:** View a list of undelivered orders, filterable by date, and searchable by customer or invoice.
    *   **Invoice List:** Access detailed invoice information for each order, including product lists and quantities.
    *   **Product List:** View and manage individual products within an order, including handling returns and calculating amounts.
    *   **Cash Collection:**  Record cash collected from customers, with automatic calculations for received and returned amounts.  Handles overdue payments and tracks collection status.
    *   **Delivery Completion:** Mark orders as delivered, triggering updates to the central system.  Supports both full and partial deliveries.
    *   **Return Management:**  Process product returns efficiently, with accurate calculations to update invoice totals and collected amounts.

*   **Real-Time Tracking & Location Services:**
    *   **Dynamic Location Updates:**  The app transmits the delivery person's location using two methods:
        *   **Time-Based:**  Location is sent via a WebSocket connection every *n* seconds (configurable via API).
        *   **Distance-Based:** Location is sent when the device moves *m* meters (configurable via API).
    *   **Activity Recognition:**  The app detects the user's activity type (Walking, Running, In Vehicle) and includes this information with location updates.  This provides valuable context for delivery tracking.
    *   **Real-Time Data Storage:** Location data is saved in both Firebase (for real-time access) and PostgreSQL (for historical reporting and analysis).
    *   **Customer Location Management:** Delivery personnel can set and update customer locations directly within the app.
    *   **Route Optimization (Basic):**  Displays route information and allows searching for destinations. (Future enhancements could include full route optimization).

*   **Reporting & Analytics:**
    *   **WebView Integration:**  Displays reports generated by the backend system directly within the app using a WebView.  Provides robust error handling for network issues or report generation problems.
    *   **Customer Visit Tracking:**  Logs daily customer visits, providing valuable data for sales and relationship management.
    * **Conveyance Summary** View Daily conveyance.
    * **Overdue Management:** User overdue list.
    * **DashBoard:** View company activity in Dashboard.

*   **User Management & App Updates:**
    *   **Login/Registration:** Secure user authentication with options for registration.  User data is cached locally for offline access (with appropriate security measures).
    *   **Version Control:**  The app enforces updates.  When a new version is available, users are forced to update to ensure they are using the latest features and bug fixes.
    *   **User Information:** Displays user details within the app.

*   **Technical Features:**
    *   **Flutter Framework:**  Built using the Flutter framework for cross-platform compatibility (currently focused on Android).
    *   **WebSocket Communication:** Uses WebSockets for real-time communication with the backend server (primarily for location updates).
    *   **API Integration:**  Extensive use of REST APIs to interact with the backend system for data retrieval, updates, and reporting.
    *   **State Management:**  Employs robust state management (likely Provider or Riverpod, based on commit history) to handle dynamic UI updates and data consistency.
    *   **Background Tasks:** Utilizes background tasks to manage location updates even when the app is not in the foreground.
    *   **Offline Capabilities:**  Caches essential data locally to allow for basic functionality even without an internet connection.
    *   **Error Handling:**  Comprehensive error handling is implemented throughout the app to provide a smooth user experience and prevent crashes.
    *   **Code Quality:**  The codebase is well-organized, with repetitive code moved into common widget functions for maintainability.

## Modules

The application development was divided into modules.  This README focuses on the features delivered in Module 6 (the final module) and previous modules.  Key features implemented in Module 6 include:

1.  **WebView for Reports:**  Displays reports from a URL.
2.  **Customer System Visit Tracking:** Logs daily customer visits.
3.  **Bug Fixes:**  Resolved issues with return calculations and fractions.
4.  **Amount & Calculation Verification:** Thoroughly checked all amounts and calculations.
5.  **Advanced Location Tracking:**  Implemented dynamic, configurable location updates (time-based and distance-based) with activity recognition.
6.  **Real-Time Data Storage:**  Ensured location data is saved in Firebase and PostgreSQL.
7.  **Version Control & Forced Updates:**  Implemented a robust version control system.
8.  **Copyright Information:** Added copyright and "Developed by" information.
9.   **UI and kotlin+gradle version upgrade:** App is Upgraded to Latest version.


## Getting Started (For Developers)

1.  **Prerequisites:**
    *   Flutter SDK (latest stable version recommended)
    *   Android Studio (latest stable version, "LadyBug" or later recommended) or VS Code with Flutter extensions
    *   An Android emulator or a physical Android device for testing
    *   Access to the backend API server (you'll need the API endpoints and any necessary authentication credentials)
    *   Firebase project setup (for real-time location data)
    *   PostgreSQL database setup (for location data storage)

2.  **Clone the Repository:**

    ```bash
    git clone https://github.com/IsmailHosenIsmailJames/ODMS_app_rdl_radiant.git
    cd ODMS_app_rdl_radiant
    ```

3.  **Install Dependencies:**

    ```bash
    flutter pub get
    ```

4.  **Configuration:**
    *   You'll likely need to configure API endpoints, Firebase credentials, and database connection details.  Look for configuration files within the project (e.g., `lib/config`, `lib/services`, or similar) and update them with your specific settings.  *This is a crucial step that is not explicitly detailed in the commit history.*

5.  **Run the App:**

    ```bash
    flutter run
    ```

    This will build and run the app on your connected device or emulator.

## Future Enhancements

*   **Full Route Optimization:** Integrate a more sophisticated route optimization service to provide the most efficient delivery routes.
*   **Offline Maps:**  Allow users to download maps for offline use, ensuring navigation capabilities even in areas with poor connectivity.
*   **Push Notifications:** Implement push notifications to alert delivery personnel of new orders, updates, or important messages.
*   **Inventory Management:**  Integrate with an inventory management system to track stock levels and ensure accurate delivery information.
*   **iOS Support:**  Extend the app's functionality to iOS devices.
*   **Enhanced Reporting:**  Add more detailed reporting features and visualizations within the app.
*   **Performance Optimizations:**  Continue to optimize the app's performance, particularly for handling large datasets and frequent location updates.

## Contributing

Contributions to this project are welcome!  If you find any bugs or have suggestions for improvements, please open an issue or submit a pull request. Please follow the established coding style and provide clear commit messages.

## License
This Project is developed by MD. Ismail Hosen James.

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details. (You'll need to create a LICENSE file).  You may need to adjust the license based on Radiant Pharmaceutical's requirements.  The provided description assumes a standard open-source license for demonstration purposes.

---

**Important Notes:**

*   **API Keys and Credentials:** This README assumes you have access to the necessary API keys, database credentials, and Firebase configuration details.  These are *essential* for running the app but are not included in the public repository for security reasons.
*   **Backend System:**  This README describes the mobile app's functionality.  It assumes a separate backend system exists to handle data storage, reporting, and other server-side logic.  The details of the backend system are outside the scope of this README.
*   **Database Setup:**  You'll need to set up both Firebase and PostgreSQL databases and configure the app to connect to them.  The specifics of this setup will depend on your environment.
*   This is best description as per your requirements.
