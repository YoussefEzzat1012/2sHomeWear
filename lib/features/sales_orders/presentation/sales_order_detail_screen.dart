import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/sales_order_model.dart';
import '../logic/sales_order_cubit.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  final SalesOrderModel order;

  const SalesOrderDetailScreen({Key? key, required this.order})
      : super(key: key);

  @override
  State<SalesOrderDetailScreen> createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SalesOrderCubit>().fetchOrderDetails(widget.order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب: ${widget.order.name}')),
      body: BlocConsumer<SalesOrderCubit, SalesOrderState>(
        listener: (context, state) {
          if (state is SalesOrderConfirmSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('تم تأكيد أمر البيع بنجاح!'),
                  backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is SalesOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is SalesOrderLoading || state is SalesOrderConfirming) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SalesOrderDetailLoaded) {
            final order = state.selectedOrder;
            final canConfirm = order.state == 'draft' || order.state == 'sent';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('العميل: ${order.partnerName}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('حالة الطلب: ${order.state.toUpperCase()}'),
                  const Divider(height: 32),
                  const Text('المنتجات:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: order.orderLines.length,
                      itemBuilder: (context, index) {
                        final line = order.orderLines[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(line.productName),
                            subtitle: Text(
                                'الكمية: ${line.productUomQty} | السعر: \$${line.priceUnit}'),
                            trailing: Text('\$${line.priceSubtotal}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي الكلي:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('\$${order.amountTotal}',
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (canConfirm)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () {
                          context
                              .read<SalesOrderCubit>()
                              .confirmOrder(order.id);
                        },
                        child: const Text('تأكيد الطلب (Confirm Order)',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
