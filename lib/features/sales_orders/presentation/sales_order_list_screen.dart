import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/sales_order_cubit.dart';
import 'sales_order_detail_screen.dart';

class SalesOrderListScreen extends StatefulWidget {
  const SalesOrderListScreen({Key? key}) : super(key: key);

  @override
  State<SalesOrderListScreen> createState() => _SalesOrderListScreenState();
}

class _SalesOrderListScreenState extends State<SalesOrderListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all sales orders when the screen loads
    context.read<SalesOrderCubit>().fetchSalesOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Orders'),
      ),
      body: BlocBuilder<SalesOrderCubit, SalesOrderState>(
        builder: (context, state) {
          if (state is SalesOrderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SalesOrderLoaded) {
            final orders = state.orders;
            if (orders.isEmpty) {
              return const Center(child: Text('No Sales Orders Found'));
            }
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final isConfirmed = order.state == 'sale';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('${order.name} - ${order.partnerName}'),
                    subtitle: Text(
                        'Date: ${order.dateOrder}\nTotal: \$${order.amountTotal}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isConfirmed
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.state.toUpperCase(),
                        style: TextStyle(
                          color: isConfirmed
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SalesOrderDetailScreen(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is SalesOrderError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
