# Hostel Management System - Flutter App

A Flutter application for managing hostel operations with two user roles: Student and Admin (Warden).

## Features

### 👨‍🎓 Student Side
- **Splash Screen**: Welcome screen with app branding
- **Login Selector**: Choose between Student, Admin login, or Sign Up
- **Student Login**: Username/password authentication
- **Sign Up**: New student registration form
- **Student Dashboard**: Main interface with sidebar navigation
- **Apply Leave**: Submit leave applications with date selection
- **Raise Complaint**: Submit complaints with categorization
- **Mess Poll & Feedback**: Vote on weekly polls and provide feedback

### 👨‍🏫 Admin Side
- **Admin Login**: Mobile number/password authentication with biometric toggle
- **Admin Dashboard**: Overview with statistics and quick actions
- **Scan Attendance**: QR code scanner simulation for marking attendance
- **View Complaints**: List and manage student complaints
- **View Leave Applications**: Review and approve/reject leave requests
- **Post Weekly Poll**: Create polls with 3-6 options for students

## Demo Credentials

### Student Login
- **Username**: `student01`
- **Password**: `pass123`

### Admin Login
- **Mobile**: `9999999999`
- **Password**: `admin123`

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd hostel_management_system
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## App Structure

```
lib/
├── main.dart                          # App entry point
└── screens/
    ├── splash_screen.dart             # Welcome screen
    ├── login_selector_screen.dart     # Role selection
    ├── student_login_screen.dart      # Student authentication
    ├── admin_login_screen.dart        # Admin authentication
    ├── signup_screen.dart             # Student registration
    ├── student_dashboard_screen.dart  # Student main interface
    ├── apply_leave_screen.dart        # Leave application form
    ├── raise_complaint_screen.dart    # Complaint submission
    ├── mess_poll_screen.dart          # Poll voting interface
    ├── admin_dashboard_screen.dart    # Admin main interface
    ├── scan_attendance_screen.dart    # Attendance scanner
    ├── view_complaints_screen.dart    # Complaint management
    ├── view_leave_applications_screen.dart # Leave management
    └── post_weekly_poll_screen.dart   # Poll creation
```

## Key Features

### 🔐 Authentication
- Hardcoded dummy credentials for demonstration
- Form validation and error handling
- Loading states and user feedback

### 📱 User Interface
- Material Design 3 components
- Responsive layout with proper spacing
- Intuitive navigation with drawer menus
- Color-coded status indicators

### 📊 Data Management
- In-memory data storage (no persistence)
- Simulated API calls with delays
- Form validation and error handling
- State management using setState

### 🎯 Functionality
- **Student Features**:
  - View attendance overview
  - Apply for leave with date selection
  - Submit complaints with categories
  - Vote on weekly mess polls
  - Provide additional feedback

- **Admin Features**:
  - View dashboard statistics
  - Simulate attendance scanning
  - Manage complaints with status updates
  - Review and approve/reject leave applications
  - Create weekly polls with dynamic options

## Technical Details

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **Backend**: Firebase (Authentication, Firestore)
- **UI**: Material Design 3

## Usage Instructions

1. **Start the app** - Splash screen appears for 2 seconds
2. **Choose role** - Select Student Login, Admin Login, or Sign Up
3. **Login** - Use provided credentials or your own Firebase user
4. **Navigate** - Use the drawer menu to access features
5. **Interact** - Submit data and view real-time updates in Firestore

## Security & Privacy

> [!IMPORTANT]
> To protect sensitive information, the Firebase API keys and configuration files in this repository have been masked.
>
> To use your own Firebase setup:
> 1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
> 2. Add your own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
> 3. Update `lib/firebase_options.dart` with your credentials.

## Notes

- This app uses Firebase for data storage and auth.
- Attendance, complaints, and leave applications are synced to Firestore.
- QR code scanning is simulated for demonstration purposes.
- All Firebase keys are masked in `lib/firebase_options.dart` for security.

## Future Enhancements

- Backend integration with real database
- Push notifications for updates
- Image upload for complaints
- Real QR code scanning
- Data persistence with local storage
- User profile management
- Advanced reporting and analytics 