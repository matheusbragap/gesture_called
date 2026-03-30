import 'package:flutter/material.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  // --------------------------------------------------------
  // Controladores (Refletindo a tabela 'profiles')
  // --------------------------------------------------------
  final _nomeController = TextEditingController();       // profiles.name
  final _emailController = TextEditingController();      // profiles.email
  final _telefoneController = TextEditingController();   // profiles.phone_number
  final _senhaController = TextEditingController();      // Vai para auth.users (Supabase)
  
  // --------------------------------------------------------
  // Chaves Estrangeiras e Regras de Negócio
  // --------------------------------------------------------
  String? _empresaSelecionada; // profiles.company_id
  String _perfilSelecionado = 'Usuário Padrão'; // Precisa ser adicionado ao BD futuramente

  // Simulando dados que viriam da tabela 'companies'
  final List<Map<String, dynamic>> _empresasSimuladas = [
    {'id': 1, 'name': 'Matriz - São Paulo'},
    {'id': 2, 'name': 'Filial - Rio de Janeiro'},
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Novo Colaborador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add_alt_1, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            
            // profiles.name
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            
            // profiles.email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail Corporativo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            // profiles.phone_number
            TextField(
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone / Ramal (Opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),

            // profiles.company_id (Vínculo com a tabela companies)
            DropdownButtonFormField<String>(
              initialValue: _empresaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Empresa / Filial',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              items: _empresasSimuladas.map((empresa) {
                return DropdownMenuItem<String>(
                  value: empresa['id'].toString(),
                  child: Text(empresa['name']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _empresaSelecionada = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Senha para o auth.users do Supabase
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha de Acesso',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            
            // Perfil Visual (Pendente de criação no BD)
            DropdownButtonFormField<String>(
              initialValue: _perfilSelecionado,
              decoration: const InputDecoration(
                labelText: 'Perfil de Acesso (Role)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.admin_panel_settings),
              ),
              items: ['Usuário Padrão', 'Técnico de TI'].map((String perfil) {
                return DropdownMenuItem<String>(
                  value: perfil,
                  child: Text(perfil),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _perfilSelecionado = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                debugPrint('--- DADOS PARA O SUPABASE ---');
                debugPrint('Email: ${_emailController.text}');
                debugPrint('Senha: ${_senhaController.text}');
                debugPrint('profiles.name: ${_nomeController.text}');
                debugPrint('profiles.phone_number: ${_telefoneController.text}');
                debugPrint('profiles.company_id: $_empresaSelecionada');
                debugPrint('profiles.role (PENDENTE NO BD): $_perfilSelecionado');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cadastro simulado com sucesso!')),
                );
              },
              child: const Text('Cadastrar Colaborador', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}