import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/ui/sf_content_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sobre o aplicativo'),
          content: const Text(
            'ServFlow\n\nSistema de gerenciamento de chamados para equipes e empresas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SfContentHeader(
            title: 'Configurações',
            subtitle: 'Preferências da conta e do aplicativo.',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Aparência e interface'),
                    subtitle: const Text('Em breve'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notificações'),
                    subtitle: const Text('Em breve'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: const Text('Conta e Segurança'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go('/profile'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('Sobre o aplicativo'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showAboutDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
