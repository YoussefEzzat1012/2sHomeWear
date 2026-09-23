import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/customer_model.dart';
import '../logic/customer_cubit.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;
  final bool isOnline;

  const CustomerDetailScreen({
    Key? key,
    required this.customer,
    required this.isOnline,
  }) : super(key: key);

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.customer.phone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _savePhone() {
    final newPhone = _phoneController.text.trim();
    context.read<CustomerCubit>().updatePhone(
          partnerId: widget.customer.id,
          newPhone: newPhone,
          isOnline: widget.isOnline,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isOnline
            ? 'تم تحديث رقم الهاتف بنجاح'
            : 'تم حفظ التعديل محلياً وسيتم رفعه عند الاتصال بالإنترنت'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.customer.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البريد الإلكتروني: ${widget.customer.email}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('المدينة: ${widget.customer.city}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _savePhone,
                child: const Text('حفظ التعديلات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
