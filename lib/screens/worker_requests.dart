import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/cubits/request_state.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';

class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({super.key});

  @override
  State<WorkerRequestsScreen> createState() => _WorkerRequestsScreenState();
}

class _WorkerRequestsScreenState extends State<WorkerRequestsScreen> {
  String _typeFilter = 'الكل';
  String _areaFilter = 'الكل';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات العامل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/worker-profile'),
            tooltip: 'الملف الشخصي',
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          children: [
            BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
              if (state is Authenticated && !state.worker.isSubscriptionActive) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.info, color: Colors.teal),
                    title: const Text('انتهى الاشتراك. يرجى التجديد لعرض الطلبات.'),
                  ),
                );
              }
              if (state is! Authenticated) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock, color: Colors.teal),
                    title: const Text('يرجى تسجيل الدخول لاستلام الطلبات.'),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            BlocBuilder<RequestCubit, RequestState>(
              builder: (context, state) {
                if (state is RequestLoaded) {
                  final newRequests = state.requests.where((r) => r.status == 'new').toList();
                  // Ensure unique, trimmed values to avoid duplicates or value mismatches
                  final types = <String>{'الكل', ...newRequests.map((r) => r.type.trim())};
                  final areas = <String>{'الكل', ...newRequests.map((r) => r.area.trim())};
                  // Guard current selected values against items list to avoid Dropdown assertion
                  final safeTypeFilter = types.contains(_typeFilter) ? _typeFilter : 'الكل';
                  final safeAreaFilter = areas.contains(_areaFilter) ? _areaFilter : 'الكل';
                  final filtered = newRequests.where((r) {
                    final typeOk = safeTypeFilter == 'الكل' || r.type.trim() == safeTypeFilter;
                    final areaOk = safeAreaFilter == 'الكل' || r.area.trim() == safeAreaFilter;
                    return typeOk && areaOk;
                  }).toList();
                  return Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: safeTypeFilter,
                                items: types.map((e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                )).toList(),
                                onChanged: (v) => setState(() => _typeFilter = v ?? 'الكل'),
                                decoration: const InputDecoration(labelText: 'النوع'),
                                isExpanded: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: safeAreaFilter,
                                items: areas.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
                                onChanged: (v) => setState(() => _areaFilter = v ?? 'الكل'),
                                decoration: const InputDecoration(labelText: 'المنطقة'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, authState) {
                              bool disabled = true;
                              String workerName = '';
                              if (authState is Authenticated) {
                                // Enable only if subscription is active
                                disabled = !authState.worker.isSubscriptionActive;
                                workerName = authState.worker.name;
                              }
                              return ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final r = filtered[index];
                                  return Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.home_repair_service, color: Colors.teal),
                                      title: Text(
                                        '${r.type} - ${r.area}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(r.description),
                                      trailing: ElevatedButton(
                                        onPressed: disabled
                                            ? null
                                            : () {
                                                context.read<RequestCubit>().takeRequest(id: r.id, workerName: workerName);
                                              },
                                        child: const Text('استلام'),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state is RequestLoading) {
                  return const Expanded(child: Center(child: CircularProgressIndicator()));
                }
                return const Expanded(child: SizedBox.shrink());
              },
            ),
          ],
          ),
        ),
      ),
    );
  }
}
