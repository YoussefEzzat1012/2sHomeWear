import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/models/user_model.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/presentation/login_screen.dart';
import '../../sales_orders/presentation/sales_order_list_screen.dart';
import '../logic/customer_cubit.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  final UserModel user;

  const CustomerListScreen({
    super.key,
    required this.user,
  });

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  @override
  void initState() {
    super.initState();

    context.read<CustomerCubit>().fetchCustomers(
          isOnline: true,
        );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text(
            'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await context.read<AuthCubit>().logout();

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Text(
                'خروج',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة العملاء'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),
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
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
            ),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              12,
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'البحث عن عميل...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                ),
              ),
              onChanged: (query) {
                context.read<CustomerCubit>().searchCustomer(query);
              },
            ),
          ),

          // Customer List
          Expanded(
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                if (state is CustomerLoaded) {
                  if (state.filteredCustomers.isEmpty) {
                    return _EmptyCustomersState(
                      theme: theme,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      24,
                    ),
                    itemCount: state.filteredCustomers.length,
                    separatorBuilder: (_, __) {
                      return const SizedBox(height: 10);
                    },
                    itemBuilder: (context, index) {
                      final customer = state.filteredCustomers[index];

                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              '${customer.phone} • ${customer.city}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
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
                        ),
                      );
                    },
                  );
                }

                if (state is CustomerError) {
                  return _CustomerErrorState(
                    message: state.message,
                    theme: theme,
                  );
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

class _EmptyCustomersState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyCustomersState({
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا يوجد عملاء',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على أي عملاء مطابقين للبحث.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(
                  alpha: 0.60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerErrorState extends StatelessWidget {
  final String message;
  final ThemeData theme;

  const _CustomerErrorState({
    required this.message,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}