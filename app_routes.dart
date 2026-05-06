import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/profile/profile_screen.dart'; // ✅ MUST BE HERE

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/', name: 'home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/admin', name: 'admin', builder: (context, state) => const AdminDashboard()),
      GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen()), // ✅ Fixed route
    ],
  );
}