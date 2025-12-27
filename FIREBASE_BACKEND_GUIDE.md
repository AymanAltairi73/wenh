# Firebase Backend Implementation Guide

## Overview
This guide provides a comprehensive, production-ready approach to implementing Firebase backend for your Flutter application. The app supports workers and admins with role-based access control.

---

## 1. Cloud Firestore Database Structure

### 1.1 Collections Design

#### **users** (Main user collection)
```
users/
  {userId}/
    - uid: string
    - email: string
    - name: string
    - role: string ('worker' | 'admin')
    - createdAt: timestamp
    - lastLogin: timestamp
    
    // Worker-specific fields
    - subscription: boolean
    - subscriptionEnd: timestamp
    - phoneNumber: string (optional)
    - profileImage: string (optional)
    - rating: number (optional)
    - completedJobs: number (default: 0)
    
    // Admin-specific fields
    - adminRole: string ('super_admin' | 'admin' | 'moderator')
    - isActive: boolean
    - permissions: map {
        canManageUsers: boolean
        canManageRequests: boolean
        canManageAdmins: boolean
        canViewAnalytics: boolean
      }
```

#### **requests** (Service requests/orders)
```
requests/
  {requestId}/
    - id: string
    - type: string (category)
    - subType: string (optional)
    - area: string
    - description: string
    - status: string ('new' | 'taken' | 'in_progress' | 'completed' | 'cancelled')
    - priority: string ('low' | 'medium' | 'high' | 'urgent')
    - budget: number (optional)
    - preferredTime: string (optional)
    - createdAt: timestamp
    - updatedAt: timestamp
    - createdBy: string (userId or 'anonymous')
    - takenBy: string (workerId, nullable)
    - takenAt: timestamp (nullable)
    - completedAt: timestamp (nullable)
    - cancelledAt: timestamp (nullable)
    - cancelReason: string (nullable)
    - images: array<string> (optional)
    - location: geopoint (optional)
```

#### **favorites** (Worker's favorite requests)
```
favorites/
  {favoriteId}/
    - id: string
    - userId: string (workerId)
    - requestId: string
    - createdAt: timestamp
```

#### **drafts** (Incomplete request drafts)
```
drafts/
  {draftId}/
    - id: string
    - userId: string (optional, for logged-in users)
    - category: string (nullable)
    - subType: string (nullable)
    - area: string (nullable)
    - description: string (nullable)
    - priority: string (nullable)
    - budget: number (nullable)
    - preferredTime: string (nullable)
    - createdAt: timestamp
    - updatedAt: timestamp
    - expiresAt: timestamp (auto-delete after 30 days)
```

#### **notifications** (User notifications)
```
notifications/
  {notificationId}/
    - id: string
    - userId: string
    - title: string
    - message: string
    - type: string ('request_taken' | 'request_completed' | 'subscription_expiring' | 'system')
    - isRead: boolean
    - createdAt: timestamp
    - relatedRequestId: string (nullable)
    - actionUrl: string (nullable)
```

#### **subscriptions** (Subscription history)
```
subscriptions/
  {subscriptionId}/
    - id: string
    - userId: string (workerId)
    - startDate: timestamp
    - endDate: timestamp
    - amount: number
    - paymentMethod: string
    - status: string ('active' | 'expired' | 'cancelled')
    - createdAt: timestamp
```

#### **analytics** (App analytics - admin only)
```
analytics/
  daily_stats/
    {date}/
      - date: timestamp
      - totalRequests: number
      - completedRequests: number
      - activeWorkers: number
      - newUsers: number
      - revenue: number
```

#### **settings** (App-wide settings)
```
settings/
  app_config/
    - maintenanceMode: boolean
    - minAppVersion: string
    - featuredCategories: array<string>
    - subscriptionPrice: number
    - subscriptionDurationDays: number
```

### 1.2 Indexing Strategy

Create composite indexes for common queries:

```
Collection: requests
- status (Ascending) + createdAt (Descending)
- status (Ascending) + area (Ascending) + createdAt (Descending)
- takenBy (Ascending) + status (Ascending)
- createdBy (Ascending) + createdAt (Descending)

Collection: favorites
- userId (Ascending) + createdAt (Descending)

Collection: notifications
- userId (Ascending) + isRead (Ascending) + createdAt (Descending)

Collection: subscriptions
- userId (Ascending) + status (Ascending) + endDate (Descending)
```

