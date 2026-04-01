import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Garante que apenas usuários com role `admin` vejam [child]; caso contrário redireciona para `/tickets`.
class AdminGuard extends StatefulWidget {
  const AdminGuard({super.key, required this.child});

  final Widget child;

  @override
  State<AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfNeeded());
  }

  void _redirectIfNeeded() {
    final user = context.read<AuthProvider>().user;
    if (!mounted) return;
    if (user?.role != 'admin') {
      context.go('/tickets');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user?.role != 'admin') {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
