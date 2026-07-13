import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/services/shared_prefs_service.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';

// Auth feature
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';

// Dashboard feature
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

// Products feature
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/presentation/providers/product_provider.dart';

// Orders feature
import 'features/orders/domain/repositories/order_repository.dart';
import 'features/orders/data/repositories/order_repository_impl.dart';
import 'features/orders/presentation/providers/order_provider.dart';

// Profile feature
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

// Notifications feature
import 'features/notifications/presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await SharedPrefsService.init();
  await FcmService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate core dependencies
    final dioClient = DioClient();

    // Instantiate repositories
    final authRepository = AuthRepositoryImpl(dioClient);
    final dashboardRepository = DashboardRepositoryImpl(dioClient);
    final productRepository = ProductRepositoryImpl(dioClient);
    final orderRepository = OrderRepositoryImpl(dioClient);
    final profileRepository = ProfileRepositoryImpl(dioClient);

    return MultiProvider(
      providers: [
        // Auth Provider is created first as other providers may depend on it
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository),
        ),
        
        // Secondary providers
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(dashboardRepository),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(productRepository),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(orderRepository),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (ctx) => ProfileProvider(profileRepository, Provider.of<AuthProvider>(ctx, listen: false)),
          update: (_, auth, previous) => previous ?? ProfileProvider(profileRepository, auth),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(dioClient),
        ),
      ],
      child: MaterialApp(
        title: 'Gundawadi Mart Vendor',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Show loading indicator during startup auth check
    if (auth.isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    // Direct routing based on whether a valid session token exists
    if (auth.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
