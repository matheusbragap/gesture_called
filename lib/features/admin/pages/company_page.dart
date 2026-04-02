import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/admin_guard.dart';
import '../../../core/widgets/ui/servflow_admin_shell.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/company_repository.dart';
import '../models/company_model.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repo = CompanyRepository();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Empresa criada com sucesso!'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      context.go('/home');
    } catch (e) {
      setState(() => _error = 'Não foi possível criar a empresa. Tente novamente.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          final hasCompany = user?.companyId != null;

          return ServflowAdminShell(
            title: 'Empresa',
            subtitle:
                hasCompany ? 'Sua organização' : 'Configure para começar',
            userName: user?.name ?? 'Administrador',
            currentRoute: '/company',
            body: hasCompany
                ? _ExistingCompany(
                    companyId: user!.companyId!,
                    repo: _repo,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Inicie sua empresa',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'O administrador cria a empresa e, em seguida, pode cadastrar departamentos (lojas) '
                          'e alocar funcionários. Você só pode estar vinculado a uma empresa.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome da empresa',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _submitting ? null : _create,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Criar empresa'),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _ExistingCompany extends StatefulWidget {
  const _ExistingCompany({
    required this.companyId,
    required this.repo,
  });

  final int companyId;
  final CompanyRepository repo;

  @override
  State<_ExistingCompany> createState() => _ExistingCompanyState();
}

class _ExistingCompanyState extends State<_ExistingCompany> {
  late Future<CompanyModel?> _companyFuture;

  @override
  void initState() {
    super.initState();
    _companyFuture = widget.repo.getCompanyById(widget.companyId);
  }

  void _reloadCompany() {
    setState(() {
      _companyFuture = widget.repo.getCompanyById(widget.companyId);
    });
  }

  Future<void> _edit(
    BuildContext context,
    CompanyModel company,
    AuthProvider auth,
  ) async {
    final nameController = TextEditingController(text: company.name);
    final descController = TextEditingController(text: company.description ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar empresa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
      await widget.repo.updateCompany(
        id: company.id,
        name: name,
        description: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
      );
      await auth.refreshUser();
      if (context.mounted) {
        _reloadCompany();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Empresa atualizada.'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Não foi possível salvar.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, AuthProvider auth) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir empresa'),
        content: const Text(
          'Isso remove chamados, mensagens e lojas vinculados a esta empresa e '
          'desvincula todos os usuários. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    try {
      await widget.repo.deleteCompanyCascade(widget.companyId);
      await auth.refreshUser();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Empresa excluída.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      context.go('/company');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Não foi possível excluir. Verifique dependências no banco ou políticas RLS.',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _companyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final company = snapshot.data;
        if (company == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Empresa não encontrada. Atualize o perfil ou entre em contato com o suporte.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          );
        }

        return Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF8B5CF6),
                    child: Icon(Icons.business, color: Colors.white),
                  ),
                  title: Text(
                    company.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: company.description != null &&
                          company.description!.isNotEmpty
                      ? Text(company.description!)
                      : const Text('Sem descrição'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _edit(context, company, auth),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar dados da empresa'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, auth),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    'Excluir empresa',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => context.go('/departments'),
                  icon: const Icon(Icons.store),
                  label: const Text('Lojas (departamentos)'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => context.go('/users'),
                  icon: const Icon(Icons.people),
                  label: const Text('Usuários e cargos'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
