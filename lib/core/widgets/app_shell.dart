import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../constants/user_roles.dart';

enum _ProfileMenuAction { account, logout }

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('ServFlow'),
        actions: [
          PopupMenuButton<_ProfileMenuAction>(
            tooltip: 'Perfil',
            onSelected: _handleProfileMenuSelection,
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person_outline,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem<_ProfileMenuAction>(
                value: _ProfileMenuAction.account,
                child: Row(
                  children: [
                    Icon(Icons.manage_accounts_outlined),
                    SizedBox(width: 8),
                    Text('Conta'),
                  ],
                ),
              ),
              PopupMenuItem<_ProfileMenuAction>(
                value: _ProfileMenuAction.logout,
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context, user),
      body: widget.child,
    );
  }

  Widget _buildDrawer(BuildContext context, dynamic user) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text(user?.name ?? 'Usuário')),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Convites'),
            onTap: () {
              Navigator.pop(context);
              context.go('/invites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          if (user?.role == UserRoles.admin) ...[
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Empresa'),
              onTap: () {
                Navigator.pop(context);
                context.go('/company');
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Lojas (Departamentos)'),
              onTap: () {
                Navigator.pop(context);
                context.go('/departments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categorias'),
              onTap: () {
                Navigator.pop(context);
                context.go('/categories');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Usuários'),
              onTap: () {
                Navigator.pop(context);
                context.go('/users');
              },
            ),
          ],
          if (user != null && user.role != UserRoles.iddle)
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Chamados'),
              onTap: () {
                Navigator.pop(context);
                context.go('/tickets');
              },
            ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              Navigator.pop(context);
              await _handleLogout();
            },
          ),
        ],
      ),
    );
  }
}
