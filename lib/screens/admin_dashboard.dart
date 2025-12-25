import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/cubits/request_state.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/admin-profile'),
            tooltip: 'الملف الشخصي',
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                if (state is Authenticated) {
                  final w = state.worker;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.verified_user, color: Colors.teal),
                      title: Text(w.name),
                      subtitle: Text('${w.email} | نهاية الاشتراك: ${w.subscriptionEnd}'),
                    ),
                  );
                }
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.teal),
                    title: Text('لا يوجد عامل مسجّل دخول'),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<RequestCubit, RequestState>(builder: (context, state) {
                  if (state is RequestLoaded) {
                    final requests = state.requests;
                    if (requests.isEmpty) return const Center(child: Text('لا توجد طلبات'));
                    return ListView.separated(
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final r = requests[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.assignment, color: Colors.teal),
                            title: Text('${r.type} - ${r.area}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.description),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Chip(
                                      label: Text(r.status == 'new' ? 'جديد' : 'تم الاستلام'),
                                      backgroundColor: r.status == 'new' ? Colors.teal.shade100 : Colors.grey.shade300,
                                    ),
                                    if (r.takenBy != null) Text('مستلم بواسطة: ${r.takenBy}'),
                                  ],
                                ),
                              ],
                            ),
                            trailing: DropdownButton<String>(
                              value: r.status,
                              items: const [
                                DropdownMenuItem(value: 'new', child: Text('جديد')),
                                DropdownMenuItem(value: 'taken', child: Text('تم الاستلام')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                final takenBy = v == 'taken' ? (r.takenBy ?? 'المشرف') : null;
                                context.read<RequestCubit>().updateStatus(id: r.id, status: v, takenBy: takenBy);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (state is RequestLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const SizedBox.shrink();
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
