import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../providers/auth_provider.dart';

class RegisterDetailsPage extends StatefulWidget {
  final String email;

  const RegisterDetailsPage({super.key, required this.email});

  @override
  State<RegisterDetailsPage> createState() => _RegisterDetailsPageState();
}

class _RegisterDetailsPageState extends State<RegisterDetailsPage>
    with SingleTickerProviderStateMixin {
  static const int _nameMaxLength = 24;
  static const int _passwordMinLength = 6;
  static const int _passwordMaxLength = 72;
  static final RegExp _phonePattern = RegExp(r'^\(\d{2}\) \d \d{4}-\d{4}$');
  static final RegExp _nameConsecutiveSpacesPattern = RegExp(r' {2,}');

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final rawName = _nameController.text;
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();

    if (rawName.trim().isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nome, senha e confirmação são obrigatórios.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (rawName.length > _nameMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'O nome deve ter no máximo $_nameMaxLength caracteres.',
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (rawName.startsWith(' ') || rawName.endsWith(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'O nome não pode começar ou terminar com espaço.',
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_nameConsecutiveSpacesPattern.hasMatch(rawName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'O nome não pode ter dois ou mais espaços seguidos.',
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (password.length < _passwordMinLength ||
        password.length > _passwordMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A senha deve ter entre $_passwordMinLength e $_passwordMaxLength caracteres.',
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (confirmPassword.length > _passwordMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A confirmação de senha deve ter no máximo $_passwordMaxLength caracteres.',
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('As senhas não conferem.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (phone.isNotEmpty && !_phonePattern.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Telefone inválido. Use o formato (99) 9 9999-9999.',
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: widget.email,
      password: password,
      name: rawName,
      phoneNumber: phone.isEmpty ? null : phone,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Erro ao cadastrar.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cadastro realizado com sucesso!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
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
                Positioned(
                  top: size.height * 0.3,
                  left: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6B879E).withValues(alpha: 0.05),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Botão voltar animado
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: GestureDetector(
                                    onTap: () => context.go('/register'),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                            Colors.white.withValues(
                                              alpha: 0.05,
                                            ),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 40),

                            // Título e email
                            const Text(
                              'Complete seu perfil',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFF3F5F7F,
                                    ).withValues(alpha: 0.2),
                                    const Color(
                                      0xFF6B879E,
                                    ).withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Campos de formulário
                            _buildModernTextField(
                              controller: _nameController,
                              label: 'Nome completo',
                              icon: Icons.person_outline_rounded,
                              hint: 'Como você quer ser chamado?',
                              onChanged: (_) => setState(() {}),
                              suffixIcon: _nameController.text.isNotEmpty
                                  ? _buildNameCounterSuffix(
                                      length: _nameController.text.length,
                                    )
                                  : null,
                              inputFormatters: const [
                                _RegisterNameFormatter(
                                  maxLength: _nameMaxLength,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: _phoneController,
                              label: 'Telefone',
                              icon: Icons.phone_outlined,
                              hint: '(99) 9 9999-9999',
                              keyboardType: TextInputType.phone,
                              isOptional: true,
                              inputFormatters: const [
                                _RegisterPhoneMaskFormatter(),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: _passwordController,
                              label: 'Senha',
                              icon: Icons.lock_outline_rounded,
                              hint: 'Mínimo 6 caracteres',
                              obscureText: _obscurePassword,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                LengthLimitingTextInputFormatter(
                                  _passwordMaxLength,
                                ),
                              ],
                              onChanged: (_) {
                                if (_passwordController.text.isEmpty &&
                                    !_obscurePassword) {
                                  setState(() {
                                    _obscurePassword = true;
                                  });
                                  return;
                                }
                                setState(() {});
                              },
                              suffixIcon: _passwordController.text.isNotEmpty
                                  ? _buildPasswordSuffix(
                                      length: _passwordController.text.length,
                                      obscure: _obscurePassword,
                                      onToggle: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            _buildModernTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmar senha',
                              icon: Icons.lock_person_outlined,
                              hint: 'Digite a mesma senha novamente',
                              obscureText: _obscureConfirmPassword,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                LengthLimitingTextInputFormatter(
                                  _passwordMaxLength,
                                ),
                              ],
                              onChanged: (_) {
                                if (_confirmPasswordController.text.isEmpty &&
                                    !_obscureConfirmPassword) {
                                  setState(() {
                                    _obscureConfirmPassword = true;
                                  });
                                  return;
                                }
                                setState(() {});
                              },
                              suffixIcon:
                                  _confirmPasswordController.text.isNotEmpty
                                  ? _buildPasswordSuffix(
                                      length: _confirmPasswordController
                                          .text
                                          .length,
                                      obscure: _obscureConfirmPassword,
                                      onToggle: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    )
                                  : null,
                            ),

                            const SizedBox(height: 32),

                            // Botão de cadastro
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3F5F7F),
                                      Color(0xFF6B879E),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isLoading
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF3F5F7F,
                                            ).withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Criar conta',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Termos e condições
                            Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Ao criar uma conta, você concorda com os ',
                                    ),
                                    TextSpan(
                                      text: 'Termos de Uso',
                                      style: TextStyle(
                                        color: const Color(0xFF3F5F7F),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' e '),
                                    TextSpan(
                                      text: 'Política de Privacidade',
                                      style: TextStyle(
                                        color: const Color(0xFF3F5F7F),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Versão
                            Text(
                              'Versão 2.0.0',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
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
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isOptional = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: isOptional ? '$label (opcional)' : label,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 14,
          ),
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.5),
            size: 22,
          ),
          suffixIcon:
              suffixIcon ??
              (isOptional
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Opcional',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : null),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF3F5F7F), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildNameCounterSuffix({required int length}) {
    return SizedBox(
      width: 74,
      child: Center(
        child: Text(
          '$length/$_nameMaxLength',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSuffix({
    required int length,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return SizedBox(
      width: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$length/$_passwordMaxLength',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            tooltip: obscure ? 'Mostrar senha' : 'Ocultar senha',
            onPressed: onToggle,
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterNameFormatter extends TextInputFormatter {
  const _RegisterNameFormatter({required this.maxLength});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    // Evita espaços no início e colapsa múltiplos espaços em apenas um.
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

class _RegisterPhoneMaskFormatter extends TextInputFormatter {
  const _RegisterPhoneMaskFormatter();

  static const int _maxDigits = 11;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digitsOnly.length > _maxDigits
        ? digitsOnly.substring(0, _maxDigits)
        : digitsOnly;

    final masked = _applyMask(limitedDigits);

    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
      composing: TextRange.empty,
    );
  }

  String _applyMask(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    final areaEnd = math.min(2, digits.length);

    buffer.write('(');
    buffer.write(digits.substring(0, areaEnd));

    if (digits.length >= 2) {
      buffer.write(') ');
    }

    if (digits.length >= 3) {
      buffer.write(digits[2]);
    }

    if (digits.length >= 4) {
      buffer.write(' ');
      final firstBlockEnd = math.min(7, digits.length);
      buffer.write(digits.substring(3, firstBlockEnd));
    }

    if (digits.length >= 8) {
      buffer.write('-');
      final secondBlockEnd = math.min(11, digits.length);
      buffer.write(digits.substring(7, secondBlockEnd));
    }

    return buffer.toString();
  }
}
