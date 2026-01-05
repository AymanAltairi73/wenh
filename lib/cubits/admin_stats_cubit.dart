import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/request_model.dart';
import '../models/worker_model.dart';
import '../services/firestore_service.dart';

class AdminStatsState extends Equatable {
  final bool isLoading;
  final Map<String, dynamic> stats;
  final Map<String, double> revenueData;
  final Map<String, int> subscriptionData;
  final String? error;

  const AdminStatsState({
    this.isLoading = false,
    this.stats = const {},
    this.revenueData = const {},
    this.subscriptionData = const {},
    this.error,
  });

  AdminStatsState copyWith({
    bool? isLoading,
    Map<String, dynamic>? stats,
    Map<String, double>? revenueData,
    Map<String, int>? subscriptionData,
    String? error,
  }) {
    return AdminStatsState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      revenueData: revenueData ?? this.revenueData,
      subscriptionData: subscriptionData ?? this.subscriptionData,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    stats,
    revenueData,
    subscriptionData,
    error,
  ];
}

class AdminStatsCubit extends Cubit<AdminStatsState> {
  final FirestoreService _firestoreService;
  StreamSubscription? _requestsSubscription;
  StreamSubscription? _workersSubscription;

  AdminStatsCubit({required FirestoreService firestoreService})
    : _firestoreService = firestoreService,
      super(const AdminStatsState());

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    _workersSubscription?.cancel();
    return super.close();
  }

  Future<void> fetchStats() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Listen to requests
      _requestsSubscription?.cancel();
      _requestsSubscription = _firestoreService.getRequests().listen(
        (requests) {
          _updateStats(requests, null);
        },
        onError: (error) {
          debugPrint('[AdminStatsCubit] Requests stream error: $error');
          emit(
            state.copyWith(
              isLoading: false,
              error: 'فشل في تحميل إحصائيات الطلبات',
            ),
          );
        },
      );

      // Listen to workers
      _workersSubscription?.cancel();
      _workersSubscription = _firestoreService.getAllWorkers().listen(
        (workers) {
          _updateStats(null, workers);
        },
        onError: (error) {
          debugPrint('[AdminStatsCubit] Workers stream error: $error');
          emit(
            state.copyWith(
              isLoading: false,
              error: 'فشل في تحميل إحصائيات العمال',
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('[AdminStatsCubit] fetchStats error: $e');
      emit(state.copyWith(isLoading: false, error: 'فشل في تحميل الإحصائيات'));
    }
  }

  void _updateStats(List<RequestModel>? requests, List<WorkerModel>? workers) {
    final currentStats = Map<String, dynamic>.from(state.stats);
    final currentRevenueData = Map<String, double>.from(state.revenueData);
    final currentSubscriptionData = Map<String, int>.from(
      state.subscriptionData,
    );

    // Update request stats
    if (requests != null) {
      currentStats['totalRequests'] = requests.length;
      currentStats['newRequests'] = requests
          .where((r) => r.status == 'new')
          .length;
      currentStats['takenRequests'] = requests
          .where((r) => r.status == 'taken')
          .length;
      currentStats['completedRequests'] = requests
          .where((r) => r.status == 'completed')
          .length;

      // Calculate revenue data (monthly)
      final monthlyRevenue = <String, double>{};
      for (final request in requests) {
        if (request.status == 'taken' || request.status == 'completed') {
          final month =
              '${request.timestamp.year}-${request.timestamp.month.toString().padLeft(2, '0')}';
          monthlyRevenue[month] =
              (monthlyRevenue[month] ?? 0) + 50.0; // Assume 50 per request
        }
      }
      currentRevenueData.clear();
      currentRevenueData.addAll(monthlyRevenue);
    }

    // Update worker stats
    if (workers != null) {
      currentStats['totalWorkers'] = workers.length;
      currentStats['activeWorkers'] = workers
          .where((w) => w.isSubscriptionActive)
          .length;

      // Calculate subscription data
      final subscriptionCounts = <String, int>{};
      for (final worker in workers) {
        final plan = worker.subscriptionPlan;
        subscriptionCounts[plan] = (subscriptionCounts[plan] ?? 0) + 1;
      }
      currentSubscriptionData.clear();
      currentSubscriptionData.addAll(subscriptionCounts);

      // Calculate monthly revenue from subscriptions
      final monthlySubRevenue = <String, double>{};
      for (final worker in workers) {
        if (worker.isSubscriptionActive) {
          final month =
              '${worker.subscriptionStart.year}-${worker.subscriptionStart.month.toString().padLeft(2, '0')}';
          final amount = worker.subscriptionPlan == 'weekly'
              ? 50.0
              : 150.0; // Weekly: 50, Monthly: 150
          monthlySubRevenue[month] = (monthlySubRevenue[month] ?? 0) + amount;
        }
      }

      // Merge with existing revenue data
      for (final entry in monthlySubRevenue.entries) {
        currentRevenueData[entry.key] =
            (currentRevenueData[entry.key] ?? 0) + entry.value;
      }
    }

    emit(
      state.copyWith(
        isLoading: false,
        stats: currentStats,
        revenueData: currentRevenueData,
        subscriptionData: currentSubscriptionData,
        error: null,
      ),
    );
  }

  void refreshStats() {
    fetchStats();
  }
}
