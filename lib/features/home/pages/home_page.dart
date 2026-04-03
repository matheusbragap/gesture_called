import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/theme/app_colors.dart';
import '../../admin/data/company_repository.dart';
import '../../admin/data/company_requests_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return _buildMainContent(context, user);
  }

  Widget _buildIddleContent(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bem-vindo, ${user?.name ?? 'usuário'}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha como você quer começar',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          _IddleOptionCard(
            icon: Icons.add_business_outlined,
            title: 'Criar uma empresa',
            subtitle: 'Você será o administrador e poderá adicionar usuários',
            onTap: () => _showCreateCompanyDialog(context),
          ),
          const SizedBox(height: 16),
          _IddleOptionCard(
            icon: Icons.people_outline,
            title: 'Entrar em uma empresa',
            subtitle: 'Solicite acesso por código da empresa',
            onTap: () => _showRequestAccessDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, dynamic user) {
    if (user?.role == UserRoles.iddle) {
      return _buildIddleContent(context);
    } else if (user?.role == UserRoles.admin) {
      return _buildAdminDashboard(context, user);
    } else if (user?.role == UserRoles.attendant) {
      return _buildAttendantDashboard(context, user);
    } else if (user?.role == UserRoles.employee) {
      return _buildEmployeeDashboard(context, user);
    }

    return const Center(child: Text('Role não reconhecido'));
  }

  Widget _buildAdminDashboard(BuildContext context, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, ${user?.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            'Dashboard do Administrador',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _DashboardCard(
                icon: Icons.assignment,
                title: 'Chamados',
                onTap: () => context.go('/tickets'),
              ),
              _DashboardCard(
                icon: Icons.badge_outlined,
                title: 'Meus atendimentos',
                onTap: () => context.go('/my-attendances'),
              ),
              _DashboardCard(
                icon: Icons.store,
                title: 'Departamentos',
                onTap: () => context.go('/departments'),
              ),
              _DashboardCard(
                icon: Icons.category,
                title: 'Categorias',
                onTap: () => context.go('/categories'),
              ),
              _DashboardCard(
                icon: Icons.people,
                title: 'Funcionários',
                onTap: () => context.go('/users'),
              ),
              _DashboardCard(
                icon: Icons.business,
                title: 'Empresa',
                onTap: () => context.go('/company'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendantDashboard(BuildContext context, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, ${user?.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Chamados'),
            subtitle: const Text('Gerenciar e responder chamados'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.go('/tickets'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDashboard(BuildContext context, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, ${user?.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Meus Chamados'),
            subtitle: const Text('Abrir e gerenciar seus chamados'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.go('/tickets'),
          ),
        ],
      ),
    );
  }

  void _showCreateCompanyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateCompanyDialog(),
    );
  }

  void _showRequestAccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _JoinCompanyByCodeDialog(),
    );
  }
}

class _IddleOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _IddleOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3F5F7F), Color(0xFF6B879E)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F5F7F).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
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
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF3F5F7F)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JoinCompanyByCodeDialog extends StatefulWidget {
  const _JoinCompanyByCodeDialog();

  @override
  State<_JoinCompanyByCodeDialog> createState() =>
      _JoinCompanyByCodeDialogState();
}

class _JoinCompanyByCodeDialogState extends State<_JoinCompanyByCodeDialog> {
  final _repo = CompanyRequestsRepository();
  final _codeController = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Informe o código da empresa.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final cooldown = await _repo.getInviteCooldownRemaining(userId: user.id);
      if (cooldown > Duration.zero) {
        final seconds = (cooldown.inMilliseconds / 1000).ceil();
        setState(() {
          _error = 'Aguarde $seconds segundo(s) para enviar um novo convite.';
        });
        return;
      }

      final companyId = await _repo.findActiveCompanyIdByCode(code);
      if (companyId == null) {
        setState(() {
          _error = 'Código da empresa inválido ou empresa inativa.';
        });
        return;
      }

      await _repo.createOrReplaceRequest(userId: user.id, companyId: companyId);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Convite enviado! Aguarde a aprovação do administrador da empresa.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível enviar o convite. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.seed.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.group_add_outlined,
                    color: AppColors.seed,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Entrar em uma empresa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Digite o código da empresa para enviar seu convite de acesso.',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _codeController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!_submitting) _submitRequest();
              },
              decoration: const InputDecoration(
                labelText: 'Código da empresa',
                hintText: 'Ex.: 123',
                prefixIcon: Icon(Icons.key_outlined),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submitRequest,
                    child: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enviar convite'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCompanyDialog extends StatefulWidget {
  const _CreateCompanyDialog();

  @override
  State<_CreateCompanyDialog> createState() => _CreateCompanyDialogState();
}

class _CreateCompanyDialogState extends State<_CreateCompanyDialog> {
  final _repo = CompanyRepository();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Informe o nome da empresa.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _repo.createCompany(
        name: name,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        adminUserId: user.id,
      );
      await auth.refreshUser();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empresa criada com sucesso!')),
      );
      context.go('/home');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível criar a empresa. Tente novamente.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.seed.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_business_outlined,
                    color: AppColors.seed,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Criar empresa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nome da empresa',
                prefixIcon: Icon(Icons.business_center_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submitCreate,
                    child: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Criar empresa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
