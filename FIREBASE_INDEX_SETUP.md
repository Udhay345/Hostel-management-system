# Firebase Index Setup Guide

## Required Indexes for RIT HMS

To resolve the "failed-precondition" errors you're seeing, you need to create the following composite indexes in your Firebase Firestore:

### 1. Out Pass Applications Index
**Collection:** `outpass_applications`
**Fields:**
- `studentUid` (Ascending)
- `appliedDate` (Descending)

### 2. Notifications Index
**Collection:** `notifications`
**Fields:**
- `userId` (Ascending)
- `timestamp` (Descending)

### 3. Leave Applications Index
**Collection:** `leave_applications`
**Fields:**
- `studentUid` (Ascending)
- `appliedDate` (Descending)

## How to Create Indexes

### Method 1: Using Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Firestore Database
4. Click on the "Indexes" tab
5. Click "Create Index"
6. Add the fields as specified above
7. Click "Create"

### Method 2: Using the Error Link
When you see the error message with a link like:
```
https://console.firebase.google.com/v1/r/project/ozone-d045b/firestore/indexes?create_composite=...
```

1. Click on the link in the error message
2. It will take you directly to the Firebase Console with the index pre-configured
3. Click "Create Index"

## Index Creation Time
- Indexes typically take 1-5 minutes to build
- You'll see a "Building" status while the index is being created
- Once complete, the status will change to "Enabled"

## Troubleshooting
- If indexes are still not working after creation, wait a few more minutes
- Refresh your app after index creation
- Check the Firebase Console to ensure indexes are "Enabled"

## Note
The app has been updated to handle index errors gracefully, so you should see a user-friendly message instead of the raw error while indexes are being created. 