**How to create indexes:**
1. Go to Firebase Console → Firestore Database → Indexes
2. Click "Create Index"
3. Add the fields and sort orders as specified above
4. Alternatively, Firebase will suggest indexes when you run queries that need them

---

## 2. Firestore Security Rules

### 2.1 Complete Security Rules

Create these rules in Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    
    function isAdmin() {
      return isAuthenticated() && getUserData().role == 'admin';
    }
    
    function isWorker() {
      return isAuthenticated() && getUserData().role == 'worker';
    }
    
    function hasActiveSubscription() {
      let userData = getUserData();
      return userData.subscription == true && 
             userData.subscriptionEnd > request.time;
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone can create a user (for registration)
      allow create: if isAuthenticated() && request.auth.uid == userId;
      
      // Users can read their own data, admins can read all
      allow read: if isOwner(userId) || isAdmin();
      
      // Users can update their own data (except role and admin fields)
      allow update: if isOwner(userId) && 
                      !request.resource.data.diff(resource.data).affectedKeys()
                        .hasAny(['role', 'adminRole', 'permissions']);
      
      // Admins can update any user
      allow update: if isAdmin();
      
      // Only super admins can delete users
      allow delete: if isAdmin() && getUserData().adminRole == 'super_admin';
    }
    
    // Requests collection
    match /requests/{requestId} {
      // Anyone can read requests (for browsing)
      allow read: if true;
      
      // Authenticated users can create requests
      allow create: if isAuthenticated() || 
                      (request.resource.data.createdBy == 'anonymous');
      
      // Only the creator or admins can update
      allow update: if isAdmin() || 
                      (isAuthenticated() && resource.data.createdBy == request.auth.uid);
      
      // Workers can update to take a request
      allow update: if isWorker() && 
                      hasActiveSubscription() &&
                      resource.data.status == 'new' &&
                      request.resource.data.status == 'taken' &&
                      request.resource.data.takenBy == request.auth.uid;
      
      // Workers can update their own taken requests
      allow update: if isWorker() && 
                      resource.data.takenBy == request.auth.uid;
      
      // Only admins can delete
      allow delete: if isAdmin();
    }
    
    // Favorites collection
    match /favorites/{favoriteId} {
      // Users can only read their own favorites
      allow read: if isAuthenticated() && 
                    resource.data.userId == request.auth.uid;
      
      // Users can create their own favorites
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      
      // Users can delete their own favorites
      allow delete: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
    }
    
    // Drafts collection
    match /drafts/{draftId} {
      // Users can read their own drafts
      allow read: if isAuthenticated() && 
                    resource.data.userId == request.auth.uid;
      
      // Users can create their own drafts
      allow create: if isAuthenticated() && 
                      request.resource.data.userId == request.auth.uid;
      
      // Users can update and delete their own drafts
      allow update, delete: if isAuthenticated() && 
                              resource.data.userId == request.auth.uid;
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      // Users can only read their own notifications
      allow read: if isAuthenticated() && 
                    resource.data.userId == request.auth.uid;
      
      // Only admins and system can create notifications
      allow create: if isAdmin();
      
      // Users can update their own notifications (mark as read)
      allow update: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid &&
                      request.resource.data.diff(resource.data).affectedKeys()
                        .hasOnly(['isRead']);
      
      // Users can delete their own notifications
      allow delete: if isAuthenticated() && 
                      resource.data.userId == request.auth.uid;
    }
    
    // Subscriptions collection
    match /subscriptions/{subscriptionId} {
      // Users can read their own subscriptions
      allow read: if isAuthenticated() && 
                    resource.data.userId == request.auth.uid;
      
      // Admins can read all subscriptions
      allow read: if isAdmin();
      
      // Only admins can create/update subscriptions
      allow create, update: if isAdmin();
    }
    
    // Analytics collection (admin only)
    match /analytics/{document=**} {
      allow read: if isAdmin();
      allow write: if isAdmin();
    }
    
    // Settings collection (read by all, write by admins)
    match /settings/{document=**} {
      allow read: if true;
      allow write: if isAdmin();
    }
  }
}
```

### 2.2 Testing Security Rules

Before deploying, test your rules:

1. Go to Firebase Console → Firestore Database → Rules → Rules Playground
2. Test scenarios:
   - Authenticated worker reading their own data ✓
   - Authenticated worker reading another user's data ✗
   - Unauthenticated user creating a request ✓
   - Worker taking a request without subscription ✗
   - Admin deleting a user ✓

---

## 3. CRUD Operations Implementation

### 3.1 Create a Firestore Service

Create `lib/services/firestore_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/request_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? get currentUserId => _auth.currentUser?.uid;
  
  // ==================== REQUESTS ====================
  
  // CREATE: Add a new request
  Future<String> createRequest(RequestModel request) async {
    try {
      final docRef = await _firestore.collection('requests').add(
        request.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // READ: Get all requests (with optional filters)
  Stream<List<RequestModel>> getRequests({
    String? status,
    String? area,
    int limit = 50,
  }) {
    try {
      Query query = _firestore.collection('requests');
      
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      
      if (area != null) {
        query = query.where('area', isEqualTo: area);
      }
      
      query = query.orderBy('createdAt', descending: true).limit(limit);
      
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => RequestModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // READ: Get single request by ID
  Future<RequestModel?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore.collection('requests').doc(requestId).get();
      
      if (!doc.exists) return null;
      
      return RequestModel.fromFirestore(doc);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // READ: Get requests taken by current worker
  Stream<List<RequestModel>> getMyTakenRequests() {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      return _firestore
          .collection('requests')
          .where('takenBy', isEqualTo: currentUserId)
          .orderBy('takenAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => RequestModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // UPDATE: Take a request
  Future<void> takeRequest(String requestId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'taken',
        'takenBy': currentUserId,
        'takenAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // UPDATE: Update request status
  Future<void> updateRequestStatus(
    String requestId,
    String newStatus, {
    String? cancelReason,
  }) async {
    try {
      final updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (newStatus == 'completed') {
        updateData['completedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == 'cancelled') {
        updateData['cancelledAt'] = FieldValue.serverTimestamp();
        if (cancelReason != null) {
          updateData['cancelReason'] = cancelReason;
        }
      }
      
      await _firestore.collection('requests').doc(requestId).update(updateData);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // DELETE: Delete a request
  Future<void> deleteRequest(String requestId) async {
    try {
      await _firestore.collection('requests').doc(requestId).delete();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // ==================== FAVORITES ====================
  
  // CREATE: Add to favorites
  Future<void> addToFavorites(String requestId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      await _firestore.collection('favorites').add({
        'userId': currentUserId,
        'requestId': requestId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // READ: Get user's favorites
  Stream<List<String>> getFavoriteRequestIds() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    try {
      return _firestore
          .collection('favorites')
          .where('userId', isEqualTo: currentUserId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => doc.data()['requestId'] as String)
            .toList();
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // DELETE: Remove from favorites
  Future<void> removeFromFavorites(String requestId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final querySnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: currentUserId)
          .where('requestId', isEqualTo: requestId)
          .get();
      
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // ==================== DRAFTS ====================
  
  // CREATE/UPDATE: Save draft
  Future<void> saveDraft(String draftId, Map<String, dynamic> draftData) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      await _firestore.collection('drafts').doc(draftId).set({
        ...draftData,
        'userId': currentUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // READ: Get user's draft
  Future<Map<String, dynamic>?> getDraft(String draftId) async {
    if (currentUserId == null) {
      return null;
    }
    
    try {
      final doc = await _firestore.collection('drafts').doc(draftId).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data();
      if (data?['userId'] != currentUserId) return null;
      
      return data;
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // DELETE: Delete draft
  Future<void> deleteDraft(String draftId) async {
    try {
      await _firestore.collection('drafts').doc(draftId).delete();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // ==================== NOTIFICATIONS ====================
  
  // CREATE: Send notification (admin only)
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedRequestId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'relatedRequestId': relatedRequestId,
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // READ: Get user notifications
  Stream<List<Map<String, dynamic>>> getNotifications() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    try {
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data()};
        }).toList();
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // UPDATE: Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // ==================== USER MANAGEMENT ====================
  
  // READ: Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // UPDATE: Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      await _firestore.collection('users').doc(currentUserId).update(updates);
    } catch (e) {
      throw _handleFirestoreError(e);
    }
  }
  
  // ==================== ERROR HANDLING ====================
  
  String _handleFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'ليس لديك صلاحية للوصول إلى هذه البيانات';
        case 'not-found':
          return 'البيانات المطلوبة غير موجودة';
        case 'already-exists':
          return 'البيانات موجودة بالفعل';
        case 'resource-exhausted':
          return 'تم تجاوز الحد المسموح من الطلبات';
        case 'failed-precondition':
          return 'الفهرس المطلوب غير موجود';
        case 'aborted':
          return 'تم إلغاء العملية';
        case 'out-of-range':
          return 'القيمة خارج النطاق المسموح';
        case 'unimplemented':
          return 'العملية غير مدعومة';
        case 'internal':
          return 'خطأ داخلي في الخادم';
        case 'unavailable':
          return 'الخدمة غير متاحة حالياً';
        case 'data-loss':
          return 'فقدان البيانات';
        case 'unauthenticated':
          return 'يجب تسجيل الدخول أولاً';
        default:
          return 'حدث خطأ: ${error.message}';
      }
    }
    return 'حدث خطأ غير متوقع';
  }
}
```

### 3.2 Best Practices for CRUD Operations

#### **Use Streams for Real-time Data**
```dart
// Good: Real-time updates
Stream<List<RequestModel>> watchRequests() {
  return _firestore
      .collection('requests')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => 
          RequestModel.fromFirestore(doc)).toList());
}
```

#### **Use Futures for One-time Reads**
```dart
// Good: One-time fetch
Future<RequestModel?> getRequest(String id) async {
  final doc = await _firestore.collection('requests').doc(id).get();
  return doc.exists ? RequestModel.fromFirestore(doc) : null;
}
```

#### **Handle Loading and Error States**
```dart
StreamBuilder<List<RequestModel>>(
  stream: firestoreService.getRequests(),
  builder: (context, snapshot) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Error state
    if (snapshot.hasError) {
      return Center(
        child: Text('خطأ: ${snapshot.error}'),
      );
    }
    
    // Empty state
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(
        child: Text('لا توجد طلبات'),
      );
    }
    
    // Success state
    final requests = snapshot.data!;
    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return RequestCard(request: requests[index]);
      },
    );
  },
)
```

#### **Use Batch Writes for Multiple Operations**
```dart
Future<void> completeRequestAndNotify(String requestId, String workerId) async {
  final batch = _firestore.batch();
  
  // Update request
  batch.update(
    _firestore.collection('requests').doc(requestId),
    {'status': 'completed', 'completedAt': FieldValue.serverTimestamp()},
  );
  
  // Update worker stats
  batch.update(
    _firestore.collection('users').doc(workerId),
    {'completedJobs': FieldValue.increment(1)},
  );
  
  // Create notification
  batch.set(
    _firestore.collection('notifications').doc(),
    {
      'userId': workerId,
      'title': 'تم إكمال الطلب',
      'message': 'تم إكمال الطلب بنجاح',
      'type': 'request_completed',
      'createdAt': FieldValue.serverTimestamp(),
    },
  );
  
  await batch.commit();
}
```

#### **Implement Pagination for Large Lists**
```dart
DocumentSnapshot? _lastDocument;
bool _hasMore = true;

Future<List<RequestModel>> loadMoreRequests() async {
  if (!_hasMore) return [];
  
  Query query = _firestore
      .collection('requests')
      .orderBy('createdAt', descending: true)
      .limit(20);
  
  if (_lastDocument != null) {
    query = query.startAfterDocument(_lastDocument!);
  }
  
  final snapshot = await query.get();
  
  if (snapshot.docs.isEmpty) {
    _hasMore = false;
    return [];
  }
  
  _lastDocument = snapshot.docs.last;
  
  return snapshot.docs
      .map((doc) => RequestModel.fromFirestore(doc))
      .toList();
}
```

---

## 4. Authentication State Management

### 4.1 Create Auth State Wrapper

Update `lib/services/firebase_auth_service.dart`:

```dart
// Add this method to your existing FirebaseAuthService class

Stream<User?> get authStateChanges => _auth.authStateChanges();

Future<bool> isUserLoggedIn() async {
  return _auth.currentUser != null;
}

Future<Map<String, dynamic>?> getCurrentUserData() async {
  final user = _auth.currentUser;
  if (user == null) return null;
  
  final doc = await _firestore.collection('users').doc(user.uid).get();
  return doc.data();
}

Future<String?> getUserRole() async {
  final userData = await getCurrentUserData();
  return userData?['role'];
}
```

### 4.2 Implement Auth Wrapper Widget

Create `lib/widgets/auth_wrapper.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../screens/worker_login_screen.dart';
import '../screens/worker_home_screen.dart';
import '../screens/admin_login_screen.dart';
import '../screens/admin_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  final bool isAdminMode;
  
  const AuthWrapper({
    super.key,
    this.isAdminMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Not logged in
        if (!snapshot.hasData) {
          return isAdminMode 
              ? const AdminLoginScreen()
              : const WorkerLoginScreen();
        }
        
        // Logged in - verify role
        return FutureBuilder<String?>(
          future: authService.getUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final role = roleSnapshot.data;
            
            // Role mismatch - logout and show login
            if (isAdminMode && role != 'admin') {
              authService.logout();
              return const AdminLoginScreen();
            }
            
            if (!isAdminMode && role != 'worker') {
              authService.logout();
              return const WorkerLoginScreen();
            }
            
            // Correct role - show home screen
            return isAdminMode 
                ? const AdminDashboard()
                : const WorkerHomeScreen();
          },
        );
      },
    );
  }
}
```

### 4.3 Session Persistence

Firebase Auth automatically persists sessions. Configure persistence level in `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  // Session persistence is enabled by default
  // For web, you can configure it:
  // await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  
  runApp(const MyApp());
}
```

### 4.4 Auto-logout on Token Expiration

```dart
class AuthService {
  void setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User logged out - navigate to login
        navigatorKey.currentState?.pushReplacementNamed('/login');
      }
    });
    
    // Listen for token refresh failures
    FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      if (user != null) {
        try {
          await user.getIdToken(true); // Force refresh
        } catch (e) {
          // Token refresh failed - logout
          await FirebaseAuth.instance.signOut();
        }
      }
    });
  }
}
```

---

## 5. Error Handling

### 5.1 Centralized Error Handler

Create `lib/utils/error_handler.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirestoreError(error);
    } else if (error is NetworkException) {
      return 'تحقق من اتصال الإنترنت';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }
  
  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات، حاول لاحقاً';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموحة';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة';
      default:
        return 'خطأ في المصادقة: ${e.message}';
    }
  }
  
  static String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية للوصول إلى هذه البيانات';
      case 'not-found':
        return 'البيانات المطلوبة غير موجودة';
      case 'already-exists':
        return 'البيانات موجودة بالفعل';
      case 'resource-exhausted':
        return 'تم تجاوز الحد المسموح من الطلبات';
      case 'failed-precondition':
        return 'الشرط المسبق للعملية غير متحقق';
      case 'aborted':
        return 'تم إلغاء العملية بسبب تعارض';
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً، حاول لاحقاً';
      case 'unauthenticated':
        return 'يجب تسجيل الدخول أولاً';
      case 'deadline-exceeded':
        return 'انتهت مهلة العملية';
      default:
        return 'خطأ في قاعدة البيانات: ${e.message}';
    }
  }
  
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
```

### 5.2 Retry Logic for Network Failures

```dart
class RetryHelper {
  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxAttempts) {
          rethrow;
        }
        
        // Check if error is retryable
        if (e is FirebaseException && 
            (e.code == 'unavailable' || e.code == 'deadline-exceeded')) {
          await Future.delayed(delay * attempts);
        } else {
          rethrow;
        }
      }
    }
    
    throw Exception('Max retry attempts reached');
  }
}

