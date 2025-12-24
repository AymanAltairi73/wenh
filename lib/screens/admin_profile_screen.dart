import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/auth_cubit.dart';
import 'package:wenh/cubits/auth_state.dart';
import 'package:wenh/cubits/request_cubit.dart';
import 'package:wenh/cubits/request_state.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          String adminName = 'المشرف';
          String adminEmail = 'admin@wenh.com';

          if (authState is Authenticated) {
            adminName = authState.worker.name;
            adminEmail = authState.worker.email;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.teal.shade100,
                        child: const Icon(Icons.admin_panel_settings, size: 50, color: Colors.teal),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        adminName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        adminEmail,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      const Chip(
                        label: Text('مدير النظام'),
                        backgroundColor: Colors.teal,
                        labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.analytics, color: Colors.teal),
                      title: const Text(
                        'إحصائيات النظام',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const Divider(height: 1),
                    BlocBuilder<RequestCubit, RequestState>(
                      builder: (context, state) {
                        int totalRequests = 0;
                        int newRequests = 0;
                        int takenRequests = 0;

                        if (state is RequestLoaded) {
                          totalRequests = state.requests.length;
                          newRequests = state.requests.where((r) => r.status == 'new').length;
                          takenRequests = state.requests.where((r) => r.status == 'taken').length;
                        }

                        return Column(
                          children: [
                            ListTile(
                              title: const Text('إجمالي الطلبات'),
                              trailing: Text(
                                '$totalRequests',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text('الطلبات الجديدة'),
                              trailing: Text(
                                '$newRequests',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text('الطلبات المستلمة'),
                              trailing: Text(
                                '$takenRequests',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.teal),
                      title: const Text(
                        'صلاحيات المدير',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('إدارة جميع الطلبات'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('تغيير حالة الطلبات'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('عرض إحصائيات النظام'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('إدارة العمال'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.menu_book, color: Colors.teal),
                      title: const Text(
                        'الإجراءات السريعة',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.dashboard, color: Colors.teal),
                      title: const Text('لوحة التحكم'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.teal),
                      title: const Text('الإعدادات'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
