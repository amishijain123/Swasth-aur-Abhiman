import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/medical/presentation/screens/medical_screen.dart';
import '../../features/education/presentation/screens/education_screen.dart';
import '../../features/skills/presentation/screens/skills_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/trainer/presentation/screens/trainer_dashboard_screen.dart';

// Listenable for router refresh
class AuthNotifierListenable extends ChangeNotifier {
  AuthNotifierListenable(this._ref) {
    _ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

final _routerRefreshListenableProvider = Provider<AuthNotifierListenable>((ref) {
  return AuthNotifierListenable(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(_routerRefreshListenableProvider);
  
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';

      // If not logged in and trying to access protected routes, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      
      // If logged in and on auth screens, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/medical',
        builder: (context, state) => const MedicalScreen(),
      ),
      GoRoute(
        path: '/education',
        builder: (context, state) => const EducationScreen(),
      ),
      GoRoute(
        path: '/skills',
        builder: (context, state) => const SkillsScreen(),
      ),
      GoRoute(
        path: '/nutrition',
        builder: (context, state) => const NutritionScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: '/trainer',
        builder: (context, state) => const TrainerDashboardScreen(),
      ),
    ],
  );
});
