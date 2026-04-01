import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/admin_guard.dart';
import '../../../core/widgets/ui/servflow_admin_shell.dart';
import '../../../core/widgets/ui/sf_dialogs.dart';
import '../../../core/widgets/ui/sf_glass_card.dart';
import '../../../core/widgets/ui/sf_list_tile_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/departments_repository.dart';
import '../widgets/no_company_banner.dart';

class DepartmentsPage extends StatefulWidget {
  const DepartmentsPage({super.key});

  @override
  State<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {
  final _repo = DepartmentsRepository();
  List<Map<String, dynamic>> _items = [];
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
        _items = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repo.listByCompany(cid);
      if (mounted) {
        setState(() {
          _items = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar lojas.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final auth = context.read<AuthProvider>();
    final cid = auth.user?.companyId;
    if (cid == null) return;

    final nameController =
        TextEditingController(text: existing?['name'] as String? ?? '');
    final descController =
        TextEditingController(text: existing?['description'] as String? ?? '');
    final locController =
        TextEditingController(text: existing?['location'] as String? ?? '');
    final isEdit = existing != null;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Editar loja' : 'Nova loja'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex.: Loja Centro',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locController,
                decoration: const InputDecoration(
                  labelText: 'Localização',
                  hintText: 'Cidade, bairro…',
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
            child: Text(isEdit ? 'Salvar' : 'Criar'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      _snack('Nome é obrigatório.', error: true);
      return;
    }

    try {
      if (isEdit) {
        await _repo.update(
          id: (existing['id'] as num).toInt(),
          name: name,
          description: descController.text.trim().isEmpty
              ? null
              : descController.text.trim(),
          location: locController.text.trim().isEmpty
              ? null
              : locController.text.trim(),
        );
      } else {
        await _repo.create(
          companyId: cid,
          name: name,
          description: descController.text.trim().isEmpty
              ? null
              : descController.text.trim(),
          location: locController.text.trim().isEmpty
              ? null
              : locController.text.trim(),
        );
      }
      await _load();
      if (mounted) {
        _snack(isEdit ? 'Loja atualizada.' : 'Loja criada.');
      }
    } catch (e) {
      if (mounted) _snack('Não foi possível salvar.', error: true);
    }
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    final id = (row['id'] as num).toInt();
    final name = row['name'] as String;

    final confirm = await sfConfirmDelete(
      context,
      title: 'Excluir loja',
      message:
          'Isso removerá permanentemente chamados e mensagens desta loja e '
          'desvinculará usuários desta loja. Loja: "$name".',
    );
    if (!confirm || !mounted) return;

    try {
      await _repo.deleteCascade(id);
      await _load();
      if (mounted) _snack('Loja excluída.');
    } catch (e) {
      if (mounted) {
        _snack('Não foi possível excluir. Verifique dependências ou RLS.',
            error: true);
      }
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> row) async {
    final id = (row['id'] as num).toInt();
    final active = row['isActive'] as bool;
    try {
      await _repo.setActive(id, !active);
      await _load();
    } catch (e) {
      if (mounted) _snack('Erro ao atualizar status.', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AdminGuard(
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          final hasCompany = user?.companyId != null;

          return ServflowAdminShell(
            title: 'Lojas',
            subtitle: 'Departamentos da sua empresa',
            userName: user?.name ?? 'Administrador',
            currentRoute: '/departments',
            floatingActionButton: hasCompany
                ? FloatingActionButton.extended(
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add_business_rounded),
                    label: const Text('Nova loja'),
                  )
                : null,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasCompany) const NoCompanyBanner(),
                  if (hasCompany) ...[
                    SfInfoCard(
                      icon: Icons.storefront_rounded,
                      tint: cs.tertiary,
                      child: Text(
                        'Gerencie todas as lojas físicas ou unidades. Chamados e '
                        'equipe podem ser vinculados a cada loja.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
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
                            : _items.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.store_mall_directory_outlined,
                                          size: 56,
                                          color: cs.outline,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Nenhuma loja cadastrada',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 100),
                                    itemCount: _items.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, i) {
                                      final row = _items[i];
                                      final active =
                                          row['isActive'] as bool;
                                      final name =
                                          row['name'] as String;
                                      final loc = row['location'] as String?;
                                      final desc =
                                          row['description'] as String?;
                                      final sub = [
                                        if (loc != null && loc.isNotEmpty) loc,
                                        if (desc != null && desc.isNotEmpty)
                                          desc,
                                      ].join(' · ');

                                      return SfListTileCard(
                                        title: name,
                                        subtitle:
                                            sub.isEmpty ? null : sub,
                                        leading: CircleAvatar(
                                          backgroundColor: cs
                                              .tertiaryContainer
                                              .withValues(alpha: 0.95),
                                          foregroundColor: cs.tertiary,
                                          child: Icon(
                                            active
                                                ? Icons.store_rounded
                                                : Icons.store_outlined,
                                            size: 20,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Switch.adaptive(
                                              value: active,
                                              onChanged: (_) =>
                                                  _toggleActive(row),
                                            ),
                                            PopupMenuButton<String>(
                                              child: Icon(
                                                Icons.more_vert_rounded,
                                                color: cs.onSurfaceVariant,
                                              ),
                                              onSelected: (v) {
                                                if (v == 'edit') {
                                                  _openForm(existing: row);
                                                }
                                                if (v == 'delete') {
                                                  _delete(row);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Text('Editar'),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Text(
                                                    'Excluir',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
}
