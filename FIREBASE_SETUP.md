# إعداد Firebase للتطبيق

## الخطوات المطلوبة

### 1. إنشاء مشروع Firebase

1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. انقر على "Add project" أو "إضافة مشروع"
3. أدخل اسم المشروع: `wenh`
4. اتبع الخطوات لإنشاء المشروع

### 2. إضافة تطبيق Android

1. في صفحة المشروع، انقر على أيقونة Android
2. أدخل اسم الحزمة: `com.example.wenh` (أو اسم الحزمة الخاص بك)
3. قم بتنزيل ملف `google-services.json`
4. ضع الملف في: `android/app/google-services.json`

### 3. تحديث ملفات Android

#### في `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        // أضف هذا السطر
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### في `android/app/build.gradle`:
```gradle
// في نهاية الملف، أضف:
apply plugin: 'com.google.gms.google-services'
```

### 4. إضافة تطبيق iOS (اختياري)

1. في صفحة المشروع، انقر على أيقونة iOS
2. أدخل Bundle ID
3. قم بتنزيل ملف `GoogleService-Info.plist`
4. أضف الملف إلى مجلد `ios/Runner` في Xcode

### 5. تفعيل خدمات Firebase

#### Authentication (المصادقة):
1. في Firebase Console، اذهب إلى Authentication
2. انقر على "Get Started"
3. فعّل "Email/Password" في تبويب Sign-in method

#### Firestore Database (قاعدة البيانات):
1. في Firebase Console، اذهب إلى Firestore Database
2. انقر على "Create database"
3. اختر "Start in test mode" للتطوير
4. اختر المنطقة الأقرب لك

#### قواعد الأمان (Security Rules):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // السماح بالقراءة والكتابة للمستخدمين المصادقين فقط
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // قواعد خاصة بالمديرين
    match /admins/{adminId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'AdminRole.superAdmin';
    }
    
    // قواعد الطلبات
    match /requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if true; // السماح للجميع بإنشاء طلبات
      allow update, delete: if request.auth != null;
    }
  }
}
```

### 6. تشغيل الأوامر

```bash
# تثبيت الحزم
flutter pub get

# تشغيل التطبيق
flutter run
```

## إنشاء حساب مدير تجريبي

عند تشغيل التطبيق لأول مرة:

1. اختر "تسجيل دخول المدير" من شاشة اختيار الدور
2. فعّل خيار "حساب تجريبي"
3. البريد الإلكتروني: `demo@wenh.com`
4. كلمة المرور: `123456`
5. انقر على "تسجيل الدخول"

سيتم إنشاء حساب المدير تلقائياً في Firebase.

## ملاحظات مهمة

- **للإنتاج**: يجب تحديث قواعد الأمان لتكون أكثر صرامة
- **النسخ الاحتياطي**: احتفظ بنسخة من ملفات التكوين في مكان آمن
- **المفاتيح السرية**: لا تشارك ملفات `google-services.json` أو `GoogleService-Info.plist` علناً

## استكشاف الأخطاء

### خطأ: "No Firebase App"
- تأكد من تشغيل `Firebase.initializeApp()` في `main.dart`
- تحقق من وجود ملفات التكوين في المكان الصحيح

### خطأ في المصادقة
- تأكد من تفعيل Email/Password في Firebase Console
- تحقق من قواعد الأمان

### خطأ في Firestore
- تأكد من إنشاء قاعدة البيانات
- تحقق من قواعد الأمان
