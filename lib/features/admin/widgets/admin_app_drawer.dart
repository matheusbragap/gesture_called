import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';

class AdminAppDrawer extends StatelessWidget {
  const AdminAppDrawer({
    super.key,
    required this.userName,
    required this.currentRoute,
  });

  final String userName;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary,
              Color.lerp(cs.primary, cs.tertiary, 0.35)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Administrador',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 16,
                    ),
                    children: [
                      _NavTile(
                        icon: Icons.home_outlined,
                        label: 'Início',
                        route: '/home',
                        currentRoute: currentRoute,
                        primary: cs.primary,
                      ),
                      _NavTile(
                        icon: Icons.business_rounded,
                        label: 'Empresa',
                        route: '/company',
                        currentRoute: currentRoute,
                        primary: cs.primary,
                      ),
                      _NavTile(
                        icon: Icons.assignment_rounded,
                        label: 'Chamados',
                        route: '/tickets',
                        currentRoute: currentRoute,
                        primary: cs.primary,
                      ),
                      _NavTile(
                        icon: Icons.storefront_rounded,
                        label: 'Lojas',
                        route: '/departments',
                        currentRoute: currentRoute,
                        primary: cs.primary,
                      ),
                      _NavTile(
                        icon: Icons.category_rounded,
                        label: 'Categorias',
                        route: '/categories',
                        currentRoute: currentRoute,
                        primary: cs.primary,
                      ),
                      _NavTile(
                        icon: Icons.groups_rounded,
                        label: 'Usuários',
                        route: '/users',
                        currentRoute: currentRoute,
                        primary: cs.primary,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(Icons.logout_rounded, color: cs.error),
                  title: Text(
                    'Sair',
                    style: TextStyle(
                      color: cs.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    context.read<AuthProvider>().logout();
                    context.go('/login');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.primary,
  });

  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final active = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Icon(
            icon,
            color: active ? primary : Colors.grey.shade700,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? primary : Colors.grey.shade800,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            context.go(route);
          },
        ),
      ),
    );
  }
}
