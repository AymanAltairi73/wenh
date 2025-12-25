import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenh/models/request_filter_model.dart';

class FilterService {
  static const String _savedFiltersKey = 'saved_filters';
  static const String _lastFilterKey = 'last_filter';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save a named filter
  Future<void> saveFilter(String name, RequestFilterModel filter) async {
    final savedFilters = await getAllSavedFilters();
    savedFilters[name] = filter;
    
    final jsonMap = savedFilters.map((key, value) => MapEntry(key, jsonEncode(value.toJson())));
    await _prefs.setString(_savedFiltersKey, jsonEncode(jsonMap));
  }

  // Get all saved filters
  Future<Map<String, RequestFilterModel>> getAllSavedFilters() async {
    final jsonString = _prefs.getString(_savedFiltersKey);
    if (jsonString == null) return {};
    
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return jsonMap.map((key, value) {
      final filterJson = jsonDecode(value as String) as Map<String, dynamic>;
      return MapEntry(key, RequestFilterModel.fromJson(filterJson));
    });
  }

  // Get a specific saved filter
  Future<RequestFilterModel?> getSavedFilter(String name) async {
    final savedFilters = await getAllSavedFilters();
    return savedFilters[name];
  }

  // Delete a saved filter
  Future<void> deleteSavedFilter(String name) async {
    final savedFilters = await getAllSavedFilters();
    savedFilters.remove(name);
    
    final jsonMap = savedFilters.map((key, value) => MapEntry(key, jsonEncode(value.toJson())));
    await _prefs.setString(_savedFiltersKey, jsonEncode(jsonMap));
  }

  // Save the last used filter
  Future<void> saveLastFilter(RequestFilterModel filter) async {
    await _prefs.setString(_lastFilterKey, jsonEncode(filter.toJson()));
  }

  // Get the last used filter
  Future<RequestFilterModel?> getLastFilter() async {
    final jsonString = _prefs.getString(_lastFilterKey);
    if (jsonString == null) return null;
    
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return RequestFilterModel.fromJson(json);
  }

  // Clear the last filter
  Future<void> clearLastFilter() async {
    await _prefs.remove(_lastFilterKey);
  }

  // Get saved filter names
  Future<List<String>> getSavedFilterNames() async {
    final savedFilters = await getAllSavedFilters();
    return savedFilters.keys.toList();
  }

  // Check if a filter name exists
  Future<bool> filterNameExists(String name) async {
    final names = await getSavedFilterNames();
    return names.contains(name);
  }
}
