import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/customer_model.dart';
import '../logic/customer_cubit.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;
  final bool isOnline;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
    required this.isOnline,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _phoneController = TextEditingController(
      text: widget.customer.phone,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _savePhone() {
    final newPhone = _phoneController.text.trim();

    if (newPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم الهاتف'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<CustomerCubit>().updatePhone(
          partnerId: widget.customer.id,
          newPhone: newPhone,
          isOnline: widget.isOnline,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isOnline
              ? 'تم تحديث رقم الهاتف بنجاح'
              : 'تم حفظ التعديل محلياً وسيتم رفعه عند الاتصال بالإنترنت',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Customer Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.customer.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'البريد الإلكتروني',
                      value: widget.customer.email.isNotEmpty
                          ? widget.customer.email
                          : 'غير متوفر',
                    ),
                    const SizedBox(height: 18),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'المدينة',
                      value: widget.customer.city.isNotEmpty
                          ? widget.customer.city
                          : 'غير متوفر',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Phone Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رقم الهاتف',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'أدخل رقم الهاتف',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _savePhone,
                        icon: const Icon(
                          Icons.save_outlined,
                          size: 20,
                        ),
                        label: const Text('حفظ التعديلات'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 21,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(
                    alpha: 0.55,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}