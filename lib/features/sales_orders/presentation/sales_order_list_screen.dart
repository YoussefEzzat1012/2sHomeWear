import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../logic/sales_order_cubit.dart';
import 'sales_order_detail_screen.dart';

class SalesOrderListScreen extends StatefulWidget {
  const SalesOrderListScreen({
    super.key,
  });

  @override
  State<SalesOrderListScreen> createState() => _SalesOrderListScreenState();
}

class _SalesOrderListScreenState extends State<SalesOrderListScreen> {
  @override
  void initState() {
    super.initState();

    _fetchOrders();
  }

  void _fetchOrders() {
    context.read<SalesOrderCubit>().fetchSalesOrders();
  }

  Future<void> _openOrderDetails(order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalesOrderDetailScreen(
          order: order,
        ),
      ),
    );

    // Reload orders after returning from details
    if (mounted) {
      _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Orders'),
      ),
      body: BlocBuilder<SalesOrderCubit, SalesOrderState>(
        builder: (context, state) {
          if (state is SalesOrderLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            );
          }

          if (state is SalesOrderLoaded) {
            final orders = state.orders;

            if (orders.isEmpty) {
              return _EmptyOrdersState(
                theme: theme,
              );
            }

            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () async {
                _fetchOrders();
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  24,
                ),
                itemCount: orders.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (context, index) {
                  final order = orders[index];

                  final isConfirmed = order.state == 'sale';

                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        '${order.name} - ${order.partnerName}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(
                          top: 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${order.dateOrder}',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Total: \$${order.amountTotal}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: _OrderStatusBadge(
                        status: order.state,
                        isConfirmed: isConfirmed,
                        theme: theme,
                      ),
                      onTap: () {
                        _openOrderDetails(order);
                      },
                    ),
                  );
                },
              ),
            );
          }

          if (state is SalesOrderError) {
            return _SalesOrderErrorState(
              message: state.message,
              theme: theme,
              onRetry: _fetchOrders,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool isConfirmed;
  final ThemeData theme;

  const _OrderStatusBadge({
    required this.status,
    required this.isConfirmed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    final backgroundColor = isConfirmed
        ? AppColors.successBackground
        : colorScheme.primary.withValues(
            alpha: 0.12,
          );

    final textColor = isConfirmed ? AppColors.success : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyOrdersState({
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
                Icons.receipt_long_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Sales Orders Found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no sales orders available at the moment.',
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

class _SalesOrderErrorState extends StatelessWidget {
  final String message;
  final ThemeData theme;
  final VoidCallback onRetry;

  const _SalesOrderErrorState({
    required this.message,
    required this.theme,
    required this.onRetry,
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }
}