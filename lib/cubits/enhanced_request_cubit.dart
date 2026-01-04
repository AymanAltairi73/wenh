import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/app_repository.dart';
import '../models/request_model.dart';

/// Enhanced request cubit with repository pattern and better state management
class EnhancedRequestCubit extends Cubit<EnhancedRequestState> {
  final AppRepository _repository;
  
  EnhancedRequestCubit({AppRepository? repository})
      : _repository = repository ?? AppRepository(),
        super(const EnhancedRequestState.initial());

  // --- Request Loading ---
  
  Future<void> loadRequests({
    String? status,
    String? area,
    bool refresh = false,
  }) async {
    emit(const EnhancedRequestState.loading());
    
    try {
      final requests = await _repository.getRequests(
        status: status,
        area: area,
        limit: 50,
        forceRefresh: refresh,
      );
      
      emit(EnhancedRequestState.loaded(
        requests: requests,
        status: status,
        area: area,
        hasMore: requests.length >= 50,
      ));
    } catch (e) {
      emit(EnhancedRequestState.error(
        message: e.toString(),
        status: status,
        area: area,
      ));
    }
  }

  // --- Pagination ---
  
  Future<void> loadMoreRequests() async {
    final currentState = state;
    if (currentState is! EnhancedRequestStateLoaded || !currentState.hasMore) {
      return;
    }

    emit(EnhancedRequestState.loaded(
      requests: currentState.requests,
      status: currentState.status,
      area: currentState.area,
      hasMore: currentState.hasMore,
      lastDocument: currentState.lastDocument,
      isLoadingMore: true,
      isRealtime: currentState.isRealtime,
      isSearch: currentState.isSearch,
      searchQuery: currentState.searchQuery,
    ));

    try {
      final moreRequests = await _repository.getRequests(
        status: currentState.status,
        area: currentState.area,
        limit: 20,
      );

      final allRequests = [...currentState.requests, ...moreRequests];
      
      emit(EnhancedRequestState.loaded(
        requests: allRequests,
        status: currentState.status,
        area: currentState.area,
        hasMore: moreRequests.length >= 20,
        lastDocument: moreRequests.isNotEmpty ? moreRequests.last.id : null,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(EnhancedRequestState.loaded(
        requests: currentState.requests,
        status: currentState.status,
        area: currentState.area,
        hasMore: currentState.hasMore,
        lastDocument: currentState.lastDocument,
        isLoadingMore: false,
        isRealtime: currentState.isRealtime,
        isSearch: currentState.isSearch,
        searchQuery: currentState.searchQuery,
      ));
      emit(EnhancedRequestState.error(
        message: e.toString(),
        status: currentState.status,
        area: currentState.area,
      ));
    }
  }

  // --- Real-time Updates ---
  
  void startRealtimeUpdates({String? status, String? area}) {
    emit(const EnhancedRequestState.loading());
    
    _repository.getRequestsStream(status: status, area: area).listen(
      (requests) {
        emit(EnhancedRequestState.loaded(
          requests: requests,
          status: status,
          area: area,
          isRealtime: true,
        ));
      },
      onError: (error) {
        emit(EnhancedRequestState.error(
          message: error.toString(),
          status: status,
          area: area,
        ));
      },
    );
  }

  // --- Search ---
  
  Future<void> searchRequests(String query) async {
    emit(const EnhancedRequestState.loading());
    
    try {
      final results = await _repository.searchRequests(query: query);
      
      emit(EnhancedRequestState.loaded(
        requests: results,
        isSearch: true,
        searchQuery: query,
      ));
    } catch (e) {
      emit(EnhancedRequestState.error(message: e.toString()));
    }
  }

  // --- Cache Management ---
  
  Future<void> refreshCache() async {
    final currentState = state;
    if (currentState is EnhancedRequestStateLoaded) {
      await loadRequests(
        status: currentState.status,
        area: currentState.area,
        refresh: true,
      );
    }
  }

  Future<void> clearCache() async {
    await _repository.clearCache();
    emit(const EnhancedRequestState.initial());
  }

  // --- Request Actions ---
  
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _repository.batchUpdateRequests([
        {
          'id': requestId,
          'data': {'status': newStatus},
        }
      ]);
      
      await refreshCache();
    } catch (e) {
      final currentState = state;
      if (currentState is EnhancedRequestStateLoaded) {
        emit(EnhancedRequestState.error(
          message: e.toString(),
          status: currentState.status,
          area: currentState.area,
        ));
      } else {
        emit(EnhancedRequestState.error(message: e.toString()));
      }
    }
  }

