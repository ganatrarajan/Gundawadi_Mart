import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_provider.dart';
import 'features/home/home_screen.dart';
import 'features/cart/cart_provider.dart';
import 'features/checkout/address_provider.dart';
import 'features/orders/order_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GundawadiMartCustomerApp());
}

class GundawadiMartCustomerApp extends StatefulWidget {
  const GundawadiMartCustomerApp({super.key});

  @override
  State<GundawadiMartCustomerApp> createState() => _GundawadiMartCustomerAppState();
}

class _GundawadiMartCustomerAppState extends State<GundawadiMartCustomerApp> {
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
        ChangeNotifierProvider(create: (_) => HomeProvider(_apiClient)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider(_apiClient)),
        ChangeNotifierProvider(create: (_) => OrderProvider(_apiClient)),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Gundawadi Mart',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/login': (_) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
