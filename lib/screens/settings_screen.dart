import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wenh/cubits/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette, color: Colors.teal),
                  title: const Text(
                    'المظهر',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const Divider(height: 1),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        RadioListTile<AppTheme>(
                          title: const Row(
                            children: [
                              Icon(Icons.light_mode, color: Colors.orange),
                              SizedBox(width: 12),
                              Text('الوضع النهاري'),
                            ],
                          ),
                          value: AppTheme.light,
                          groupValue: state.appTheme,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<ThemeCubit>().setTheme(value);
                            }
                          },
                        ),
                        RadioListTile<AppTheme>(
                          title: const Row(
                            children: [
                              Icon(Icons.dark_mode, color: Colors.indigo),
                              SizedBox(width: 12),
                              Text('الوضع الليلي'),
                            ],
                          ),
                          value: AppTheme.dark,
                          groupValue: state.appTheme,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<ThemeCubit>().setTheme(value);
                            }
                          },
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
                  leading: const Icon(Icons.info_outline, color: Colors.teal),
                  title: const Text(
                    'حول التطبيق',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('اسم التطبيق'),
                  trailing: Text('وينه', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const ListTile(
                  title: Text('الإصدار'),
                  trailing: Text('1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