// Usage:
final result = await RetryHelper.retryOperation(
  operation: () => firestoreService.getRequests(),
  maxAttempts: 3,
);
```

### 5.3 Offline Support

```dart
// Enable offline persistence in main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const MyApp());
}

// Check network connectivity
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  static Stream<bool> get connectivityStream {
    return Connectivity().onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
```

---

## 6. Production Readiness Steps

### 6.1 Data Validation

Create `lib/utils/validators.dart`:

```dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }
  
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    
    if (value.length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'رقم الهاتف غير صالح';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }
}
```

### 6.2 Performance Optimization

```dart
// 1. Use const constructors
const Text('Hello'); // Instead of Text('Hello')

// 2. Implement proper list builders
ListView.builder( // Instead of ListView(children: [...])
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// 3. Limit query results
query.limit(50); // Don't fetch all documents

// 4. Use indexes for complex queries
// Create indexes in Firebase Console

// 5. Cache network images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// 6. Dispose streams and controllers
@override
void dispose() {
  _streamSubscription?.cancel();
  _controller.dispose();
  super.dispose();
}
```

### 6.3 Security Checklist

- [ ] Firestore Security Rules implemented and tested
- [ ] API keys restricted in Firebase Console (Android/iOS package names)
- [ ] Authentication required for sensitive operations
- [ ] User input validated on client and server
- [ ] Rate limiting configured in Firebase Console
- [ ] Sensitive data encrypted (if applicable)
- [ ] No hardcoded secrets in code
- [ ] HTTPS enforced for all connections
- [ ] User roles and permissions properly enforced

### 6.4 Monitoring and Logging

```dart
// Add Firebase Crashlytics
// pubspec.yaml:
// firebase_crashlytics: ^3.4.0

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(const MyApp());
}

