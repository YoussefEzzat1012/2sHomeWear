import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Core Imports
import 'core/network/odoo_api_client.dart';
// Data Models & Hive Adapters
import 'core/theme/app_theme.dart';
// Repositories
import 'features/auth/data/repositories/auth_repository.dart';
// Cubits / State Management
import 'features/auth/logic/auth_cubit.dart';
// UI Presentation
import 'features/auth/presentation/login_screen.dart';
import 'features/customers/data/models/customer_model.dart';
import 'features/customers/data/repositories/customer_repository.dart';
import 'features/customers/logic/customer_cubit.dart';
import 'features/sales_orders/data/repositories/sales_order_repository.dart';
import 'features/sales_orders/logic/sales_order_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive Local Storage for Offline Support
  await Hive.initFlutter();
  Hive.registerAdapter(CustomerModelAdapter());

  // 2. Instantiate Odoo JSON-RPC API Client
  final odooApiClient = OdooApiClient(
    baseUrl: 'https://2s-home-wear.odoo.com',
  );

  // 3. Instantiate Data Repositories
  final authRepository = AuthRepository(odooApiClient);
  final customerRepository = CustomerRepository(odooApiClient);
  final salesOrderRepository = SalesOrderRepository(odooApiClient);

  runApp(
    MyApp(
      authRepository: authRepository,
      customerRepository: customerRepository,
      salesOrderRepository: salesOrderRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final CustomerRepository customerRepository;
  final SalesOrderRepository salesOrderRepository;

  const MyApp({
    Key? key,
    required this.authRepository,
    required this.customerRepository,
    required this.salesOrderRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepository),
        ),
        BlocProvider<CustomerCubit>(
          create: (_) => CustomerCubit(customerRepository),
        ),
        BlocProvider<SalesOrderCubit>(
          create: (_) => SalesOrderCubit(salesOrderRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Odoo Sales ERP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
