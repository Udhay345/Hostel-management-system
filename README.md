<div align="center">

# 🏠 Hostel Management System

**A modern Flutter application for seamless hostel administration**

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Material Design](https://img.shields.io/badge/Material-Design%203-757575?style=for-the-badge&logo=material-design&logoColor=white)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Simplifying hostel life for students and wardens alike.*

</div>

---

## 📖 Overview

The **Hostel Management System** is a full-featured Flutter application designed to digitize and streamline hostel operations. It supports two distinct user roles — **Student** and **Admin (Warden)** — each with a tailored dashboard and feature set, backed by Firebase for real-time data sync.

---

## ✨ Features

<table>
<tr>
<td width="50%" valign="top">

### 👨‍🎓 Student Portal
| Screen | Description |
|---|---|
| 🎨 Splash Screen | Branded welcome screen |
| 🔑 Login Selector | Choose role or sign up |
| 🔒 Student Login | Username/password auth |
| 📝 Sign Up | New student registration |
| 🏠 Dashboard | Sidebar-driven main view |
| 📅 Apply Leave | Submit dated leave requests |
| 📢 Raise Complaint | Categorized complaint form |
| 🍽️ Mess Poll | Vote on weekly mess menu |

</td>
<td width="50%" valign="top">

### 👨‍🏫 Admin (Warden) Portal
| Screen | Description |
|---|---|
| 🔐 Admin Login | Mobile number + biometric toggle |
| 📊 Dashboard | Stats overview & quick actions |
| 📷 Scan Attendance | QR code scanner simulation |
| 📋 View Complaints | Manage & update complaint status |
| 📄 Leave Applications | Approve or reject leave requests |
| 📊 Post Weekly Poll | Create dynamic mess polls |

</td>
</tr>
</table>

---

## 🚀 Getting Started

### Prerequisites

Ensure the following are installed on your machine:

| Tool | Version |
|---|---|
| Flutter SDK | 3.0.0 or higher |
| Dart SDK | 3.0.0 or higher |
| Android Studio / VS Code | Latest |
| Android Emulator / Physical Device | API 21+ |

### Installation

**1. Clone the repository**
```bash
git clone <repository-url>
cd hostel_management_system
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Firebase** *(see [Security & Privacy](#-security--privacy))*

**4. Run the app**
```bash
flutter run
```

---

## 🔑 Demo Credentials

> These credentials are for demonstration purposes only.

<table>
<tr>
<th>Role</th>
<th>Field</th>
<th>Value</th>
</tr>
<tr>
<td rowspan="2">👨‍🎓 Student</td>
<td>Username</td>
<td><code>student01</code></td>
</tr>
<tr>
<td>Password</td>
<td><code>pass123</code></td>
</tr>
<tr>
<td rowspan="2">👨‍🏫 Admin</td>
<td>Mobile</td>
<td><code>9999999999</code></td>
</tr>
<tr>
<td>Password</td>
<td><code>admin123</code></td>
</tr>
</table>

---

## 🗂️ Project Structure

```
lib/
├── main.dart                               # App entry point & Firebase init
└── screens/
    ├── splash_screen.dart                  # Branded welcome screen
    ├── login_selector_screen.dart          # Role selection hub
    ├── student_login_screen.dart           # Student authentication
    ├── admin_login_screen.dart             # Admin authentication
    ├── signup_screen.dart                  # New student registration
    ├── student_dashboard_screen.dart       # Student main interface
    ├── apply_leave_screen.dart             # Leave application form
    ├── raise_complaint_screen.dart         # Complaint submission
    ├── mess_poll_screen.dart               # Poll voting interface
    ├── admin_dashboard_screen.dart         # Admin main interface
    ├── scan_attendance_screen.dart         # QR attendance scanner
    ├── view_complaints_screen.dart         # Complaint management
    ├── view_leave_applications_screen.dart # Leave approval flow
    └── post_weekly_poll_screen.dart        # Poll creation
```

---

## 🛠️ Technical Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **Backend** | Firebase (Auth + Firestore) |
| **UI System** | Material Design 3 |
| **State Management** | `setState` (built-in) |

### Architecture Highlights

- 🔐 **Authentication** — Firebase Auth with form validation, loading states, and user feedback
- 📱 **Responsive UI** — Material 3 components with intuitive drawer navigation and color-coded indicators
- 📡 **Real-time Sync** — Attendance, complaints, and leave applications are synced live to Firestore
- 🧪 **Simulation** — QR scanning is simulated for demo environments without physical scanner hardware

---

## 📋 Usage Guide

```
1. 🚀  Launch the app         →  Splash screen plays for 2 seconds
2. 👤  Select your role       →  Student Login, Admin Login, or Sign Up
3. 🔑  Authenticate           →  Use demo credentials or your Firebase account
4. 🏠  Explore dashboard      →  Open the drawer to navigate between features
5. ✅  Perform actions         →  Submit forms, vote on polls, manage requests
```

---

## 🔒 Security & Privacy

> [!IMPORTANT]
> Firebase API keys and configuration files in this repository have been masked to protect sensitive credentials.
>
> **To connect your own Firebase project:**
> 1. Create a new project at the [Firebase Console](https://console.firebase.google.com/).
> 2. Register your Android/iOS app and download:
>    - `google-services.json` → place in `android/app/`
>    - `GoogleService-Info.plist` → place in `ios/Runner/`
> 3. Replace the placeholder values in `lib/firebase_options.dart` with your own credentials.
> 4. Enable **Email/Password** authentication in Firebase Auth settings.
> 5. Create a **Firestore** database in test mode to get started.

---

## 🔮 Roadmap

- [ ] 🔔 Push notifications for leave/complaint status updates
- [ ] 📸 Image upload support for complaint evidence
- [ ] 📷 Real QR code scanning with `mobile_scanner`
- [ ] 💾 Offline support with local data persistence (`Hive` / `sqflite`)
- [ ] 👤 User profile management & avatar upload
- [ ] 📈 Advanced analytics dashboard for admins
- [ ] 🌙 Dark mode support
- [ ] 🌐 Multi-language (i18n) support

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ using Flutter &nbsp;|&nbsp; Powered by Firebase

</div>
