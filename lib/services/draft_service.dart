import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenh/models/request_draft_model.dart';

class DraftService {
  static const String _draftKey = 'request_drafts';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveDraft(RequestDraftModel draft) async {
    final drafts = await getAllDrafts();
    final index = drafts.indexWhere((d) => d.id == draft.id);
    
    if (index >= 0) {
      drafts[index] = draft;
    } else {
      drafts.add(draft);
    }
    
    final jsonList = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs.setStringList(_draftKey, jsonList);
  }

  Future<List<RequestDraftModel>> getAllDrafts() async {
    final jsonList = _prefs.getStringList(_draftKey) ?? [];
    return jsonList
        .map((json) => RequestDraftModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<RequestDraftModel?> getDraft(String id) async {
    final drafts = await getAllDrafts();
    try {
      return drafts.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteDraft(String id) async {
    final drafts = await getAllDrafts();
    drafts.removeWhere((d) => d.id == id);
    
    final jsonList = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs.setStringList(_draftKey, jsonList);
  }

  Future<void> deleteAllDrafts() async {
    await _prefs.remove(_draftKey);
  }

  Future<int> getDraftCount() async {
    final drafts = await getAllDrafts();
    return drafts.length;
  }
}
