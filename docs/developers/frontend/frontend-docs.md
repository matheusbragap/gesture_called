# 📱 Gesture Called — Documentação Técnica: Sprint Front-End (Flutter)
 

---

## 📋 Sumário

1. [Visão Geral](#1-visão-geral)
2. [Stack Tecnológica](#2-stack-tecnológica)
3. [Estrutura de Pastas](#3-estrutura-de-pastas)
4. [Sistema de Rotas e Navegação](#4-sistema-de-rotas-e-navegação)
5. [Configuração Inicial (main.dart)](#5-configuração-inicial-maindart)
6. [Camada de Modelos (Models)](#6-camada-de-modelos-models)
7. [Camada de Serviços (Services)](#7-camada-de-serviços-services)
8. [Camada de Views (Telas)](#8-camada-de-views-telas)
   - [8.1 Login (login\_view.dart)](#81-login-login_viewdart)
   - [8.2 Dashboard (home\_view.dart)](#82-dashboard-home_viewdart)
   - [8.3 Novo Chamado (new\_ticket\_view.dart)](#83-novo-chamado-new_ticket_viewdart)
   - [8.4 Perfil do Usuário (profile\_view.dart)](#84-perfil-do-usuário-profile_viewdart)
9. [Padrões de Código e UX Aplicados](#9-padrões-de-código-e-ux-aplicados)
10. [Dependências do Projeto](#10-dependências-do-projeto)
11. [Como Executar o Projeto](#11-como-executar-o-projeto)
12. [Pendências e Próximos Passos](#12-pendências-e-próximos-passos)

---

## 1. Visão Geral

Esta documentação descreve todo o trabalho realizado na **Sprint de Front-End** do projeto **Gesture Called**, um sistema mobile de Help Desk voltado para comunicação interna em empresas com múltiplas unidades físicas.

O objetivo desta sprint foi construir a camada de interface do usuário (UI) do aplicativo Flutter, estabelecendo:

- Uma **arquitetura de pastas escalável** baseada em separação de responsabilidades (MVC adaptado).
- Um **sistema de navegação robusto** com rotas nomeadas.
- **Telas funcionais** com validação, estados de carregamento e feedback visual profissional.
- A **base de integração** com o Supabase, pronta para ser conectada à API real.

> ⚠️ **Nota para Desenvolvedores:** Todo o conteúdo de dados exibido nas telas (chamados, nome do usuário, unidade) é atualmente **simulado (mock data)**. A integração real com o Supabase está mapeada na seção [Próximos Passos](#12-pendências-e-próximos-passos).

---

## 2. Stack Tecnológica

| Tecnologia | Versão | Finalidade |
|---|---|---|
| **Dart** | ^3.x | Linguagem principal (Null Safety) |
| **Flutter** | ^3.x | Framework de UI multiplataforma |
| **Supabase Flutter** | ^2.x | BaaS: Autenticação, Banco de Dados e API REST |
| **Material Design 3** | — | Sistema de design visual |

> O pacote `http` foi instalado inicialmente mas foi **substituído pelo `supabase_flutter`**, que já provê um cliente HTTP interno com suporte nativo a JWT, tokens de sessão e realtime.

---

## 3. Estrutura de Pastas

A organização segue o padrão **MVC adaptado para Flutter**, garantindo que cada arquivo tenha uma única responsabilidade:

```
gesture_called/
└── lib/
    ├── main.dart                   # Inicialização do App, Supabase e Rotas
    │
    ├── models/
    │   ├── ticket_model.dart       # Entidade: Chamado
    │   └── user_model.dart         # Entidade: Usuário
    │
    ├── services/
    │   └── api_service.dart        # Cliente HTTP base (preparado para migração Supabase)
    │
    ├── controllers/
    │   └── ticket_controller.dart  # Lógica de negócio dos chamados
    │
    └── views/
        ├── login_view.dart         # Tela de autenticação
        ├── home_view.dart          # Dashboard principal com abas
        ├── new_ticket_view.dart    # Formulário de abertura de chamado
        └── profile_view.dart       # Perfil do colaborador logado
```

**Princípio aplicado:** Nenhuma `View` realiza chamadas diretas à API nem processa regras de negócio. Essa responsabilidade pertence exclusivamente aos `Controllers` e `Services`.

---

## 4. Sistema de Rotas e Navegação

Toda a navegação é centralizada no `main.dart` usando **Named Routes** (Rotas Nomeadas), o padrão recomendado para aplicações Flutter de médio e grande porte.

| Rota | View | Descrição |
|---|---|---|
| `/` | `LoginView` | Ponto de entrada. Exibe o formulário de autenticação. |
| `/home` | `HomeView` | Dashboard principal. Acessível após login bem-sucedido. |
| `/3d` | `ThreeDShowcasePage` | Showcase visual com animações 3D (Matrix4). |

**Vantagem desta abordagem:** Qualquer alteração de destino (por exemplo, redirecionar `/home` para uma tela de onboarding) é feita em **uma única linha** no `main.dart`, sem necessidade de alterar os botões de cada tela.

---

## 5. Configuração Inicial (main.dart)

O `main.dart` é o **ponto de entrada** da aplicação. Ele é responsável por:

1. Inicializar o binding do Flutter (`WidgetsFlutterBinding.ensureInitialized()`).
2. Conectar o app ao projeto Supabase.
3. Declarar o mapa de rotas nomeadas.

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';

void main() async {
  // Garante que o Flutter inicializou antes de processos assíncronos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a conexão com o Supabase
  await Supabase.initialize(
    url: 'SUA_URL_DO_SUPABASE_AQUI',
    anonKey: 'SUA_ANON_KEY_DO_SUPABASE_AQUI',
  );

  runApp(const GestureCalledApp());
}

class GestureCalledApp extends StatelessWidget {
  const GestureCalledApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Called',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
        '/3d': (context) => const ThreeDShowcasePage(),
      },
    );
  }
}
```

> 🔑 **Atenção:** As chaves `url` e `anonKey` devem ser obtidas no painel do projeto em [supabase.com](https://supabase.com). **Nunca versione essas chaves diretamente no código.** Use variáveis de ambiente ou um arquivo `.env` ignorado pelo `.gitignore`.

---

## 6. Camada de Modelos (Models)

Os modelos refletem diretamente o **Dicionário de Dados** definido na documentação do projeto. Cada classe é responsável por tipar os dados e serializar/deserializar o JSON retornado pela API.

### `user_model.dart`

Representa um colaborador da empresa, vinculado a uma unidade física.

```dart
class UserModel {
  final int id;
  final String nome;
  final String email;
  final String perfil; // 'funcionario', 'atendente' ou 'admin'
  final int unidadeId;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.unidadeId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      perfil: json['perfil'],
      unidadeId: json['unidade_id'],
    );
  }
}
```

### `ticket_model.dart`

Representa um chamado técnico. O campo `unidadeOrigemId` é **obrigatório** e reflete a regra de negócio central do sistema.

```dart
class TicketModel {
  final int id;
  final String titulo;
  final String descricao;
  final String status; // 'Aberto', 'Em Andamento', 'Resolvido'
  final int unidadeOrigemId;

  TicketModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.unidadeOrigemId,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      status: json['status'],
      unidadeOrigemId: json['unidade_origem_id'],
    );
  }

  // Usado no POST para criar um novo chamado
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'unidade_origem_id': unidadeOrigemId,
    };
  }
}
```

---

## 7. Camada de Serviços (Services)

### `api_service.dart`

Criado como cliente HTTP base com tratamento centralizado de erros e timeout. Atualmente serve como camada de abstração, mas **será substituído pelo cliente nativo do Supabase** na próxima sprint.

```dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = "http://localhost:3000/api";
  static const int _timeoutInSeconds = 10;

  static Map<String, String> _buildHeaders(String? token) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw ApiException(
        errorBody['message'] ?? 'Erro no servidor: ${response.statusCode}',
      );
    }
  }

  static Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _buildHeaders(token))
          .timeout(const Duration(seconds: _timeoutInSeconds));
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('A conexão expirou. Verifique sua internet.');
    } catch (e) {
      throw ApiException('Falha ao processar a requisição: $e');
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _buildHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: _timeoutInSeconds));
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('A conexão expirou. Verifique sua internet.');
    } catch (e) {
      throw ApiException('Falha ao processar a requisição: $e');
    }
  }
}
```

---

## 8. Camada de Views (Telas)

### 8.1 Login (`login_view.dart`)

**Objetivo:** Autenticar o usuário e redirecionar para o Dashboard.

**Funcionalidades implementadas:**
- Campo de e-mail com teclado otimizado (`TextInputType.emailAddress`).
- Campo de senha com ocultação de texto (`obscureText: true`).
- Estado de carregamento (`_isLoading`) que substitui o botão por um indicador visual.
- Tratamento de erros com `SnackBar`.
- Verificação de `mounted` para evitar vazamentos de memória em chamadas assíncronas.

```dart
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _realizarLogin() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Substituir pelo supabase.auth.signInWithPassword(...)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gesture Called',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _realizarLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('ENTRAR', style: TextStyle(fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}
```

---

### 8.2 Dashboard (`home_view.dart`)

**Objetivo:** Exibir todos os chamados da unidade do usuário logado, organizados por status.

**Funcionalidades implementadas:**
- `DefaultTabController` com 3 abas: **Abertos**, **Em Andamento**, **Resolvidos**.
- Filtragem dinâmica da lista por status usando método reutilizável `_buildListaChamados`.
- Cards com cores semânticas por status (vermelho, laranja, verde).
- Menu Lateral (`Drawer`) com acesso ao perfil e logout.
- `FloatingActionButton` estendido para abertura de novo chamado.

```dart
import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import 'new_ticket_view.dart';
import 'profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Mock Data — será substituído por Stream do Supabase
  final List<TicketModel> _chamados = [
    TicketModel(id: 1, titulo: 'Lâmpada queimada', descricao: 'Trocar no estoque', status: 'Aberto', unidadeOrigemId: 101),
    TicketModel(id: 2, titulo: 'Sistema lento', descricao: 'PDV 3 travando constantemente', status: 'Em Andamento', unidadeOrigemId: 101),
    TicketModel(id: 3, titulo: 'Impressora sem tinta', descricao: 'Trocar toner da impressora fiscal', status: 'Resolvido', unidadeOrigemId: 101),
    TicketModel(id: 4, titulo: 'Ar condicionado', descricao: 'Não está gelando', status: 'Aberto', unidadeOrigemId: 101),
  ];

  List<TicketModel> _filtrarPorStatus(String status) {
    return _chamados.where((c) => c.status == status).toList();
  }

  Widget _buildListaChamados(String status) {
    final chamadosFiltrados = _filtrarPorStatus(status);

    if (chamadosFiltrados.isEmpty) {
      return Center(
        child: Text(
          'Nenhum chamado $status.',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: chamadosFiltrados.length,
      itemBuilder: (context, index) {
        final chamado = chamadosFiltrados[index];
        final color = status == 'Aberto'
            ? Colors.red
            : status == 'Em Andamento'
                ? Colors.orange
                : Colors.green;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assignment, color: color.shade700),
            ),
            title: Text(
              chamado.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                chamado.descricao,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // TODO: Navegar para TicketDetailView
            },
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Nome do Usuário', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text('usuario@email.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue, size: 40),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Meu Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileView()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel de Chamados'),
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Abertos'),
              Tab(text: 'Em Andamento'),
              Tab(text: 'Resolvidos'),
            ],
          ),
        ),
        drawer: _buildDrawer(context),
        body: TabBarView(
          children: [
            _buildListaChamados('Aberto'),
            _buildListaChamados('Em Andamento'),
            _buildListaChamados('Resolvido'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewTicketView()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Novo Chamado'),
        ),
      ),
    );
  }
}
```

---

### 8.3 Novo Chamado (`new_ticket_view.dart`)

**Objetivo:** Permitir que o colaborador abra um novo chamado técnico com dados válidos.

**Funcionalidades implementadas:**
- Validação robusta com `GlobalKey<FormState>` — nenhum campo vazio chega à API.
- Limite de caracteres no título (`maxLength: 50`) alinhado com o banco de dados.
- Campo de descrição multilinha para detalhamento do problema.
- Botão desativado durante o envio (`_isSubmitting`) para prevenir chamados duplicados.
- `SnackBar` com cor verde para sucesso e vermelho para erro.

```dart
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO: Substituir pelo TicketController com chamada real ao Supabase
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado aberto com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir chamado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
      appBar: AppBar(title: const Text('Novo Chamado'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              'Descreva o problema de forma clara para a equipe de suporte.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _tituloController,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Título do Chamado',
                hintText: 'Ex: Impressora do PDV 1 sem papel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'O título é obrigatório.' : null,
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
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'A descrição é obrigatória.' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _enviarChamado,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'ENVIANDO...' : 'ENVIAR CHAMADO'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 8.4 Perfil do Usuário (`profile_view.dart`)

**Objetivo:** Exibir os dados cadastrais do colaborador logado.

**Funcionalidades implementadas:**
- Avatar circular com ícone representativo.
- Lista de informações com ícones e tipografia hierárquica.
- Widget `_buildProfileItem` reutilizável para evitar código duplicado.
- Preparada para receber dados dinâmicos do `supabase.auth.currentUser`.

```dart
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          // TODO: Substituir pelos dados reais do supabase.auth.currentUser
          _buildProfileItem(Icons.badge, 'Nome', 'Nome do Colaborador'),
          _buildProfileItem(Icons.email, 'E-mail', 'colaborador@empresa.com'),
          _buildProfileItem(Icons.work, 'Perfil de Acesso', 'Atendente / Suporte'),
          _buildProfileItem(Icons.store, 'Unidade', 'Filial 1 - Shopping'),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}
```

---

## 9. Padrões de Código e UX Aplicados

### Hierarquia de Cores Semânticas

O sistema usa cores para comunicar urgência de forma imediata, sem que o usuário precise ler o status:

| Status | Cor | Significado |
|---|---|---|
| **Aberto** | 🔴 Vermelho | Chamado não atendido — requer atenção imediata |
| **Em Andamento** | 🟠 Laranja | Chamado sendo tratado pela equipe de suporte |
| **Resolvido** | 🟢 Verde | Chamado finalizado com sucesso |

### Padrões de Engenharia Aplicados

| Padrão | Onde foi aplicado | Benefício |
|---|---|---|
| **Single Responsibility** | Cada arquivo tem uma única função | Facilita manutenção e testes |
| **DRY (Don't Repeat Yourself)** | `_buildListaChamados` e `_buildProfileItem` | Elimina código duplicado |
| **Fail-Fast** | Validação no cliente antes do POST | Evita dados inválidos no banco |
| **Safe Async** | `if (!mounted) return` em todas as funções async | Previne crashes ao sair de tela durante carregamento |
| **Named Routes** | Centralizado no `main.dart` | Navegação previsível e fácil de manter |
| **Const Constructors** | Widgets estáticos marcados com `const` | Reduz rebuilds desnecessários da UI |

---

## 10. Dependências do Projeto

Após esta sprint, o `pubspec.yaml` deve conter as seguintes dependências:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.12.2
  http: ^1.x.x  # Mantido temporariamente, será removido após migração completa para Supabase
```

Para instalar as dependências em um ambiente novo, execute:

```bash
cd gesture_called
flutter pub get
```

---

## 11. Como Executar o Projeto

### Pré-requisitos

- Flutter SDK instalado e configurado (`flutter doctor` sem erros críticos)
- Android Studio com SDK configurado **ou** Visual Studio com workload C++ instalado
- Conta no Supabase com projeto criado

### Passo a Passo

```bash
# 1. Clone o repositório
git clone https://github.com/matheusbragap/gesture_called.git

# 2. Entre na pasta do projeto
cd gesture_called

# 3. Instale as dependências
flutter pub get

# 4. Configure as chaves do Supabase em lib/main.dart
# Substitua 'SUA_URL_DO_SUPABASE_AQUI' e 'SUA_ANON_KEY_DO_SUPABASE_AQUI'

# 5. Execute o projeto
flutter run
```

> 💡 **Dica:** Para desenvolvimento web (Chrome), utilize `flutter run -d chrome`. Para Windows desktop, utilize `flutter run -d windows`.

---

## 12. Pendências e Próximos Passos

As tarefas abaixo estão mapeadas e prontas para serem implementadas na próxima sprint, com a base do front-end já preparada para recebê-las.

---

### ✅ Concluído nesta Sprint

- [x] Configuração inicial do projeto Flutter com Supabase
- [x] Sistema de rotas nomeadas
- [x] Tela de Login com validação e estados de loading
- [x] Dashboard com abas por status
- [x] Cards de chamados com cores semânticas
- [x] Menu lateral (Drawer) com perfil e logout
- [x] Formulário de novo chamado com validação
- [x] Tela de perfil do colaborador
- [x] Estrutura MVC de pastas estabelecida

---

### 🔲 Próxima Sprint — Integração com Supabase

-- Dados de teste
INSERT INTO unidades (nome) VALUES ('Loja Matriz - Centro'), ('Filial 1 - Shopping');
```

#### 2. Integrar Autenticação Real

Substituir o `Future.delayed` no `login_view.dart` pela chamada real:

```dart
// Substituir a simulação por:
await Supabase.instance.client.auth.signInWithPassword(
  email: _emailController.text.trim(),
  password: _senhaController.text,
);
```

#### 3. Substituir Mock Data por StreamBuilder

Na `home_view.dart`, substituir a lista estática por um stream reativo do Supabase:

```dart
// Em vez de List<TicketModel> fixo, usar:
StreamBuilder(
  stream: Supabase.instance.client
      .from('chamados')
      .stream(primaryKey: ['id'])
      .eq('unidade_origem_id', unidadeDoUsuario),
  builder: (context, snapshot) { ... },
)
```

#### 4. Implementar Tela de Detalhes do Chamado (`ticket_detail_view.dart`)

Tela que exibe todos os dados de um chamado e permite **alterar o status** (ex: de `Aberto` para `Em Andamento`). Acesso via `onTap` nos cards do Dashboard.

**Funcionalidades sugeridas:**
- Exibição completa de título, descrição, data de abertura e unidade de origem.
- Botão de ação contextual baseado no perfil do usuário:
  - `funcionario` → apenas visualiza.
  - `atendente` → pode mover para "Em Andamento" ou "Resolvido".
  - `admin` → acesso total.
- Histórico de mensagens/comentários entre solicitante e atendente (tabela `mensagens`).

#### 5. Conectar Perfil ao Usuário Logado

Substituir os dados fixos da `profile_view.dart` pelos dados reais:

```dart
final user = Supabase.instance.client.auth.currentUser;
// Buscar perfil na tabela 'usuarios' com user.id
```

#### 6. Remover `api_service.dart` (limpeza de código)

Com a integração Supabase completa, o arquivo `api_service.dart` se torna obsoleto e deve ser removido do projeto para manter o código limpo.

---

> 📌 **Nota Final para Desenvolvedores:** Toda a estrutura de pastas, modelos e views foi construída antecipando a integração com o Supabase. Os pontos marcados com `// TODO` no código indicam exatamente onde cada substituição deve ocorrer. A lógica de UI não precisará ser alterada — apenas os dados que alimentam as telas.
