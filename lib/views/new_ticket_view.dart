import 'package:flutter/material.dart';

class NewTicketView extends StatefulWidget {
  const NewTicketView({super.key});

  @override
  State<NewTicketView> createState() => _NewTicketViewState();
}

class _NewTicketViewState extends State<NewTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  bool _isSubmitting = false;

  Future<void> _enviarChamado() async {
   // 1. Validação de formulário: Garante que os campos obrigatórios estão preenchidos
    if (!_formKey.currentState!.validate()) return;

    // 2. Segurança: Bloqueia a interface imediatamente
    setState(() => _isSubmitting = true);

    try {
      // Simulação da chamada segura à API Node.js (Controller real virá aqui)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      
     
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chamado aberto com sucesso!'), backgroundColor: Colors.green),
      );
      
      
      Navigator.pop(context); 
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir chamado: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Chamado'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              'Descreva o problema de forma clara para a equipa de suporte.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _tituloController,
              maxLength: 50, // Limita o tamanho na base de dados
              decoration: const InputDecoration(
                labelText: 'Título do Chamado',
                hintText: 'Ex: Impressora do PDV 1 sem papel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) => value == null || value.trim().isEmpty 
                  ? 'O título é obrigatório.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descrição Detalhada',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty 
                  ? 'A descrição é obrigatória.' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                // Se _isSubmitting for true, onPressed fica null (botão desativa automaticamente)
                onPressed: _isSubmitting ? null : _enviarChamado, 
                icon: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'ENVIANDO...' : 'ENVIAR CHAMADO'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}