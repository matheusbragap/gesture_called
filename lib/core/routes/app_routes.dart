import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_email_page.dart';
import '../../features/auth/pages/register_details_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/admin/pages/company_page.dart';
import '../../features/admin/pages/departments_page.dart';
import '../../features/admin/pages/categories_page.dart';
import '../../features/admin/pages/users_page.dart';
import '../../features/admin/pages/invites_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/tickets/pages/tickets_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../widgets/app_shell.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggedIn = auth.isAuthenticated;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation.startsWith('/register/');

      // Se não está logado e não está em página de auth, redireciona para login
      if (!isLoggedIn && !isOnAuthPage) {
        return '/login';
      }

      // Se está logado em página de auth, vai para home
      if (isLoggedIn && isOnAuthPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterEmailPage(),
      ),
      GoRoute(
        path: '/register/details',
        builder: (context, state) =>
            RegisterDetailsPage(email: state.extra as String),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/tickets',
            builder: (context, state) => const TicketsPage(),
          ),
          GoRoute(
            path: '/company',
            builder: (context, state) => const CompanyPage(),
          ),
          GoRoute(
            path: '/departments',
            builder: (context, state) => const DepartmentsPage(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/invites',
            builder: (context, state) => const InvitesPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
