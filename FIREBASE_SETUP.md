# Firebase Setup Guide for Hostel Management System

This guide will help you set up Firebase authentication and Firestore database for your Flutter hostel management app.

## Prerequisites

1. A Firebase project (you mentioned you already have one)
2. Flutter SDK installed
3. Android Studio / VS Code

## Step 1: Get Firebase Configuration Files

### For Android:
1. Go to your [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on the gear icon (⚙️) next to "Project Overview"
4. Select "Project settings"
5. Scroll down to "Your apps" section
6. Click on the Android icon (🤖) to add an Android app
7. Enter your package name: `com.example.hostel_management_system`
8. Click "Register app"
9. Download the `google-services.json` file
10. Place it in `android/app/google-services.json`

### For iOS:
1. In the same Firebase project settings
2. Click on the iOS icon (🍎) to add an iOS app
3. Enter your bundle ID: `com.example.hostelManagementSystem`
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place it in `ios/Runner/GoogleService-Info.plist`

## Step 2: Update Configuration Files

### Replace the placeholder values in the configuration files:

**For Android (`android/app/google-services.json`):**
- Replace `YOUR_PROJECT_NUMBER` with your actual project number
- Replace `YOUR_PROJECT_ID` with your actual project ID
- Replace `YOUR_APP_ID` with your actual app ID
- Replace `YOUR_CLIENT_ID` with your actual client ID
- Replace `YOUR_API_KEY` with your actual API key

**For iOS (`ios/Runner/GoogleService-Info.plist`):**
- Replace `YOUR_CLIENT_ID` with your actual client ID
- Replace `YOUR_REVERSED_CLIENT_ID` with your actual reversed client ID
- Replace `YOUR_API_KEY` with your actual API key
- Replace `YOUR_PROJECT_NUMBER` with your actual project number
- Replace `YOUR_PROJECT_ID` with your actual project ID
- Replace `YOUR_APP_ID` with your actual app ID

## Step 3: Enable Authentication in Firebase Console

1. In your Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to the "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Click "Save"

## Step 4: Set up Firestore Database

1. In your Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database
5. Click "Done"

## Step 5: Set up Firestore Security Rules

1. In Firestore Database, go to the "Rules" tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own data
    match /students/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /admins/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow admins to read all student data
    match /students/{document=**} {
      allow read: if request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
  }
}
```

## Step 6: Install Dependencies

Run the following command to install Firebase dependencies:

```bash
flutter pub get
```

## Step 7: Test the Integration

1. Run your app: `flutter run`
2. Try to sign up as a student or admin
3. Try to log in with the created credentials
4. Check the Firebase Console to see if users are being created

## Features Implemented

### Authentication:
- ✅ Student signup with email/password
- ✅ Admin signup with email/password
- ✅ Student login with email/password
- ✅ Admin login with email/password
- ✅ Logout functionality
- ✅ User type validation (student vs admin)

### Database Structure:
- **Students Collection**: Stores student data (name, email, room number, attendance)
- **Admins Collection**: Stores admin data (name, email, mobile)

### Security:
- Users can only access their own data
- Admins can read all student data
- Email/password authentication required

## Troubleshooting

### Common Issues:

1. **"Target of URI doesn't exist" errors**: Run `flutter pub get` to install dependencies

2. **Firebase initialization error**: Make sure your configuration files are properly placed and contain correct values

3. **Authentication errors**: Check if Email/Password authentication is enabled in Firebase Console

4. **Permission denied errors**: Check your Firestore security rules

### Debug Commands:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check Firebase connection
flutter doctor
```

## Next Steps

After setting up Firebase, you can:

1. **Add more user data fields** in the signup forms
2. **Implement real-time data** for attendance tracking
3. **Add push notifications** for important updates
4. **Implement file upload** for profile pictures
5. **Add email verification** for new accounts

## Support

If you encounter any issues:
1. Check the Firebase Console for error logs
2. Verify your configuration files are correct
3. Ensure all dependencies are installed
4. Check Flutter and Firebase documentation

---

**Note**: Make sure to replace all placeholder values in the configuration files with your actual Firebase project credentials before testing the app. 