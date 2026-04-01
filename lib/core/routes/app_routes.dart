import 'package:go_router/go_router.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_email_page.dart';
import '../../features/auth/pages/register_details_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/admin/pages/company_page.dart';
import '../../features/admin/pages/departments_page.dart';
import '../../features/admin/pages/categories_page.dart';
import '../../features/admin/pages/users_page.dart';
import '../../features/tickets/pages/tickets_page.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/login',
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
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
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
    ],
  );
}
