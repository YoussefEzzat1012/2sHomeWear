import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/models/user_model.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/presentation/login_screen.dart'; // Adjust import path if needed
import '../../sales_orders/presentation/sales_order_list_screen.dart';
import '../logic/customer_cubit.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  final UserModel user;

  const CustomerListScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  @override
  void initState() {
    super.initState();
    // جلب البيانات مع الافتراض المبدئي لوجود اتصال (أو ربطه بـ connectivity_plus)
    context.read<CustomerCubit>().fetchCustomers(isOnline: true);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // 1. Clear session via AuthCubit
              await context.read<AuthCubit>().logout();

              // 2. Redirect back to LoginScreen and clear routing stack
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('خروج', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة العملاء'),
        actions: [
          // 1. Sales Orders Icon (Always visible)
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Sales Orders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SalesOrderListScreen(),
                ),
              );
            },
          ),

          // 2. Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'البحث عن عميل...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                context.read<CustomerCubit>().searchCustomer(query);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CustomerLoaded) {
                  if (state.filteredCustomers.isEmpty) {
                    return const Center(child: Text('لا يوجد عملاء'));
                  }
                  return ListView.builder(
                    itemCount: state.filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = state.filteredCustomers[index];
                      return ListTile(
                        title: Text(customer.name),
                        subtitle: Text('${customer.phone} | ${customer.city}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailScreen(
                                customer: customer,
                                isOnline: !state.isOffline,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is CustomerError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
