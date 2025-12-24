# دليل التخزين المحلي - بدون Backend

## نظرة عامة

تم تحويل التطبيق للعمل بدون Firebase أو أي backend خارجي. جميع البيانات تُخزن محلياً على الجهاز باستخدام `SharedPreferences`.

## الميزات

### ✅ ما يعمل الآن

1. **تسجيل دخول المديرين**
   - إنشاء حسابات تجريبية محلياً
   - تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
   - حفظ معلومات المدير محلياً

2. **إدارة الطلبات**
   - إضافة طلبات جديدة
   - تحديث حالة الطلبات
   - حذف الطلبات
   - عرض الطلبات في الوقت الفعلي

3. **إدارة المديرين**
   - إضافة مديرين جدد
   - تعديل صلاحيات المديرين
   - تفعيل/تعطيل الحسابات
   - حذف المديرين

4. **التزامن التلقائي**
   - تحديث البيانات تلقائياً عبر الشاشات
   - استخدام Streams للتحديثات الفورية

## كيفية الاستخدام

### 1. تسجيل دخول تجريبي

```
البريد الإلكتروني: demo@wenh.com
كلمة المرور: 123456
```

عند تفعيل "حساب تجريبي" وتسجيل الدخول، سيتم:
- إنشاء حساب مدير جديد محلياً
- حفظه في SharedPreferences
- تسجيل الدخول تلقائياً

### 2. البيانات الأولية

عند تشغيل التطبيق لأول مرة، يتم إنشاء:
- 3 طلبات نموذجية
- يمكنك إضافة المزيد من الطلبات

### 3. التخزين المحلي

جميع البيانات تُحفظ في:
- **المديرين**: `SharedPreferences` -> مفتاح `'admins'`
- **الطلبات**: `SharedPreferences` -> مفتاح `'requests'`

## البنية التقنية

### LocalStorageService

الخدمة الرئيسية للتخزين المحلي:

```dart
class LocalStorageService {
  // تحميل البيانات من SharedPreferences
  static Future<void> _loadData()
  
  // حفظ المديرين
  static Future<void> _saveAdmins()
  
  // حفظ الطلبات
  static Future<void> _saveRequests()
  
  // تسجيل دخول المدير
  static Future<AdminModel?> loginAdmin(String email, String password)
  
  // إنشاء حساب تجريبي
  static Future<void> createDemoAdmin(String email, String password)
  
  // الحصول على stream للمديرين
  static Stream<List<AdminModel>> getAdminsStream()
  
  // الحصول على stream للطلبات
  static Stream<List<RequestModel>> getRequestsStream()
  
  // إضافة طلب
  static Future<void> addRequest(RequestModel request)
  
  // تحديث حالة الطلب
  static Future<void> updateRequestStatus({...})
  
  // حذف طلب
  static Future<void> deleteRequest(String id)
  
  // إدارة المديرين
  static Future<void> createAdmin({...})
  static Future<void> updateAdmin(AdminModel admin)
  static Future<void> deleteAdmin(String id)
}
```

### Streams للتحديثات الفورية

```dart
// StreamControllers للبث
static final _adminsController = StreamController<List<AdminModel>>.broadcast();
static final _requestsController = StreamController<List<RequestModel>>.broadcast();

// عند حفظ البيانات، يتم بث التحديث
_adminsController.add(List.from(_admins));
_requestsController.add(List.from(_requests));
```

## الفروقات عن Firebase

### ✅ المزايا

1. **لا يحتاج إنترنت**: يعمل بدون اتصال
2. **سهولة الإعداد**: لا حاجة لتكوين Firebase
3. **سرعة**: لا تأخير في الشبكة
4. **خصوصية**: البيانات محلية فقط

### ⚠️ القيود

1. **بيانات محلية فقط**: كل جهاز له بياناته الخاصة
2. **لا مزامنة بين الأجهزة**: البيانات لا تنتقل بين الأجهزة
3. **فقدان البيانات**: عند إلغاء تثبيت التطبيق، تُفقد البيانات
4. **لا نسخ احتياطي سحابي**: يجب عمل نسخ احتياطي يدوي

## التطوير المستقبلي

### خيارات للتحسين

1. **SQLite**: لتخزين أكثر تعقيداً
2. **Hive**: قاعدة بيانات NoSQL محلية سريعة
3. **Export/Import**: تصدير واستيراد البيانات
4. **Sync API**: إضافة API خاص للمزامنة

## استكشاف الأخطاء

### مشكلة: البيانات لا تظهر

**الحل**:
```dart
// تأكد من استدعاء initializeSampleData
LocalStorageService.initializeSampleData();
```

### مشكلة: لا يمكن تسجيل الدخول

**الحل**:
1. استخدم وضع "حساب تجريبي"
2. أو أنشئ حساب جديد من شاشة إدارة المديرين

### مشكلة: البيانات تختفي

**السبب**: إلغاء تثبيت التطبيق يحذف SharedPreferences

**الحل**: 
- استخدم وضع التطوير
- أو أضف ميزة تصدير/استيراد البيانات

## الكود المهم

### تهيئة البيانات في App

```dart
class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    LocalStorageService.initializeSampleData();
  }
}
```

### استخدام في Cubits

```dart
// في RequestCubit
_requestsSubscription = LocalStorageService.getRequestsStream().listen(
  (requests) {
    emit(RequestLoaded(requests));
  },
);

// في AdminCubit
final admin = await LocalStorageService.loginAdmin(email, password);
```

## ملاحظات مهمة

1. **الأداء**: SharedPreferences مناسب للبيانات البسيطة
2. **الحجم**: لا تخزن بيانات كبيرة جداً
3. **التشفير**: البيانات غير مشفرة (يمكن إضافة تشفير)
4. **النسخ الاحتياطي**: فكر في إضافة ميزة النسخ الاحتياطي

## الخلاصة

التطبيق الآن يعمل بالكامل بدون Firebase أو أي backend خارجي. جميع البيانات محلية وآمنة على الجهاز. النظام يدعم جميع الميزات الأساسية مع تحديثات فورية باستخدام Streams.
