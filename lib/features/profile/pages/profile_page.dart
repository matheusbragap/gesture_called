import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/user_roles.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/data/company_repository.dart';
import '../../admin/data/departments_repository.dart';
import '../../../core/widgets/ui/sf_content_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const int _nameMaxLength = 24;

  final _companyRepository = CompanyRepository();
  final _departmentsRepository = DepartmentsRepository();

  String _companyLabel = 'Não vinculada';
  String _departmentLabel = 'Não vinculado';
  bool _loadingAffiliation = true;
  String? _affiliationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAffiliationInfo());
  }

  Future<void> _loadAffiliationInfo() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _companyLabel = 'Não informado';
        _departmentLabel = 'Não informado';
        _loadingAffiliation = false;
        _affiliationError = null;
      });
      return;
    }

    if (user.companyId == null) {
      if (!mounted) return;
      setState(() {
        _companyLabel = 'Não vinculada';
        _departmentLabel = 'Não vinculado';
        _loadingAffiliation = false;
        _affiliationError = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loadingAffiliation = true;
      _affiliationError = null;
    });

    try {
      final company = await _companyRepository.getCompanyById(user.companyId!);

      String departmentLabel;
      if (user.departmentId == null) {
        departmentLabel = 'Não vinculado';
      } else {
        final departments = await _departmentsRepository.listByCompany(
          user.companyId!,
        );

        Map<String, dynamic>? matchedDepartment;
        for (final department in departments) {
          final rawId = department['id'];
          if (rawId is num && rawId.toInt() == user.departmentId) {
            matchedDepartment = department;
            break;
          }
        }

        final departmentName = matchedDepartment?['name'] as String?;
        if (departmentName == null || departmentName.trim().isEmpty) {
          departmentLabel = 'Departamento #${user.departmentId}';
        } else {
          departmentLabel = departmentName;
        }
      }

      final companyName = company?.name;
      final companyLabel =
          companyName == null || companyName.trim().isEmpty
              ? 'Empresa #${user.companyId}'
              : companyName;

      if (!mounted) return;
      setState(() {
        _companyLabel = companyLabel;
        _departmentLabel = departmentLabel;
        _loadingAffiliation = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _companyLabel = 'Empresa #${user.companyId}';
        _departmentLabel = user.departmentId == null
            ? 'Não vinculado'
            : 'Departamento #${user.departmentId}';
        _loadingAffiliation = false;
        _affiliationError =
            'Não foi possível carregar os dados de empresa/departamento.';
      });
    }
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _roleLabel(String role) {
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
        return role;
    }
  }

  String? _validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Nome é obrigatório.';
    }
    if (name.length > _nameMaxLength) {
      return 'Nome deve ter no máximo $_nameMaxLength caracteres.';
    }
    if (name.startsWith(' ') || name.endsWith(' ')) {
      return 'Nome não pode começar ou terminar com espaço.';
    }
    if (RegExp(r' {2,}').hasMatch(name)) {
      return 'Nome não pode ter dois ou mais espaços seguidos.';
    }
    return null;
  }

  Future<void> _openEditNameDialog() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final controller = TextEditingController(text: user.name);
    String? validationError;

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Alterar nome'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    inputFormatters: const [
                      _ProfileNameFormatter(maxLength: _nameMaxLength),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      hintText: 'Como você quer ser chamado?',
                      errorText: validationError,
                      suffixText:
                          controller.text.isNotEmpty
                              ? '${controller.text.length}/$_nameMaxLength'
                              : null,
                    ),
                    onChanged: (value) {
                      setLocal(() {
                        validationError = _validateName(value);
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final error = _validateName(controller.text);
                    if (error != null) {
                      setLocal(() {
                        validationError = error;
                      });
                      return;
                    }
                    Navigator.pop(dialogContext, controller.text);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (newName == null || !mounted) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfileName(newName);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Nome atualizado com sucesso.'
              : (auth.errorMessage ?? 'Não foi possível atualizar o nome.'),
        ),
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }

  Future<void> _confirmLeaveCompany() async {
    final user = context.read<AuthProvider>().user;
    if (user == null || user.companyId == null) return;

    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var canConfirm = false;

        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Sair da empresa'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Para confirmar, digite "confirmar" abaixo. Esta ação irá '
                    'remover seu vínculo atual de empresa e departamento.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Confirmação',
                      hintText: 'confirmar',
                    ),
                    onChanged: (value) {
                      setLocal(() {
                        canConfirm = value.trim().toLowerCase() == 'confirmar';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: canConfirm
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  child: const Text('Sair da empresa'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (confirmed != true || !mounted) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.leaveCurrentCompany();
    if (!mounted) return;

    if (success) {
      await _loadAffiliationInfo();
      if (!mounted) return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Você saiu da empresa atual.'
              : (auth.errorMessage ?? 'Não foi possível sair da empresa.'),
        ),
        backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final loading = auth.isLoading;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SfContentHeader(
            title: 'Perfil',
            subtitle: 'Dados da sua conta e vínculo atual na empresa.',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Nome'),
                    subtitle: Text(user.name),
                    trailing: IconButton(
                      tooltip: 'Editar nome',
                      onPressed: loading ? null : _openEditNameDialog,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('E-mail'),
                    subtitle: Text(user.email),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Número de telefone'),
                    subtitle: Text(
                      user.phoneNumber == null || user.phoneNumber!.trim().isEmpty
                          ? 'Não informado'
                          : user.phoneNumber!,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.apartment_outlined),
                        title: const Text('Empresa atual'),
                        subtitle: Text(
                          _loadingAffiliation
                              ? 'Carregando...'
                              : _companyLabel,
                        ),
                      ),
                      if (user.companyId != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: loading ? null : _confirmLeaveCompany,
                              icon: const Icon(Icons.exit_to_app_rounded),
                              label: const Text('Sair da empresa'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: const BorderSide(color: AppColors.danger),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.store_mall_directory_outlined),
                    title: const Text('Departamento atual'),
                    subtitle: Text(
                      _loadingAffiliation
                          ? 'Carregando...'
                          : _departmentLabel,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Cargo na empresa'),
                    subtitle: Text(_roleLabel(user.role)),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('Data de criação do perfil'),
                    subtitle: Text(_formatDate(user.createdAt)),
                  ),
                ),
                if (_affiliationError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _affiliationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileNameFormatter extends TextInputFormatter {
  const _ProfileNameFormatter({required this.maxLength});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    text = text.replaceFirst(RegExp(r'^ +'), '');
    text = text.replaceAll(RegExp(r' {2,}'), ' ');

    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }

    final baseOffset = math.max(
      0,
      math.min(text.length, newValue.selection.baseOffset),
    );
    final extentOffset = math.max(
      0,
      math.min(text.length, newValue.selection.extentOffset),
    );

    return TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: baseOffset,
        extentOffset: extentOffset,
      ),
      composing: TextRange.empty,
    );
  }
}
