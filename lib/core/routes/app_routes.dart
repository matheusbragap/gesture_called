import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_email_page.dart';
import '../../features/auth/pages/register_details_page.dart';

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
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home'))),
      ),
    ],
  );
}
