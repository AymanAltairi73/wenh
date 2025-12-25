import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenh/models/favorite_request_model.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_requests';
  static const String _historyKey = 'request_history';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Favorites Management
  Future<void> saveFavorite(FavoriteRequestModel favorite) async {
    final favorites = await getAllFavorites();
    final index = favorites.indexWhere((f) => f.id == favorite.id);
    
    if (index >= 0) {
      favorites[index] = favorite;
    } else {
      favorites.add(favorite);
    }
    
    final jsonList = favorites.map((f) => jsonEncode(f.toJson())).toList();
    await _prefs.setStringList(_favoritesKey, jsonList);
  }

  Future<List<FavoriteRequestModel>> getAllFavorites() async {
    final jsonList = _prefs.getStringList(_favoritesKey) ?? [];
    return jsonList
        .map((json) => FavoriteRequestModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<FavoriteRequestModel?> getFavorite(String id) async {
    final favorites = await getAllFavorites();
    try {
      return favorites.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteFavorite(String id) async {
    final favorites = await getAllFavorites();
    favorites.removeWhere((f) => f.id == id);
    
    final jsonList = favorites.map((f) => jsonEncode(f.toJson())).toList();
    await _prefs.setStringList(_favoritesKey, jsonList);
  }

  Future<int> getFavoritesCount() async {
    final favorites = await getAllFavorites();
    return favorites.length;
  }

  Future<bool> isFavorite(String id) async {
    final favorite = await getFavorite(id);
    return favorite != null;
  }

  // History Management
  Future<void> addToHistory(FavoriteRequestModel request) async {
    final history = await getHistory();
    
    // Remove if already exists to avoid duplicates
    history.removeWhere((r) => r.id == request.id);
    
    // Add to beginning of list
    history.insert(0, request);
    
    // Keep only last 50 items
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    final jsonList = history.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(_historyKey, jsonList);
  }

  Future<List<FavoriteRequestModel>> getHistory() async {
    final jsonList = _prefs.getStringList(_historyKey) ?? [];
    return jsonList
        .map((json) => FavoriteRequestModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<List<FavoriteRequestModel>> getHistoryByCategory(String category) async {
    final history = await getHistory();
    return history.where((r) => r.category == category).toList();
  }

  Future<List<FavoriteRequestModel>> getHistoryByArea(String area) async {
    final history = await getHistory();
    return history.where((r) => r.area == area).toList();
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  Future<int> getHistoryCount() async {
    final history = await getHistory();
    return history.length;
  }

  Future<void> deleteFromHistory(String id) async {
    final history = await getHistory();
    history.removeWhere((r) => r.id == id);
    
    final jsonList = history.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(_historyKey, jsonList);
  }
}