// Log custom events
void logCustomEvent(String eventName, Map<String, dynamic> parameters) {
  FirebaseCrashlytics.instance.log('Event: $eventName');
  // Use Firebase Analytics for detailed analytics
}

// Log errors
void logError(dynamic error, StackTrace? stackTrace) {
  FirebaseCrashlytics.instance.recordError(error, stackTrace);
}
```

### 6.5 Testing Strategy

Create `test/firestore_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('FirestoreService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    
    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
    });
    
    test('Create request should add document to Firestore', () async {
      // Arrange
      final requestData = {
        'type': 'plumbing',
        'area': 'Riyadh',
        'description': 'Fix leak',
        'status': 'new',
      };
      
      // Act
      final docRef = await fakeFirestore.collection('requests').add(requestData);
      
      // Assert
      final doc = await docRef.get();
      expect(doc.exists, true);
      expect(doc.data()?['type'], 'plumbing');
    });
    
    test('Security rules should prevent unauthorized access', () async {
      // Test your security rules logic
      // This requires Firebase Emulator Suite
    });
  });
}
```

### 6.6 Environment Configuration

Create `lib/config/firebase_config.dart`:

```dart
class FirebaseConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  
  static const String firestoreEmulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;
  
  static void configureEmulators() {
    if (!isProduction) {
      FirebaseFirestore.instance.useFirestoreEmulator(
        firestoreEmulatorHost,
        firestoreEmulatorPort,
      );
      
      FirebaseAuth.instance.useAuthEmulator(
        'localhost',
        9099,
      );
    }
  }
}

