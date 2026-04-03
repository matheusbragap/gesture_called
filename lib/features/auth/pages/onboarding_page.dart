import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../admin/data/company_requests_repository.dart';
import '../../admin/models/company_model.dart';
import '../../../core/services/supabase_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF131C27),
              const Color(0xFF1A2735),
              const Color(0xFF243647),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Elementos decorativos
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3F5F7F).withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Ícone animado
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 600),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF3F5F7F),
                                        Color(0xFF6B879E),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF3F5F7F)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.business_center,
                                      size: 45,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Bem-vindo, ${user?.name ?? 'usuário'}!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Escolha como você quer começar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Opção 1: Criar Empresa
                          _OptionCard(
                            icon: Icons.add_business_outlined,
                            title: 'Criar uma empresa',
                            subtitle:
                                'Você será o administrador e poderá adicionar usuários',
                            onTap: () => context.go('/company'),
                          ),
                          const SizedBox(height: 16),

                          // Opção 2: Entrar em Empresa
                          _OptionCard(
                            icon: Icons.people_outline,
                            title: 'Entrar em uma empresa',
                            subtitle:
                                'Solicite acesso a uma empresa existente',
                            onTap: () => _showRequestAccessDialog(context),
                          ),

                          const SizedBox(height: 48),

                          // Logout
                          TextButton.icon(
                            onPressed: () async {
                              await context.read<AuthProvider>().logout();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Sair'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 139, 92, 246),
                Color.fromARGB(255, 99, 102, 241),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F5F7F).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
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
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
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
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.7),
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

