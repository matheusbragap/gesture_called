import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../constants/user_roles.dart';
import '../theme/app_colors.dart';

enum _ProfileMenuAction { account, logout }

class AppShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({super.key, required this.child, required this.currentRoute});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _hoveredRoute;

  Future<void> _handleLogout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _handleProfileMenuSelection(_ProfileMenuAction action) async {
    switch (action) {
      case _ProfileMenuAction.account:
        context.go('/profile');
        break;
      case _ProfileMenuAction.logout:
        await _handleLogout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.ink900,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.ink900, AppColors.ink800],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go('/home'),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'SERVFLOW',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<_ProfileMenuAction>(
            tooltip: 'Perfil',
            onSelected: _handleProfileMenuSelection,
            color: AppColors.surface,
            elevation: 10,
            shadowColor: Colors.black.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.surfaceMuted),
            ),
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0x33FFFFFF),
              child: Icon(Icons.person_outline, size: 18, color: Colors.white),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<_ProfileMenuAction>(
                value: _ProfileMenuAction.account,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.seed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.manage_accounts_outlined,
                        color: AppColors.seed,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Conta',
                      style: TextStyle(
                        color: AppColors.ink900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<_ProfileMenuAction>(
                value: _ProfileMenuAction.logout,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.logout,
                        color: AppColors.danger,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Sair',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, user, widget.currentRoute),
      body: widget.child,
    );
  }

  Widget _buildDrawer(BuildContext context, dynamic user, String currentRoute) {
    final initials = _nameInitials(user?.name as String?);
    final roleLabel = _roleLabel(user?.role as String?);
    final currentPageLabel = _routeLabel(currentRoute);

    return Drawer(
      elevation: 0,
      width: 330,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(26)),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.ink900, AppColors.ink800],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Usuário',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                roleLabel,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.radio_button_checked_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Você está em: $currentPageLabel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    if (user?.role == UserRoles.attendant) ...[
                      _buildDrawerItem(
                        context: context,
                        route: '/home',
                        label: 'Início',
                        icon: Icons.home_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/home');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/tickets',
                        label: 'Chamados',
                        icon: Icons.assignment_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/tickets');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/my-attendances',
                        label: 'Meus atendimentos',
                        icon: Icons.badge_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/my-attendances');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/departments-overview',
                        label: 'Departamentos',
                        icon: Icons.store_mall_directory_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/departments-overview');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/team',
                        label: 'Equipe',
                        icon: Icons.groups_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/team');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/invites',
                        label: 'Meus convites',
                        icon: Icons.mail_outline,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/invites');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/settings',
                        label: 'Configurações',
                        icon: Icons.settings_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/settings');
                        },
                      ),
                    ] else if (user?.role == UserRoles.admin) ...[
                      _buildDrawerItem(
                        context: context,
                        route: '/home',
                        label: 'Início',
                        icon: Icons.home_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/home');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/tickets',
                        label: 'Chamados',
                        icon: Icons.assignment_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/tickets');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/my-attendances',
                        label: 'Meus atendimentos',
                        icon: Icons.badge_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/my-attendances');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/departments',
                        label: 'Departamentos',
                        icon: Icons.store_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/departments');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/categories',
                        label: 'Categorias',
                        icon: Icons.category,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/categories');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/users',
                        label: 'Funcionários',
                        icon: Icons.people,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/users');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/company',
                        label: 'Empresa',
                        icon: Icons.business,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/company');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/invites',
                        label: 'Meus convites',
                        icon: Icons.mail_outline,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/invites');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/settings',
                        label: 'Configurações',
                        icon: Icons.settings_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/settings');
                        },
                      ),
                    ] else ...[
                      _buildDrawerItem(
                        context: context,
                        route: '/home',
                        label: 'Início',
                        icon: Icons.home_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/home');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/invites',
                        label: 'Meus convites',
                        icon: Icons.mail_outline,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/invites');
                        },
                      ),
                      _buildDrawerItem(
                        context: context,
                        route: '/settings',
                        label: 'Configurações',
                        icon: Icons.settings_outlined,
                        currentRoute: currentRoute,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/settings');
                        },
                      ),
                      if (user != null && user.role != UserRoles.iddle)
                        _buildDrawerItem(
                          context: context,
                          route: '/tickets',
                          label: 'Chamados',
                          icon: Icons.assignment,
                          currentRoute: currentRoute,
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/tickets');
                          },
                        ),
                    ],
                    const SizedBox(height: 6),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.14),
                      height: 24,
                    ),
                    _buildDrawerItem(
                      context: context,
                      route: '/logout',
                      label: 'Sair',
                      icon: Icons.logout,
                      currentRoute: currentRoute,
                      destructive: true,
                      onTap: () async {
                        Navigator.pop(context);
                        await _handleLogout();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String route,
    required String label,
    required IconData icon,
    required String currentRoute,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final isActive = _isRouteActive(currentRoute, route);
    final isHovered = _hoveredRoute == route;
    final foreground = destructive
        ? Colors.white.withValues(alpha: 0.86)
        : isActive
        ? Colors.white
        : Colors.white.withValues(alpha: 0.86);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          onHover: (hovering) {
            setState(() {
              _hoveredRoute = hovering ? route : null;
            });
          },
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: destructive
                  ? (isHovered
                        ? AppColors.danger.withValues(alpha: 0.35)
                        : AppColors.danger.withValues(alpha: 0.2))
                  : isActive
                  ? Colors.white.withValues(alpha: 0.2)
                  : isHovered
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: Border.all(
                color: destructive
                    ? AppColors.danger.withValues(alpha: 0.38)
                    : isActive
                    ? Colors.white.withValues(alpha: 0.26)
                    : Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: foreground, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isRouteActive(String currentRoute, String route) {
    if (route == '/logout') return false;
    if (route == '/home') return currentRoute == route;
    return currentRoute == route || currentRoute.startsWith('$route/');
  }

  String _routeLabel(String route) {
    switch (route) {
      case '/home':
        return 'Início';
      case '/invites':
        return 'Meus convites';
      case '/settings':
        return 'Configurações';
      case '/company':
        return 'Empresa';
      case '/departments':
        return 'Departamentos';
      case '/categories':
        return 'Categorias';
      case '/users':
        return 'Funcionários';
      case '/tickets':
        return 'Chamados';
      case '/my-attendances':
        return 'Meus atendimentos';
      case '/departments-overview':
        return 'Departamentos';
      case '/team':
        return 'Equipe';
      case '/profile':
        return 'Conta';
      default:
        return 'Página';
    }
  }

  String _nameInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'US';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  String _roleLabel(String? role) {
    switch (role) {
      case UserRoles.admin:
        return 'Administrador';
      case UserRoles.attendant:
        return 'Atendente';
      case UserRoles.employee:
        return 'Funcionário';
      case UserRoles.iddle:
        return 'Sem empresa';
      default:
        return 'Perfil não definido';
    }
  }
}