  // --- State Reset ---
  
  void reset() {
    emit(const EnhancedRequestState.initial());
  }
}

/// Enhanced request state with more detailed information
abstract class EnhancedRequestState {
  const EnhancedRequestState();
  
  const factory EnhancedRequestState.initial() = EnhancedRequestStateInitial;
  const factory EnhancedRequestState.loading() = EnhancedRequestStateLoading;
  const factory EnhancedRequestState.loaded({
    required List<RequestModel> requests,
    String? status,
    String? area,
    bool hasMore,
    String? lastDocument,
    bool isLoadingMore,
    bool isRealtime,
    bool isSearch,
    String? searchQuery,
  }) = EnhancedRequestStateLoaded;
  
  const factory EnhancedRequestState.error({
    required String message,
    String? status,
    String? area,
  }) = EnhancedRequestStateError;
}

class EnhancedRequestStateInitial extends EnhancedRequestState {
  const EnhancedRequestStateInitial();
}

class EnhancedRequestStateLoading extends EnhancedRequestState {
  const EnhancedRequestStateLoading();
}

class EnhancedRequestStateLoaded extends EnhancedRequestState {
  final List<RequestModel> requests;
  final String? status;
  final String? area;
  final bool hasMore;
  final String? lastDocument;
  final bool isLoadingMore;
  final bool isRealtime;
  final bool isSearch;
  final String? searchQuery;
  final String? error;

  const EnhancedRequestStateLoaded({
    required this.requests,
    this.status,
    this.area,
    this.hasMore = false,
    this.lastDocument,
    this.isLoadingMore = false,
    this.isRealtime = false,
    this.isSearch = false,
    this.searchQuery,
    this.error,
  });

  EnhancedRequestStateLoaded copyWith({
    List<RequestModel>? requests,
    String? status,
    String? area,
    bool? hasMore,
    String? lastDocument,
    bool? isLoadingMore,
    bool? isRealtime,
    bool? isSearch,
    String? searchQuery,
    String? error,
  }) {
    return EnhancedRequestStateLoaded(
      requests: requests ?? this.requests,
      status: status ?? this.status,
      area: area ?? this.area,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRealtime: isRealtime ?? this.isRealtime,
      isSearch: isSearch ?? this.isSearch,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnhancedRequestStateLoaded &&
          runtimeType == other.runtimeType &&
          requests == other.requests &&
          status == other.status &&
          area == other.area &&
          hasMore == other.hasMore &&
          lastDocument == other.lastDocument &&
          isLoadingMore == other.isLoadingMore &&
          isRealtime == other.isRealtime &&
          isSearch == other.isSearch &&
          searchQuery == other.searchQuery &&
          error == other.error;

  @override
  int get hashCode => Object.hash(
        requests,
        status,
        area,
        hasMore,
        lastDocument,
        isLoadingMore,
        isRealtime,
        isSearch,
        searchQuery,
        error,
      );
}

class EnhancedRequestStateError extends EnhancedRequestState {
  final String message;
  final String? status;
  final String? area;

  const EnhancedRequestStateError({
    required this.message,
    this.status,
    this.area,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnhancedRequestStateError &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          status == other.status &&
          area == other.area;

  @override
  int get hashCode => Object.hash(message, status, area);
}
