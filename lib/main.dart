import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/network/dio_client.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/vendor_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/vendor_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Gracefully initialize Firebase Cloud Messaging (will catch and proceed if credentials or config files are missing)
  await NotificationService.instance.initialize();

  // Initialize Storage Service (SharedPreferences)
  final storageService = await StorageService.getInstance();

  // Core Dio network Client
  final dioClient = DioClient();

  // Repository Implementations
  final authRepository = AuthRepositoryImpl(dioClient, storageService);
  final vendorRepository = VendorRepositoryImpl(dioClient);
  final orderRepository = OrderRepositoryImpl(dioClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorProvider(vendorRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderRepository),
        ),
      ],
      child: const FreshMandiApp(),
    ),
  );
}

class FreshMandiApp extends StatelessWidget {
  const FreshMandiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshMandi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