// In main.dart:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FirebaseConfig.configureEmulators();
  
  runApp(const MyApp());
}
```

### 6.7 Pre-Production Checklist

#### **Firebase Console Configuration**
- [ ] Enable App Check for abuse prevention
- [ ] Configure budget alerts
- [ ] Set up Firebase Performance Monitoring
- [ ] Enable Firebase Analytics
- [ ] Configure Cloud Functions (if needed)
- [ ] Set up backup schedule for Firestore

#### **Code Quality**
- [ ] All features tested (unit, widget, integration)
- [ ] Error handling implemented everywhere
- [ ] Loading states for all async operations
- [ ] Offline support enabled
- [ ] Code reviewed and refactored
- [ ] No console.log or print statements in production

#### **Performance**
- [ ] Images optimized and cached
- [ ] Pagination implemented for large lists
- [ ] Lazy loading for heavy widgets
- [ ] Firestore indexes created
- [ ] Query limits applied

#### **Security**
- [ ] Security rules tested
- [ ] API keys restricted
- [ ] User input sanitized
- [ ] Authentication enforced
- [ ] HTTPS only

---

## 7. Next Steps

### Immediate Actions:

1. **Set up Firestore Database**
   - Go to Firebase Console → Firestore Database
   - Click "Create database"
   - Choose production mode
   - Select a location close to your users

2. **Deploy Security Rules**
   - Copy the security rules from Section 2.1
   - Go to Firestore Database → Rules
   - Paste and publish

3. **Create Initial Data Structure**
   - Manually create the collections or use the app to create them
   - Add test data for development

4. **Implement Firestore Service**
   - Create `firestore_service.dart` from Section 3.1
   - Integrate with your existing cubits/blocs

5. **Test Authentication Flow**
   - Test login/logout
   - Test session persistence
   - Test role-based access

6. **Enable Monitoring**
   - Set up Crashlytics
   - Configure Analytics
   - Set up Performance Monitoring

### Long-term Improvements:

- Implement Cloud Functions for complex backend logic
- Add Firebase Cloud Messaging for push notifications
- Set up Firebase Storage for file uploads
- Implement advanced analytics and A/B testing
- Add Firebase Remote Config for feature flags
- Set up CI/CD pipeline for automated testing and deployment

---

## 8. Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/data-model)
- [Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

**This guide provides a complete, production-ready Firebase backend implementation. Follow each section carefully and adapt to your specific requirements.**
