import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/ui/sf_content_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SfContentHeader(
            title: 'Conta',
            subtitle: 'Dados do seu perfil de acesso.',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Nome'),
                    subtitle: Text(user?.name ?? 'Não informado'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('E-mail'),
                    subtitle: Text(user?.email ?? 'Não informado'),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Role'),
                    subtitle: Text(user?.role ?? 'Não informado'),
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
