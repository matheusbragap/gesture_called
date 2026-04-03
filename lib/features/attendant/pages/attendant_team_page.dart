import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/user_roles.dart';
import '../../../core/widgets/ui/sf_content_header.dart';
import '../../../core/widgets/ui/sf_glass_card.dart';
import '../../../core/widgets/ui/sf_list_tile_card.dart';
import '../../admin/data/admin_users_repository.dart';
import '../../admin/widgets/no_company_banner.dart';
import '../../auth/providers/auth_provider.dart';

class AttendantTeamPage extends StatefulWidget {
  const AttendantTeamPage({super.key});

  @override
  State<AttendantTeamPage> createState() => _AttendantTeamPageState();
}

class _AttendantTeamPageState extends State<AttendantTeamPage> {
  final _usersRepo = AdminUsersRepository();

  List<Map<String, dynamic>> _teamMembers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    final companyId = user?.companyId;
    final departmentId = user?.departmentId;
    final isEmployee = user?.role == UserRoles.employee;

    if (companyId == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
        _teamMembers = [];
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await _usersRepo.listAllInCompany(companyId);

      final members = isEmployee
          ? users.where((row) {
              if (departmentId == null) return false;
              final rawDepartmentId = row['department_id'];
              if (rawDepartmentId is! num) return false;
              return rawDepartmentId.toInt() == departmentId;
            }).toList()
          : users.where((row) => row['role'] == UserRoles.attendant).toList();

      if (!mounted) return;
      setState(() {
        _teamMembers = members;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = isEmployee
            ? 'Erro ao carregar equipe do seu departamento.'
            : 'Erro ao carregar equipe de atendentes.';
        _loading = false;
      });
    }
  }

  String? _departmentName(Map<String, dynamic> row) {
    final embed = row['departments'];
    if (embed is Map<String, dynamic>) {
      return embed['name'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;
    final isEmployee = user?.role == UserRoles.employee;
    final hasCompany = user?.companyId != null;
    final hasDepartment = user?.departmentId != null;
    final subtitle = isEmployee
        ? 'Usuários do mesmo departamento que você.'
        : 'Atendentes da sua empresa.';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SfContentHeader(
              title: 'Equipe',
              subtitle: subtitle,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!hasCompany) const NoCompanyBanner(forAdmin: false),
                    if (hasCompany && isEmployee && !hasDepartment)
                      SfInfoCard(
                        icon: Icons.info_outline_rounded,
                        tint: cs.secondary,
                        child: Text(
                          'Você ainda não está vinculado a um departamento. '
                          'Peça para um administrador realizar a vinculação para ver sua equipe.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    if (hasCompany) ...[
                      SfInfoCard(
                        icon: Icons.groups_rounded,
                        tint: cs.secondary,
                        child: Text(
                          isEmployee
                              ? 'Lista de usuários do mesmo departamento '
                                    'que o seu, com seus cargos e status.'
                              : 'Lista da equipe de atendimento da empresa '
                                    'com o departamento associado de cada atendente.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: cs.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Expanded(
                      child: !hasCompany
                          ? const SizedBox.shrink()
                          : isEmployee && !hasDepartment
                          ? const SizedBox.shrink()
                          : _loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: cs.primary,
                                  ),
                                )
                              : _teamMembers.isEmpty
                                  ? Center(
                                      child: Text(
                                        isEmployee
                                            ? 'Nenhum usuário encontrado no seu departamento.'
                                            : 'Nenhum atendente encontrado nesta empresa.',
                                        style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      itemCount: _teamMembers.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final row = _teamMembers[index];
                                        final name = row['name'] as String? ?? 'Usuário';
                                        final email = row['email'] as String?;
                                        final role = row['role'] as String?;
                                        final department = _departmentName(row);
                                        final isActive =
                                            (row['isActive'] as bool?) ?? true;

                                        final subtitleParts = <String>[];
                                        if (email != null && email.isNotEmpty) {
                                          subtitleParts.add(email);
                                        }
                                        final roleLabel = _roleLabel(role);
                                        subtitleParts.add('Cargo: $roleLabel');
                                        if (department != null &&
                                            department.isNotEmpty &&
                                            !isEmployee) {
                                          subtitleParts.add('Loja: $department');
                                        }

                                        final initials = name.trim().isEmpty
                                            ? 'US'
                                            : name.trim()[0].toUpperCase();

                                        return SfListTileCard(
                                          title: name,
                                          subtitle: subtitleParts.isEmpty
                                              ? null
                                              : subtitleParts.join('\n'),
                                          leading: CircleAvatar(
                                            backgroundColor: cs
                                                .secondaryContainer
                                                .withValues(alpha: 0.95),
                                            foregroundColor: cs.secondary,
                                            child: Text(
                                              initials,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          trailing: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 7,
                                                ),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? Colors.green.withValues(
                                                      alpha: 0.16,
                                                    )
                                                  : Colors.orange.withValues(
                                                      alpha: 0.16,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: isActive
                                                    ? Colors.green
                                                        .withValues(
                                                          alpha: 0.32,
                                                        )
                                                    : Colors.orange
                                                        .withValues(
                                                          alpha: 0.32,
                                                        ),
                                              ),
                                            ),
                                            child: Text(
                                              isActive ? 'Ativo' : 'Inativo',
                                              style: TextStyle(
                                                color: isActive
                                                    ? Colors.green.shade800
                                                    : Colors.orange.shade900,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case UserRoles.admin:
        return 'Administrador';
      case UserRoles.attendant:
        return 'Atendente';
      case UserRoles.employee:
        return 'Funcionário';
      case UserRoles.iddle:
        return 'Sem empresa';
      default:
        return 'Não definido';
    }
  }
}
