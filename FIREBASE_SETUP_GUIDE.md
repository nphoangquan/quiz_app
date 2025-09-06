# Firebase Setup Guide - QuizApp

## 🔥 Lỗi hiện tại
```
Failed to load FirebaseOptions from resource. Check that you have defined values.xml correctly.
```

## ✅ Giải pháp tạm thời
- Đã comment `Firebase.initializeApp()` trong `main.dart`
- App có thể chạy để test UI/UX
- Firebase sẽ được setup sau

## 🚀 Cách setup Firebase đúng cách

### 1. Tạo Firebase Project
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới: "QuizApp"
3. Enable các services cần thiết:
   - Authentication
   - Cloud Firestore
   - Storage

### 2. Setup Android
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure Flutter project
flutter pub global activate flutterfire_cli
flutterfire configure
```

### 3. Chọn project và platforms
- Chọn QuizApp project
- Chọn Android, iOS, Web
- Sẽ tự động tạo `firebase_options.dart`

### 4. Update main.dart
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

### 5. Enable Authentication methods
- Email/Password
- Google Sign-In
- Anonymous (optional)

### 6. Setup Firestore rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public quizzes can be read by anyone
    match /quizzes/{quizId} {
      allow read: if resource.data.isPublic == true || request.auth.uid == resource.data.ownerId;
      allow write: if request.auth != null && request.auth.uid == resource.data.ownerId;
    }
    
    // Questions subcollection
    match /quizzes/{quizId}/questions/{questionId} {
      allow read: if get(/databases/$(database)/documents/quizzes/$(quizId)).data.isPublic == true || 
                     request.auth.uid == get(/databases/$(database)/documents/quizzes/$(quizId)).data.ownerId;
      allow write: if request.auth != null && 
                      request.auth.uid == get(/databases/$(database)/documents/quizzes/$(quizId)).data.ownerId;
    }
    
    // Results
    match /results/{resultId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

## 📱 Hiện tại
- ✅ UI/Theme system hoạt động tốt
- ✅ Splash screen với animations
- ✅ Provider state management
- ❌ Firebase chưa được cấu hình

## 🎯 Sau khi setup Firebase
1. Uncomment Firebase imports trong `main.dart`
2. Add `firebase_options.dart` file
3. Test authentication
4. Implement Giai đoạn 2: Authentication

---
*Lưu ý: App hiện tại chạy được để test UI, Firebase sẽ setup sau khi cần thiết*
