# Firebase Console Setup Instructions

## Step 1: Enable Firebase Authentication

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project: `fitnessapp-54afb`
3. In the left sidebar, click on **Authentication**
4. Click **Get started** if you haven't set it up yet
5. Go to **Sign-in method** tab
6. Enable **Email/Password**:
   - Click on **Email/Password**
   - Toggle **Enable** to ON
   - Click **Save**
7. Enable **Google** (optional):
   - Click on **Google**
   - Toggle **Enable** to ON
   - Add your support email
   - Click **Save**

## Step 2: Create Firestore Database

1. In the left sidebar, click on **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (we'll secure it later)
4. Select a location (choose the closest to your users)
5. Click **Done**

## Step 3: Configure Firestore Security Rules

1. In Firestore Database, go to **Rules** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to read public data
    match /public/{document=**} {
      allow read: if request.auth != null;
    }
  }
}
```

3. Click **Publish**

## Step 4: Disable App Check (Temporary Fix)

Since you're getting App Check errors, let's disable it temporarily:

1. In the left sidebar, click on **App Check**
2. If you see your app listed, click on it
3. If App Check is enabled, disable it for now
4. This will resolve the "No AppCheckProvider installed" error

## Step 5: Verify Project Configuration

1. Go to **Project Settings** (gear icon)
2. In the **General** tab, verify:
   - Project ID: `fitnessapp-54afb`
   - App ID matches your `firebase_options.dart`
3. In the **Your apps** section, make sure your Android app is listed

## Step 6: Test the Setup

After completing these steps:
1. Clean and rebuild your Flutter app
2. Try registering a new user
3. Check Firestore Database for the new user document

## Common Issues:

- **reCAPTCHA errors**: Usually resolve after enabling Authentication properly
- **CONFIGURATION_NOT_FOUND**: Make sure all services are enabled
- **Database creation**: User documents won't appear until Firestore is created

Follow these steps in order, then test your app registration again.