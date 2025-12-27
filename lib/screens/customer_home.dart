// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:wenh/cubits/request_cubit.dart';
// import 'package:wenh/cubits/request_state.dart';
// import 'package:wenh/widgets/custom_button.dart';

// class CustomerHomeScreen extends StatelessWidget {
//   const CustomerHomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('وينه - الصفحة الرئيسية'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () => Navigator.pushNamed(context, '/customer-profile'),
//             tooltip: 'الملف الشخصي',
//           ),
//         ],
//       ),
//       body: Container(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 8),
//                 Center(
//                   child: Image.asset(
//                     'assets/images/logo.png',
//                     height: 80,
//                     errorBuilder: (_, __, ___) => const Icon(Icons.handyman, size: 56, color: Colors.teal),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'مرحباً! اختر ما تريد القيام به:',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//                 ),
//                 const SizedBox(height: 16),
//                 BlocBuilder<RequestCubit, RequestState>(
//                   builder: (context, state) {
//                     int total = 0;
//                     int newCount = 0;
//                     if (state is RequestLoaded) {
//                       total = state.requests.length;
//                       newCount = state.requests.where((r) => r.status == 'new').length;
//                     }
//                     return Row(
//                       children: [
//                         Expanded(
//                           child: Card(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                               child: Column(
//                                 children: [
//                                   const Icon(Icons.assignment, color: Colors.teal),
//                                   const SizedBox(height: 8),
//                                   Text('إجمالي الطلبات', style: Theme.of(context).textTheme.bodyMedium),
//                                   const SizedBox(height: 4),
//                                   Text('$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Card(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                               child: Column(
//                                 children: [
//                                   const Icon(Icons.fiber_new, color: Colors.teal),
//                                   const SizedBox(height: 8),
//                                   Text('الطلبات الجديدة', style: Theme.of(context).textTheme.bodyMedium),
//                                   const SizedBox(height: 4),
//                                   Text('$newCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 CustomButton(
//                   label: 'إرسال طلب',
//                   icon: Icons.send,
//                   onPressed: () => Navigator.pushNamed(context, '/send'),
//                 ),
//                 const SizedBox(height: 12),
//                 CustomButton(
//                   label: 'تسجيل دخول العامل',
//                   icon: Icons.login,
//                   onPressed: () => Navigator.pushNamed(context, '/login'),
//                 ),
//                 const SizedBox(height: 12),
//                 CustomButton(
//                   label: 'لوحة التحكم',
//                   icon: Icons.dashboard,
//                   onPressed: () => Navigator.pushNamed(context, '/admin'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
