import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/user_roles.dart';
import '../../admin/data/company_requests_repository.dart';
import '../../admin/models/company_model.dart';
import '../../../core/services/supabase_service.dart';

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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha como você quer começar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          _IddleOptionCard(
            icon: Icons.add_business_outlined,
            title: 'Criar uma empresa',
            subtitle: 'Você será o administrador e poderá adicionar usuários',
            onTap: () => context.go('/company'),
          ),
          const SizedBox(height: 16),
          _IddleOptionCard(
            icon: Icons.people_outline,
            title: 'Entrar em uma empresa',
            subtitle: 'Solicite acesso a uma empresa existente',
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _DashboardCard(
                icon: Icons.business,
                title: 'Empresa',
                onTap: () => context.go('/company'),
              ),
              _DashboardCard(
                icon: Icons.store,
                title: 'Lojas',
                onTap: () => context.go('/departments'),
              ),
              _DashboardCard(
                icon: Icons.category,
                title: 'Categorias',
                onTap: () => context.go('/categories'),
              ),
              _DashboardCard(
                icon: Icons.people,
                title: 'Usuários',
                onTap: () => context.go('/users'),
              ),
              _DashboardCard(
                icon: Icons.assignment,
                title: 'Chamados',
                onTap: () => context.go('/tickets'),
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

  void _showRequestAccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RequestAccessDialog(),
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
              colors: [
                Color(0xFF3F5F7F),
                Color(0xFF6B879E),
              ],
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

class _RequestAccessDialog extends StatefulWidget {
  const _RequestAccessDialog();

  @override
  State<_RequestAccessDialog> createState() => _RequestAccessDialogState();
}

class _RequestAccessDialogState extends State<_RequestAccessDialog> {
  final _repo = CompanyRequestsRepository();
  late Future<List<CompanyModel>> _companiesFuture;
  CompanyModel? _selectedCompany;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _companiesFuture = _fetchCompanies();
  }

  Future<List<CompanyModel>> _fetchCompanies() async {
    final data = await SupabaseService.client
        .from('companies')
        .select()
        .eq('isActive', true)
        .order('name', ascending: true);

    return (data as List).map((e) => CompanyModel.fromMap(e)).toList();
  }

  Future<void> _submitRequest() async {
    if (_selectedCompany == null) {
      setState(() => _error = 'Selecione uma empresa');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _repo.createRequest(
        userId: user.id,
        companyId: _selectedCompany!.id,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Requisição enviada! Aguarde aprovação do administrador.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      setState(() => _error = 'Erro ao enviar requisição. Tente novamente.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Entrar em uma empresa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecione a empresa que você deseja participar:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<CompanyModel>>(
              future: _companiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final companies = snapshot.data ?? [];

                if (companies.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Nenhuma empresa disponível no momento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return DropdownButton<CompanyModel>(
                  isExpanded: true,
                  hint: const Text('Selecione uma empresa'),
                  value: _selectedCompany,
                  items: companies
                      .map((company) => DropdownMenuItem(
                            value: company,
                            child: Text(company.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCompany = value);
                  },
                );
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submitRequest,
          child: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Solicitar'),
        ),
      ],
    );
  }
}
