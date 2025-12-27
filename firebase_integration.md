# دليل ربط Firebase مع تطبيق "وينه؟"

## 📋 جدول المحتويات
1. [نظرة عامة](#1-نظرة-عامة)
2. [إعداد Firebase Project](#2-إعداد-firebase-project)
3. [Firebase Services المستخدمة](#3-firebase-services-المستخدمة)
4. [تصميم قاعدة البيانات](#4-تصميم-قاعدة-البيانات)
5. [ربط Authentication](#5-ربط-authentication)
6. [ربط Cubit مع Firebase](#6-ربط-cubit-مع-firebase)
7. [تدفق البيانات](#7-تدفق-البيانات)
8. [الصلاحيات والأمان](#8-الصلاحيات-والأمان)
9. [اقتراحات تحسينية](#9-اقتراحات-تحسينية)
10. [خطة الانتقال](#10-خطة-الانتقال)

---

## 1️⃣ نظرة عامة

### فكرة التطبيق
تطبيق "وينه؟" هو منصة تربط بين:
- **الزبائن**: يرسلون طلبات خدمات (سباكة، كهرباء، نجارة)
- **العمال**: يستلمون الطلبات (يحتاجون اشتراك نشط)
- **الأدمن**: يديرون المنصة والطلبات

### الوضع الحالي
- Frontend Only مع `SharedPreferences`
- يستخدم Cubit لإدارة الحالة
- بنية بسيطة بدون Clean Architecture

### ما سيتم تحويله
| الحالي | سيصبح |
|--------|-------|
| LocalStorageService | FirebaseService |
| SharedPreferences | Cloud Firestore |
| Mock Login | Firebase Auth |
| Stream محلي | Firestore Snapshots |

### لماذا Firestore؟
✅ Real-time Sync - العمال يرون الطلبات فورًا  
✅ Scalability - قابل للتوسع  
✅ Offline Support - يعمل بدون إنترنت  
✅ Security Rules - تحكم دقيق  

---

## 2️⃣ إعداد Firebase Project

### الخطوة 1: إنشاء المشروع
1. [Firebase Console](https://console.firebase.google.com/)
2. Add Project → اسم: `wenh-app`
3. فعّل Google Analytics (اختياري)

### الخطوة 2: إضافة Android
1. Package name: `com.wenh.app`
2. حمّل `google-services.json`
3. ضعه في `android/app/`

### الخطوة 3: إضافة iOS
1. Bundle ID: `com.wenh.app`
2. حمّل `GoogleService-Info.plist`
3. ضعه في `ios/Runner/`

### الخطوة 4: تعديل Android

**android/build.gradle**:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle**:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### الخطوة 5: تعديل iOS

**ios/Podfile**:
```ruby
platform :ios, '12.0'
```

### الخطوة 6: Dependencies

**pubspec.yaml**:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
```

### الخطوة 7: تهيئة Firebase

**lib/main.dart**:
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}
```

### الخطوة 8: تشغيل
```bash
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

## 3️⃣ Firebase Services المستخدمة

### 🔐 Firebase Authentication
**لماذا**: إدارة تسجيل دخول العمال والأدمن بشكل آمن

**الاستخدام**:
- Email/Password للعمال
- Email/Password للأدمن
- التحقق من الدور (role)

**ملاحظة**: الزبائن لا يحتاجون تسجيل دخول حاليًا

### 📊 Cloud Firestore
**لماذا**: قاعدة بيانات NoSQL سريعة

**الاستخدام**:
- تخزين الطلبات
- تخزين بيانات المستخدمين
- Real-time updates

### 🔒 Security Rules
**لماذا**: حماية البيانات

**الاستخدام**:
- منع الوصول غير المصرح
- التحكم بالصلاحيات

---

## 4️⃣ تصميم قاعدة البيانات

### البنية المقترحة

```
users/
  {userId}/
    - uid: string
    - email: string
    - name: string
    - role: "customer" | "worker" | "admin"
    - subscription: boolean
    - subscriptionEnd: timestamp
    - createdAt: timestamp
    - lastLogin: timestamp
    - permissions: map (للأدمن)

requests/
  {requestId}/
    - id: string
    - type: string
    - area: string
    - description: string
    - status: "new" | "taken" | "completed"
    - createdAt: timestamp
    - createdBy: string
    - takenBy: string
    - takenAt: timestamp
```

### شرح الحقول

#### users collection
- `uid`: معرف Firebase Auth
- `role`: للتفريق بين الأدوار
- `subscription`: حالة اشتراك العامل
- `subscriptionEnd`: تاريخ الانتهاء
- `permissions`: صلاحيات الأدمن

#### requests collection
- `type`: نوع الخدمة (للفلترة)
- `area`: المنطقة (للفلترة)
- `status`: حالة الطلب
- `createdAt`: للترتيب
- `takenBy`: معرف العامل

### لماذا هذه البنية؟
✅ بسيطة وواضحة  
✅ قابلة للتوسع  
✅ استعلامات سريعة  
✅ آمنة  

---

## 5️⃣ ربط Authentication

### إنشاء FirebaseAuthService

**lib/services/firebase_auth_service.dart**:
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<WorkerModel?> loginWorker(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) throw Exception('المستخدم غير موجود');

      final data = userDoc.data()!;
      
      if (data['role'] != 'worker') {
        await _auth.signOut();
        throw Exception('هذا الحساب ليس حساب عامل');
      }

      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return WorkerModel(
        name: data['name'],
        email: data['email'],
        subscription: data['subscription'] ?? false,
        subscriptionEnd: (data['subscriptionEnd'] as Timestamp).toDate(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<AdminModel?> loginAdmin(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) throw Exception('المستخدم غير موجود');

      final data = userDoc.data()!;
      
      if (data['role'] != 'admin') {
        await _auth.signOut();
        throw Exception('هذا الحساب ليس حساب مدير');
      }

      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return AdminModel.fromJson({
        'id': credential.user!.uid,
        'name': data['name'],
        'email': data['email'],
        'role': data['adminRole'] ?? 'AdminRole.admin',
        'isActive': data['isActive'] ?? true,
        'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
        'permissions': data['permissions'] ?? {},
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> registerWorker({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'name': name,
        'role': 'worker',
        'subscription': false,
        'subscriptionEnd': Timestamp.fromDate(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
```

### التحقق من الدور

**لماذا مهم؟**
- منع الزبون من الدخول لشاشات العامل
- منع العامل من الدخول لشاشات الأدمن

**كيف؟**
```dart
if (data['role'] != 'worker') {
  await _auth.signOut();
  throw Exception('هذا الحساب ليس حساب عامل');
}
```

---

## 6️⃣ ربط Cubit مع Firebase

### تحديث RequestCubit

**lib/cubits/request_cubit.dart**:
```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import 'request_state.dart';

class RequestCubit extends Cubit<RequestState> {
  RequestCubit() : super(const RequestInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _requestsSubscription;

  void getRequests() {
    emit(const RequestLoading());
    
    _requestsSubscription?.cancel();
    _requestsSubscription = _firestore
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final requests = snapshot.docs.map((doc) {
          final data = doc.data();
          return RequestModel(
            id: doc.id,
            type: data['type'],
            area: data['area'],
            description: data['description'],
            status: data['status'],
            takenBy: data['takenBy'],
          );
        }).toList();
        
        emit(RequestLoaded(requests));
      },
      onError: (error) {
        emit(RequestError('فشل تحميل الطلبات: ${error.toString()}'));
      },
    );
  }

  Future<void> addRequest({
    required String type,
    required String area,
    required String description,
  }) async {
    try {
      await _firestore.collection('requests').add({
        'type': type,
        'area': area,
        'description': description,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'anonymous',
        'takenBy': null,
      });
    } catch (e) {
      emit(RequestError('فشل إضافة الطلب: ${e.toString()}'));
    }
  }

  Future<void> takeRequest({
    required String id,
    required String workerName,
  }) async {
    try {
      await _firestore.collection('requests').doc(id).update({
        'status': 'taken',
        'takenBy': workerName,
        'takenAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(RequestError('فشل استلام الطلب: ${e.toString()}'));
    }
  }

  Future<void> updateStatus({
    required String id,
    required String status,
    String? takenBy,
  }) async {
    try {
      final updateData = {'status': status};
      if (takenBy != null) updateData['takenBy'] = takenBy;
      if (status == 'completed') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      }
      
      await _firestore.collection('requests').doc(id).update(updateData);
    } catch (e) {
      emit(RequestError('فشل تحديث حالة الطلب: ${e.toString()}'));
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      await _firestore.collection('requests').doc(id).delete();
    } catch (e) {
      emit(RequestError('فشل حذف الطلب: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    return super.close();
  }
}
```

### تحديث AuthCubit

**lib/cubits/auth_cubit.dart**:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/worker_model.dart';
import '../services/firebase_auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  final FirebaseAuthService _authService = FirebaseAuthService();
  WorkerModel? current;

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final worker = await _authService.loginWorker(email, password);
      if (worker != null) {
        current = worker;
        emit(Authenticated(worker));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(const AuthLoading());
    try {
      await _authService.registerWorker(
        email: email,
        password: password,
        name: name,
      );
      await login(email, password);
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthInitial());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    current = null;
    emit(const AuthInitial());
  }
}
```

### أين توضع العمليات؟

| العملية | المكان |
|---------|--------|
| addRequest | RequestCubit |
| getRequests | RequestCubit |
| takeRequest | RequestCubit |
| login | AuthCubit / AdminCubit |
| logout | AuthCubit / AdminCubit |

### التعامل مع loading / error / success

**في Cubit**:
```dart
emit(const RequestLoading());  // Loading
emit(RequestLoaded(requests)); // Success
emit(RequestError('خطأ'));     // Error
```

**في UI**:
```dart
BlocBuilder<RequestCubit, RequestState>(
  builder: (context, state) {
    if (state is RequestLoading) {
      return const CircularProgressIndicator();
    }
    if (state is RequestError) {
      return Text(state.message);
    }
    if (state is RequestLoaded) {
      return ListView.builder(...);
    }
    return const SizedBox();
  },
)
```

---

## 7️⃣ تدفق البيانات

### سيناريو كامل

#### 1. الزبون يرسل طلب
```dart
context.read<RequestCubit>().addRequest(
  type: selectedType,
  area: selectedArea,
  description: description,
);
```

#### 2. الطلب يُخزن في Firestore
```json
{
  "type": "⚡ كهربائي",
  "area": "بغداد",
  "description": "تمديدات كهربائية",
  "status": "new",
  "createdAt": "timestamp",
  "createdBy": "anonymous"
}
```

#### 3. العامل يراه فورًا
- Firestore snapshots ترسل تحديث فوري
- RequestCubit يصدر RequestLoaded
- الواجهة تُعاد بناؤها

#### 4. العامل يستلمه
```dart
context.read<RequestCubit>().takeRequest(
  id: request.id,
  workerName: worker.name,
);
```

#### 5. حالة الطلب تتغير
```json
{
  "status": "taken",
  "takenBy": "عامل تجريبي",
  "takenAt": "timestamp"
}
```

### مخطط التدفق
```
الزبون → RequestCubit → Firestore
                           ↓
                    (Real-time)
                           ↓
العامل ← RequestCubit ← snapshots
```

---

## 8️⃣ الصلاحيات والأمان

### Security Rules

**Firebase Console → Firestore → Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    match /users/{userId} {
      allow read: if request.auth != null && 
                     (request.auth.uid == userId || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      
      allow update: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /requests/{requestId} {
      allow read: if true;
      allow create: if true;
      allow update: if request.auth != null && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'worker' &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.subscription == true;
      allow delete: if request.auth != null && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### شرح القواعد

**من يمكنه إنشاء طلب؟**
```javascript
allow create: if true;
```
الزبائن لا يحتاجون تسجيل دخول

**من يمكنه رؤية الطلبات؟**
```javascript
allow read: if true;
```
جميع العمال يحتاجون رؤية الطلبات

**من يمكنه تعديل حالة الطلب؟**
```javascript
allow update: if request.auth != null && 
                 role == 'worker' &&
                 subscription == true;
```
فقط العمال المسجلين بـ اشتراك نشط

---

## 9️⃣ اقتراحات تحسينية

### 1. فصل Collections
**الاقتراح**: collections منفصلة لـ customers/workers/admins

**المميزات**: استعلامات أسرع، Security Rules أبسط

**التوصية**: اتركه للمرحلة التالية

### 2. Offline Persistence
**الاقتراح**: تفعيل Cache
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
);
```

**التوصية**: **فعّله الآن**

### 3. Pagination
**الاقتراح**: تحميل 20 طلب في كل مرة
```dart
.limit(20)
.startAfterDocument(lastDoc)
```

**التوصية**: أضفه عند زيادة عدد الطلبات

### 4. Push Notifications
**الاقتراح**: إشعارات للعمال عند طلب جديد

**التوصية**: المرحلة التالية

### 5. Analytics
**الاقتراح**: تتبع سلوك المستخدمين

**التوصية**: ليس أولوية الآن

---

## 🔟 خطة الانتقال

### ما يُحذف

#### ❌ LocalStorageService
```dart
// احذف lib/services/firebase_service.dart
// احذف من app.dart:
LocalStorageService.initializeSampleData();
```

#### ❌ SharedPreferences للطلبات
يبقى فقط للإعدادات المحلية

### ما يُعدّل

#### 🔄 RequestModel
```dart
// أضف:
final DateTime createdAt;
final String createdBy;
final DateTime? takenAt;

factory RequestModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return RequestModel(
    id: doc.id,
    type: data['type'],
    area: data['area'],
    description: data['description'],
    status: data['status'],
    takenBy: data['takenBy'],
    createdAt: (data['createdAt'] as Timestamp).toDate(),
    createdBy: data['createdBy'] ?? 'anonymous',
    takenAt: data['takenAt'] != null 
        ? (data['takenAt'] as Timestamp).toDate() 
        : null,
  );
}
```

#### 🔄 WorkerModel
```dart
// أضف:
final String uid;

factory WorkerModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return WorkerModel(
    uid: doc.id,
    name: data['name'],
    email: data['email'],
    subscription: data['subscription'],
    subscriptionEnd: (data['subscriptionEnd'] as Timestamp).toDate(),
  );
}
```

### ما يبقى

✅ البنية العامة (cubits, models, screens)  
✅ استخدام Cubit  
✅ معظم الواجهات  
✅ Services المحلية (drafts, favorites, filters)  

### خطة التنفيذ

#### المرحلة 1: الإعداد (يوم)
- [ ] إنشاء Firebase Project
- [ ] إضافة Apps
- [ ] تنزيل ملفات الإعداد
- [ ] إضافة Dependencies
- [ ] تهيئة Firebase

#### المرحلة 2: Authentication (يومان)
- [ ] إنشاء FirebaseAuthService
- [ ] تحديث AuthCubit
- [ ] تحديث AdminCubit
- [ ] اختبار Login/Logout

#### المرحلة 3: Firestore (يومان)
- [ ] تصميم البنية
- [ ] تحديث RequestCubit
- [ ] تحديث Models
- [ ] اختبار CRUD

#### المرحلة 4: Security (يوم)
- [ ] كتابة Rules
- [ ] اختبار الصلاحيات

#### المرحلة 5: التنظيف (يوم)
- [ ] حذف LocalStorageService
- [ ] اختبار شامل

### نصائح

💡 **ابدأ بالتدريج**: اجعل LocalStorage و Firestore يعملان معًا أولاً

💡 **استخدم Emulator**: للتطوير بدون التأثير على البيانات الحقيقية
```bash
firebase emulators:start
```

💡 **أضف بيانات تجريبية**: في Firebase Console يدويًا

💡 **راقب Usage**: Firebase لديه حد مجاني 50k قراءة/يوم

---

## ✅ Checklist النهائي

- [ ] جميع Cubits تستخدم Firestore
- [ ] Security Rules مطبقة
- [ ] لا بيانات تجريبية في Production
- [ ] Error Handling محسّن
- [ ] Offline Persistence مفعّل
- [ ] اختبار شامل على Android/iOS

---

## 📚 مصادر

- [FlutterFire Docs](https://firebase.flutter.dev/)
- [Firestore Get Started](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Auth Flutter](https://firebase.google.com/docs/auth/flutter/start)

---

**تم إنشاء هذا الدليل بناءً على فهم كامل لمشروع "وينه؟"**  
**جاهز للتنفيذ خطوة بخطوة** 🚀
