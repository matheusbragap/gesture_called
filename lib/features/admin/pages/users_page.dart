import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/widgets/admin_guard.dart';
import '../../../core/widgets/ui/servflow_admin_shell.dart';
import '../../../core/widgets/ui/sf_glass_card.dart';
import '../../../core/widgets/ui/sf_list_tile_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/admin_users_repository.dart';
import '../data/departments_repository.dart';
import '../widgets/no_company_banner.dart';
import '../widgets/role_labels.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _repo = AdminUsersRepository();
  final _deptRepo = DepartmentsRepository();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _departments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final cid = auth.user?.companyId;
    if (cid == null) {
      setState(() {
        _loading = false;
        _users = [];
        _departments = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _repo.listAllInCompany(cid),
        _deptRepo.listByCompany(cid),
      ]);
      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(results[0]);
          _departments = List<Map<String, dynamic>>.from(results[1]);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar usuários.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _openAllocateExisting() async {
    final auth = context.read<AuthProvider>();
    final cid = auth.user?.companyId;
    if (cid == null) return;

    final emailController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular funcionário existente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informe o e-mail de um usuário com perfil de funcionário que ainda não esteja em uma empresa.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vincular'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Informe o e-mail.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    try {
      await _repo.allocateEmployeeByEmail(email: email, companyId: cid);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Usuário vinculado à empresa.'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final display =
          msg.startsWith('Exception: ') ? msg.substring(11) : msg;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(display),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _openCreateUser() async {
    final auth = context.read<AuthProvider>();
    final cid = auth.user?.companyId;
    if (cid == null) return;

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();
    String role = UserRoles.employee;
    int? departmentId;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text('Novo usuário'),
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
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha inicial',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(role),
                    initialValue: role,
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UserRoles.employee,
                        child: Text('Funcionário'),
                      ),
                      DropdownMenuItem(
                        value: UserRoles.attendant,
                        child: Text('Atendente'),
                      ),
                      DropdownMenuItem(
                        value: UserRoles.admin,
                        child: Text('Administrador'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setLocal(() => role = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    key: ValueKey(departmentId),
                    initialValue: departmentId,
                    decoration: const InputDecoration(
                      labelText: 'Loja (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Nenhuma'),
                      ),
                      ..._departments.map(
                        (d) => DropdownMenuItem<int?>(
                          value: (d['id'] as num).toInt(),
                          child: Text(d['name'] as String),
                        ),
                      ),
                    ],
                    onChanged: (v) => setLocal(() => departmentId = v),
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
                child: const Text('Criar'),
              ),
            ],
          );
        },
      ),
    );

    if (ok != true || !mounted) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passController.text.trim();
    if (name.isEmpty || email.isEmpty || pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            pass.length < 6
                ? 'Senha deve ter pelo menos 6 caracteres.'
                : 'Preencha nome e e-mail.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    try {
      await _repo.createUserInCompany(
        name: name,
        email: email,
        password: pass,
        role: role,
        companyId: cid,
        departmentId: departmentId,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Usuário criado e vinculado à empresa.'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final display =
          msg.startsWith('Exception: ') ? msg.substring(11) : msg;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(display),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          final hasCompany = user?.companyId != null;

          final cs = Theme.of(context).colorScheme;

          return ServflowAdminShell(
            title: 'Equipe',
            subtitle: 'Usuários, cargos e lojas',
            userName: user?.name ?? 'Administrador',
            currentRoute: '/users',
            actions: [
              if (hasCompany)
                IconButton(
                  tooltip: 'Vincular existente',
                  icon: const Icon(Icons.link_rounded),
                  onPressed: _openAllocateExisting,
                ),
            ],
            floatingActionButton: hasCompany
                ? FloatingActionButton.extended(
                    onPressed: _openCreateUser,
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Novo usuário'),
                  )
                : null,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasCompany) const NoCompanyBanner(),
                  if (hasCompany)
                    SfInfoCard(
                      icon: Icons.groups_rounded,
                      tint: cs.secondary,
                      child: Text(
                        'Crie usuários já na empresa, edite cargos e loja, ou remova o '
                        'acesso à organização.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ),
                  if (hasCompany) const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: cs.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Expanded(
                    child: !hasCompany
                        ? const SizedBox.shrink()
                        : _loading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: cs.primary,
                                ),
                              )
                            : _users.isEmpty
                                ? Center(
                                    child: Text(
                                      'Nenhum usuário na empresa.',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 100),
                                    itemCount: _users.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, i) {
                                      final row = _users[i];
                                      final dept = _departmentName(row);
                                      final sub = [
                                        row['email'] as String,
                                        if (dept != null) 'Loja: $dept',
                                      ].join('\n');

                                      final nameStr = row['name'] as String;
                                      final initial = nameStr.isNotEmpty
                                          ? nameStr[0].toUpperCase()
                                          : '?';

                                      return SfListTileCard(
                                        title: nameStr,
                                        subtitle: sub,
                                        onTap: () => _editUserDialog(row, auth),
                                        leading: CircleAvatar(
                                          backgroundColor: cs
                                              .secondaryContainer
                                              .withValues(alpha: 0.9),
                                          foregroundColor: cs.secondary,
                                          child: Text(
                                            initial,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        trailing: Chip(
                                          label: Text(
                                            roleLabelPt(
                                              row['role'] as String,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          visualDensity:
                                              VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _departmentName(Map<String, dynamic> row) {
    final d = row['departments'];
    if (d is Map) return d['name'] as String?;
    return null;
  }

  Future<void> _editUserDialog(
    Map<String, dynamic> row,
    AuthProvider auth,
  ) async {
    final cid = auth.user?.companyId;
    if (cid == null) return;

    final userId = row['id'] as String;
    final selfId = auth.user?.id;
    var role = row['role'] as String;
    int? departmentId = row['department_id'] != null
        ? (row['department_id'] as num).toInt()
        : null;
    var isActive = row['isActive'] as bool;

    final result = await showDialog<Object>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: Text('Editar ${row['name']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    row['email'] as String,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(role),
                    initialValue: role,
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UserRoles.employee,
                        child: Text('Funcionário'),
                      ),
                      DropdownMenuItem(
                        value: UserRoles.attendant,
                        child: Text('Atendente'),
                      ),
                      DropdownMenuItem(
                        value: UserRoles.admin,
                        child: Text('Administrador'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setLocal(() => role = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    key: ValueKey(departmentId),
                    initialValue: departmentId,
                    decoration: const InputDecoration(
                      labelText: 'Loja',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Nenhuma'),
                      ),
                      ..._departments.map(
                        (d) => DropdownMenuItem<int?>(
                          value: (d['id'] as num).toInt(),
                          child: Text(d['name'] as String),
                        ),
                      ),
                    ],
                    onChanged: (v) => setLocal(() => departmentId = v),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ativo'),
                    value: isActive,
                    onChanged: (v) => setLocal(() => isActive = v),
                  ),
                ],
              ),
            ),
            actions: [
              if (selfId != userId)
                TextButton(
                  onPressed: () => Navigator.pop(context, 'remove'),
                  child: Text(
                    'Remover da empresa',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );

    if (!mounted || result == null || result == false) return;

    if (result == 'remove') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remover da empresa'),
          content: const Text(
            'O usuário perde acesso a esta empresa, mas a conta continua existindo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover'),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
      try {
        await _repo.removeUserFromCompany(userId);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Usuário removido da empresa.'),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erro ao remover.'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
      return;
    }

    if (result != true) return;

    try {
      await _repo.updateUser(
        userId: userId,
        role: role,
        departmentId: departmentId,
        isActive: isActive,
      );
      if (userId == selfId) await auth.refreshUser();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Usuário atualizado.'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao atualizar.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
