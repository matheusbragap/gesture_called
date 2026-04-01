import 'package:flutter/material.dart';

import '../../../features/admin/widgets/admin_app_drawer.dart';

/// Layout admin: gradient suave, cabeçalho com menu e área rolável.
class ServflowAdminShell extends StatelessWidget {
  const ServflowAdminShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.userName,
    required this.currentRoute,
    required this.body,
    this.floatingActionButton,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final String userName;
  final String currentRoute;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      drawer: AdminAppDrawer(
        userName: userName,
        currentRoute: currentRoute,
      ),
      floatingActionButton: floatingActionButton,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface,
              cs.primaryContainer.withValues(alpha: 0.35),
              cs.secondaryContainer.withValues(alpha: 0.25),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (ctx) => IconButton(
                        tooltip: 'Menu',
                        style: IconButton.styleFrom(
                          foregroundColor: cs.onSurface,
                        ),
                        icon: const Icon(Icons.menu_rounded, size: 26),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
