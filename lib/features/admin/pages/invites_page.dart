import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/ui/sf_content_header.dart';
import '../data/invites_repository.dart';
import '../models/invite_model.dart';
import '../../auth/providers/auth_provider.dart';

class InvitesPage extends StatefulWidget {
  const InvitesPage({super.key});

  @override
  State<InvitesPage> createState() => _InvitesPageState();
}

class _InvitesPageState extends State<InvitesPage> {
  final _repo = InvitesRepository();
  Future<List<InviteModel>> _invitesFuture = Future.value([]);
  final Map<int, String> _companyNameCache = {};

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  void _loadInvites() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _invitesFuture = _repo.getPendingInvitesForUser(user.email);
      return;
    }

    _invitesFuture = Future.value([]);
  }

  Future<void> _handleAccept(int inviteId) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    final isAdmin = user.role == 'admin';
    if (isAdmin && user.companyId != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Você precisa sair da empresa atual antes de aceitar este convite.',
          ),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    try {
      await _repo.acceptInvite(
        inviteId: inviteId,
        userId: user.id,
        userEmail: user.email,
      );

      await authProvider.refreshUser();

      if (!mounted) return;
      setState(() => _loadInvites());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Convite aceito! Bem-vindo à empresa.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao aceitar convite. Tente novamente.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _handleReject(int inviteId) async {
    try {
      await _repo.rejectInvite(inviteId);
      if (!mounted) return;
      setState(() => _loadInvites());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Convite rejeitado.'),
          backgroundColor: Colors.grey.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao rejeitar convite.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SfContentHeader(
            title: 'Convites',
            subtitle: 'Convites pendentes para entrar em empresas.',
            variant: SfContentHeaderVariant.standard,
            actions: [
              IconButton.filledTonal(
                tooltip: 'Atualizar convites',
                onPressed: () => setState(_loadInvites),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<InviteModel>>(
              future: _invitesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final invites = snapshot.data ?? [];

                if (invites.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum convite pendente',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: invites.length,
                  itemBuilder: (context, index) {
                    final invite = invites[index];
                    final isAdminWithCompany =
                        user?.role == 'admin' && user?.companyId != null;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Convite para Empresa',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.business, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FutureBuilder<String>(
                                    future: _getCompanyName(invite.companyId),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? 'Carregando...',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.badge, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Cargo: ${_getRoleLabel(invite.role)}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (isAdminWithCompany)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Saia da sua empresa atual para aceitar.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _handleReject(invite.id),
                                    child: const Text('Rejeitar'),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    onPressed: () => _handleAccept(invite.id),
                                    child: const Text('Aceitar'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getCompanyName(int companyId) async {
    final cached = _companyNameCache[companyId];
    if (cached != null) return cached;

    try {
      final name = await _repo.getCompanyNameById(companyId);
      _companyNameCache[companyId] = name;
      return name;
    } catch (_) {
      return 'Empresa #$companyId';
    }
  }

  String _getRoleLabel(String role) {
    final labels = {
      'admin': 'Administrador',
      'attendant': 'Atendente',
      'employee': 'Funcionário',
      'iddle': 'Não definido',
    };
    return labels[role] ?? role;
  }
}
