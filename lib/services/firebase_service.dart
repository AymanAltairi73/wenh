import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:wenh/models/admin_model.dart';
import 'package:wenh/models/request_model.dart';

class LocalStorageService {
  static final _adminsController = StreamController<List<AdminModel>>.broadcast();
  static final _requestsController = StreamController<List<RequestModel>>.broadcast();
  
  static List<AdminModel> _admins = [];
  static List<RequestModel> _requests = [];
  static AdminModel? _currentAdmin;

  static Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final adminsJson = prefs.getString('admins');
    if (adminsJson != null) {
      final List<dynamic> decoded = jsonDecode(adminsJson);
      _admins = decoded.map((json) => AdminModel.fromJson(json)).toList();
    }
    
    final requestsJson = prefs.getString('requests');
    if (requestsJson != null) {
      final List<dynamic> decoded = jsonDecode(requestsJson);
      _requests = decoded.map((json) => RequestModel(
        id: json['id'],
        type: json['type'],
        area: json['area'],
        description: json['description'],
        status: json['status'],
        takenBy: json['takenBy'],
      )).toList();
    }
  }

  static Future<void> _saveAdmins() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_admins.map((a) => a.toJson()).toList());
    await prefs.setString('admins', json);
    _adminsController.add(List.from(_admins));
  }

  static Future<void> _saveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_requests.map((r) => {
      'id': r.id,
      'type': r.type,
      'area': r.area,
      'description': r.description,
      'status': r.status,
      'takenBy': r.takenBy,
    }).toList());
    await prefs.setString('requests', json);
    _requestsController.add(List.from(_requests));
  }

  static Future<AdminModel?> loginAdmin(String email, String password) async {
    await _loadData();
    
    try {
      final admin = _admins.firstWhere(
        (a) => a.email == email && a.isActive,
        orElse: () => throw Exception('Admin not found'),
      );

      final updatedAdmin = admin.copyWith(lastLogin: DateTime.now());
      final index = _admins.indexWhere((a) => a.id == admin.id);
      _admins[index] = updatedAdmin;
      await _saveAdmins();
      
      _currentAdmin = updatedAdmin;
      return updatedAdmin;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createDemoAdmin(String email, String password) async {
    await _loadData();
    
    try {
      if (_admins.any((a) => a.email == email)) {
        return;
      }

      final admin = AdminModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'مدير تجريبي',
        email: email,
        role: AdminRole.admin,
        isActive: true,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        permissions: AdminModel.getDefaultPermissions(AdminRole.admin),
      );

      _admins.add(admin);
      await _saveAdmins();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    _currentAdmin = null;
  }

  static Stream<List<AdminModel>> getAdminsStream() async* {
    await _loadData();
    yield List.from(_admins);
    yield* _adminsController.stream;
  }

  static Stream<List<RequestModel>> getRequestsStream() async* {
    await _loadData();
    yield List.from(_requests);
    yield* _requestsController.stream;
  }

  static Future<void> addRequest(RequestModel request) async {
    await _loadData();
    _requests.add(request);
    await _saveRequests();
  }

  static Future<void> updateRequestStatus({
    required String id,
    required String status,
    String? takenBy,
  }) async {
    await _loadData();
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: status,
        takenBy: takenBy,
      );
      await _saveRequests();
    }
  }

  static Future<void> deleteRequest(String id) async {
    await _loadData();
    _requests.removeWhere((r) => r.id == id);
    await _saveRequests();
  }

  static Future<void> updateAdmin(AdminModel admin) async {
    await _loadData();
    final index = _admins.indexWhere((a) => a.id == admin.id);
    if (index != -1) {
      _admins[index] = admin;
      await _saveAdmins();
    }
  }

  static Future<void> deleteAdmin(String id) async {
    await _loadData();
    _admins.removeWhere((a) => a.id == id);
    await _saveAdmins();
  }

  static Future<void> createAdmin({
    required String email,
    required String password,
    required String name,
    required AdminRole role,
  }) async {
    await _loadData();
    
    try {
      if (_admins.any((a) => a.email == email)) {
        throw Exception('البريد الإلكتروني مستخدم بالفعل');
      }

      final admin = AdminModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
        permissions: AdminModel.getDefaultPermissions(role),
      );

      _admins.add(admin);
      await _saveAdmins();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, int>> getAnalytics() async {
    await _loadData();

    final newRequests = _requests.where((r) => r.status == 'new').length;
    final takenRequests = _requests.where((r) => r.status == 'taken').length;

    return {
      'totalRequests': _requests.length,
      'newRequests': newRequests,
      'takenRequests': takenRequests,
      'totalWorkers': 0,
      'totalAdmins': _admins.length,
    };
  }

  static Future<void> initializeSampleData() async {
    await _loadData();
    
    if (_requests.isEmpty) {
      final sampleRequests = [
        RequestModel.create(
          type: '🏗 البناء والتشطيبات - نجّار',
          area: 'بغداد',
          description: 'تفصيل وتركيب أبواب داخلية',
        ),
        RequestModel.create(
          type: '⚡ الكهرباء والطاقة - كهربائي',
          area: 'أربيل',
          description: 'تمديدات كهربائية لغرفة مع تركيب إنارة',
        ),
        RequestModel.create(
          type: '🚿 الماء والتبريد - سبّاك',
          area: 'البصرة',
          description: 'تصليح تسريب في حمام وتبديل سيفون',
        ),
      ];

      for (var request in sampleRequests) {
        await addRequest(request);
      }
    }
  }
  
  static void dispose() {
    _adminsController.close();
    _requestsController.close();
  }
}
