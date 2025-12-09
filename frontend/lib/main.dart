import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/admin_service.dart';
import 'services/lounge_service.dart';
import 'services/reference_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/lounge_owner/lounge_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final adminService = AdminService(apiClient);
  final loungeService = LoungeService(apiClient);
  final referenceService = ReferenceService(apiClient);

  runApp(CampusEatsApp(
    apiClient: apiClient,
    authService: authService,
    adminService: adminService,
    loungeService: loungeService,
    referenceService: referenceService,
  ));
}

class CampusEatsApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthService authService;
  final AdminService adminService;
  final LoungeService loungeService;
  final ReferenceService referenceService;

  const CampusEatsApp({
    Key? key,
    required this.apiClient,
    required this.authService,
    required this.adminService,
    required this.loungeService,
    required this.referenceService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => LoginScreen(
                authService: authService,
                apiClient: apiClient,
                adminService: adminService,
                loungeService: loungeService,
              ),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => RegisterScreen(
                authService: authService,
                referenceService: referenceService,
                loungeService: loungeService,
              ),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (context) => HomeScreen(
                apiClient: apiClient,
              ),
            );
          case '/admin-dashboard':
            return MaterialPageRoute(
              builder: (context) => AdminDashboardScreen(
                adminService: adminService,
              ),
            );
          case '/lounge-dashboard':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => LoungeDashboardScreen(
                loungeService: loungeService,
                loungeId: args?['loungeId'] ?? '',
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
        }
      },
    );
  }
}

// Splash Screen with navigation logic
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Check if user is logged in
    // For now, navigate to login
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              AppConfig.appName,
              style: AppTheme.heading1.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Ethiopian Universities Food Ordering',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
