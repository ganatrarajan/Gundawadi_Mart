import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/products/products_provider.dart';
import 'features/orders/orders_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GundawadiMartVendorApp());
}

class GundawadiMartVendorApp extends StatefulWidget {
  const GundawadiMartVendorApp({super.key});

  @override
  State<GundawadiMartVendorApp> createState() => _GundawadiMartVendorAppState();
}

class _GundawadiMartVendorAppState extends State<GundawadiMartVendorApp> {
  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(_apiClient)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(_apiClient)),
        ChangeNotifierProvider(create: (_) => ProductsProvider(_apiClient)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(_apiClient)),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Gundawadi Mart - Vendor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: auth.isAuthenticated ? const DashboardScreen() : const LoginScreen(),
            routes: {
              '/dashboard': (_) => const DashboardScreen(),
              '/login': (_) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
