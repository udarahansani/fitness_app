# Testing Instructions for Registration & Database Saving

## ✅ Configuration Updated Successfully

Your Firebase configuration has been updated to match your new Google Services file:

**New Firebase Project Details:**
- **Project ID**: `metawell-fitness`
- **App ID**: `1:878344363430:android:9e621dc629b8b2e6498367`
- **API Key**: `AIzaSyDBRJ_ErMtlG7JGIBZQieO02WL0qExvmVA`
- **Storage Bucket**: `metawell-fitness.firebasestorage.app`

## 🚀 Next Steps to Test Registration

### 1. Clean and Rebuild Your App
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Test Registration Flow
1. **Open your app** - You should see the Welcome screen
2. **Tap "Register"** - This will open the registration form
3. **Fill out ALL fields**:
   - Email: `test@example.com`
   - Password: `password123`
   - Confirm Password: `password123`
   - Name: `John Doe`
   - Age: `25`
   - Weight: `70`
   - Height: `175`
   - Gender: Select from dropdown
   - Fitness Goal: Select from dropdown
   - Activity Level: Select from dropdown
   - Diet Type: Select from dropdown
4. **Tap "Create Account"**
5. **Watch for success message** and navigation to home screen

### 3. Check Firebase Database
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project: `metawell-fitness`
3. Go to **Firestore Database**
4. Look for a new collection called `users`
5. You should see a document with the user's UID containing all the registration data

### 4. Test Login Flow
1. **Go back to Welcome screen**
2. **Tap "Login"**
3. **Enter the same credentials** you used for registration
4. **Tap "Sign in"**
5. **You should be navigated to the home screen**

## 🔍 What Data Should Be Saved

When you register a new user, the following data should appear in Firestore:

```json
{
  "email": "test@example.com",
  "displayName": "John Doe",
  "age": 25,
  "weight": 70.0,
  "height": 175.0,
  "gender": "Male",
  "fitnessGoal": "lose_fat",
  "activityLevel": "medium",
  "dietaryRestrictions": ["vegan"],
  "profileCompleted": true,
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 🐛 If You Encounter Issues

**Common Issues & Solutions:**

1. **"No user found" error**: Make sure Firebase Authentication is enabled
2. **"Permission denied" error**: Check Firestore security rules
3. **"Configuration not found" error**: Make sure the google-services.json file is in the correct location
4. **App crashes**: Check the Flutter console for detailed error messages

## 📱 Expected App Flow

1. **Welcome Screen** → Tap Register
2. **Registration Screen** → Fill all fields → Create Account
3. **Success Message** → Navigate to Home Screen
4. **Home Screen** → Shows dashboard with welcome message
5. **Go Back** → Test Login with same credentials
6. **Login Screen** → Enter credentials → Sign in
7. **Home Screen** → Successfully logged in

Let me know the results after testing!