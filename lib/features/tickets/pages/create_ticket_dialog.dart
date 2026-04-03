import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/models/user_model.dart';
import '../data/tickets_repository.dart';
import '../providers/tickets_provider.dart';

class CreateTicketDialog extends StatefulWidget {
  final UserModel user;

  const CreateTicketDialog({super.key, required this.user});

  @override
  State<CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<CreateTicketDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _repo = TicketsRepository();

  int? _selectedCategoryId;
  int? _selectedDepartmentId;

  bool _loadingData = true;
  bool _submitting = false;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cats = await _repo.getCategories();
      final cid = widget.user.companyId;
      var deps = <Map<String, dynamic>>[];
      if (cid != null) {
        deps = await _repo.getDepartmentsByCompany(cid);
      }
      if (mounted) {
        setState(() {
          _categories = cats;
          _departments = deps;
          _loadingData = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateTicket() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Digite o título do chamado.');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Digite a descrição do chamado.');
      return;
    }

    if (_selectedCategoryId == null) {
      _showError('Selecione uma categoria.');
      return;
    }

    if (widget.user.companyId == null) {
      _showError('Sua conta precisa estar vinculada a uma empresa.');
      return;
    }

    if (_selectedDepartmentId == null) {
      _showError('Selecione um departamento (loja).');
      return;
    }

    setState(() => _submitting = true);

    final ticketsProvider = context.read<TicketsProvider>();
    final success = await ticketsProvider.createTicket(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      creatorId: widget.user.id,
      departmentId: _selectedDepartmentId!,
      categoryId: _selectedCategoryId!,
    );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (!success) {
      _showError(ticketsProvider.errorMessage ?? 'Erro ao criar chamado.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chamado criado com sucesso!'),
        backgroundColor: AppColors.success,
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.ink900, AppColors.ink800],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Novo Chamado',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Título',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Assunto do chamado',
                  maxLines: 1,
                ),
                const SizedBox(height: 20),
                Text(
                  'Descrição',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Explique o motivo do chamado',
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Text(
                  'Departamento (loja)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDepartmentField(),
                const SizedBox(height: 20),
                Text(
                  'Categoria',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildCategoryField(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.green.shade300,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Status: Aberto (novo chamado)',
                          style: TextStyle(
                            color: Colors.green.shade300,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitting || _loadingData
                            ? null
                            : _handleCreateTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.seed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Criar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentField() {
    if (_loadingData) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.seed),
          ),
        ),
      );
    }

    if (_departments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
        ),
        child: Text(
          'Não há departamentos ativos. Peça ao administrador para cadastrar departamentos na sua empresa.',
          style: TextStyle(color: Colors.orange.shade200, fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<int>(
        value: _selectedDepartmentId,
        hint: Text(
          'Selecione o departamento',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(8),
        dropdownColor: AppColors.ink800,
        items: _departments.map((d) {
          return DropdownMenuItem<int>(
            value: d['id'] as int,
            child: Text(
              d['name'] as String,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedDepartmentId = value);
        },
      ),
    );
  }

  Widget _buildCategoryField() {
    if (_loadingData) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.seed),
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Text(
        'Nenhuma categoria disponível.',
        style: TextStyle(color: Colors.red.shade200),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<int>(
        value: _selectedCategoryId,
        hint: Text(
          'Selecione uma categoria',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(8),
        dropdownColor: AppColors.ink800,
        items: _categories.map((category) {
          return DropdownMenuItem<int>(
            value: category['id'] as int,
            child: Text(
              category['name'] as String,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedCategoryId = value);
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.seed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
