# 📋 Documentação de Sprint — Gesture Called
**Data:** 29/03/2026  
**Branch:** `feat/frontend-sprint`  
**Repositório:** [matheusbragap/gesture_called](https://github.com/matheusbragap/gesture_called)

---

## ✅ O que foi feito nesta sprint

### 1. Tela de Detalhes do Chamado — `TicketDetailView`

Criado o arquivo `lib/views/ticket_detail_view.dart` com as seguintes características:

- Cabeçalho (`AppBar`) com cor dinâmica baseada no status do chamado.
- Badge de status com borda colorida.
- Exibição de título, descrição e atendente responsável.
- Botão de ação no rodapé com comportamento condicional (Máquina de Estados).

**Trecho principal — Cor dinâmica por status:**
```dart
Color _getCorStatus(String status) {
  switch (status) {
    case 'Aberto':      return Colors.red.shade700;
    case 'Em Andamento': return Colors.orange.shade700;
    case 'Resolvido':   return Colors.green.shade700;
    default:            return Colors.grey;
  }
}
```

**Trecho — Badge de status (com API moderna do Flutter):**
```dart
Container(
  decoration: BoxDecoration(
    color: corStatus.withValues(alpha: 0.1), // withOpacity está deprecated
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: corStatus),
  ),
  child: Text(widget.chamado.status.toUpperCase(), ...),
)
```

---

### 2. Máquina de Estados — Transição de Status

Implementada a lógica de negócio que controla as transições permitidas:

```
Aberto → Em Andamento → Resolvido
```

> **Regra de negócio:** Um chamado só vai para "Em Andamento" após um técnico assumir explicitamente. Chamados "Resolvidos" têm o botão desabilitado — não podem retroceder.

**Trecho — Lógica da Máquina de Estados:**
```dart
void _atualizarStatus() {
  setState(() {
    if (widget.chamado.status == 'Aberto') {
      widget.chamado.status = 'Em Andamento';
      widget.chamado.atendenteId = 'Arlisson (Técnico)';
    } else if (widget.chamado.status == 'Em Andamento') {
      widget.chamado.status = 'Resolvido';
    }
  });
}
```

**Trecho — Controle visual do botão:**
```dart
String textoBotao;
IconData iconeBotao;
bool botaoHabilitado = true;

if (widget.chamado.status == 'Aberto') {
  textoBotao = 'ASSUMIR CHAMADO';
  iconeBotao = Icons.back_hand;
} else if (widget.chamado.status == 'Em Andamento') {
  textoBotao = 'RESOLVER CHAMADO';
  iconeBotao = Icons.check_circle;
} else {
  textoBotao = 'CHAMADO FINALIZADO';
  iconeBotao = Icons.lock;
  botaoHabilitado = false; // Botão travado
}
```

---

### 3. Comunicação entre Telas — Navigation Payload

A `NewTicketView` agora empacota os dados preenchidos e os retorna para a `HomeView` ao fechar, que atualiza a lista em tempo real.

**Trecho — Envio de dados ao fechar (`new_ticket_view.dart`):**
```dart
final novoChamado = TicketModel(
  id: DateTime.now().millisecondsSinceEpoch,
  titulo: _tituloController.text,
  descricao: _descricaoController.text,
  status: 'Aberto',
  unidadeOrigemId: 101,
  dataAbertura: DateTime.now(),
);

Navigator.pop(context, novoChamado);
```

**Trecho — Recebimento na `HomeView` (Floating Action Button):**
```dart
onPressed: () async {
  final resultado = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const NewTicketView()),
  );

  if (resultado != null && resultado is TicketModel) {
    setState(() {
      _chamados.add(resultado);
    });
  }
},
```

---

### 4. Sincronização de Estado — Atualização das Abas

Correção do bug onde o chamado não era movido para a aba correta ao voltar da `TicketDetailView`.

**Trecho — `onTap` corrigido na `HomeView`:**
```dart
onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TicketDetailView(chamado: chamado),
    ),
  );

  // Força redesenho da tela ao retornar
  setState(() {});
},
```

> **Nota arquitetural:** Quando o Supabase for integrado via `StreamBuilder` (Realtime), este `setState(() {})` será removido. A atualização ocorrerá automaticamente pelo canal WebSocket.

---

### 5. Controle de Acesso Visual — RBAC

Implementada a lógica de permissão baseada no perfil do usuário logado. O botão de ação só é exibido para técnicos.

**Trecho — Renderização condicional do botão (`ticket_detail_view.dart`):**
```dart
bottomNavigationBar: usuarioLogado.isTecnico
    ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: botaoHabilitado ? _atualizarStatus : null,
            icon: Icon(iconeBotao),
            label: Text(textoBotao),
            ...
          ),
        ),
      )
    : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Apenas a equipe de TI pode alterar o status deste chamado.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ),
```

---

## 🔄 Mudanças Estruturais

### `TicketModel` — Atualizado (`lib/models/ticket_model.dart`)

Adicionados campos de auditoria e serialização JSON para integração futura com o Supabase:

```dart
class TicketModel {
  final int id;
  final String titulo;
  final String descricao;
  String status;              // Sem 'final' — muda com a Máquina de Estados
  final int unidadeOrigemId;
  final DateTime dataAbertura; // Novo: timestamp de criação
  String? atendenteId;         // Novo: quem assumiu o chamado (pode ser nulo)

  // Lê do Supabase (JSON → Objeto)
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      status: json['status'] ?? 'Aberto',
      unidadeOrigemId: json['unidade_origem_id'] ?? 0,
      dataAbertura: json['data_abertura'] != null
          ? DateTime.parse(json['data_abertura'])
          : DateTime.now(),
      atendenteId: json['atendente_id'],
    );
  }

  // Escreve no Supabase (Objeto → JSON)
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'status': status,
      'unidade_origem_id': unidadeOrigemId,
      'data_abertura': dataAbertura.toIso8601String(),
      'atendente_id': atendenteId,
    };
  }
}
```

---

### `ProfileModel` — Criado (`lib/models/profile_model.dart`)

Substituiu o antigo `user_model.dart`. Alinhado ao Dicionário de Dados (tabela `profiles` do Supabase).

```dart
class ProfileModel {
  final String id;          // UUID → auth.users
  final String name;
  final String email;
  final String? phoneNumber;
  final int? companyId;
  final bool isActive;
  final DateTime lastSeen;
  final DateTime createdAt;
  final String role;        // ⚠️ Campo temporário — aguarda definição no DB

  // Getter de permissão (RBAC)
  bool get isTecnico => role == 'tecnico';

  factory ProfileModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}

// Usuário simulado para testes (substitua pelo auth.getUser() do Supabase)
final usuarioLogado = ProfileModel(
  id: 'uuid-falso-123',
  name: 'Arlisson Santos',
  email: 'arlisson@email.com',
  isActive: true,
  lastSeen: DateTime.now(),
  createdAt: DateTime.now(),
  role: 'tecnico', // Altere para 'funcionario' para testar o bloqueio da UI
);
```

---

## 📌 Pendências e Próximas Etapas

### 🔲 Interface (Front-end)

| # | Funcionalidade | Descrição |
|---|---|---|
| 1 | **Barra de Busca** | Adicionar `TextField` no `AppBar` da `HomeView` para filtrar chamados por título ou ID em tempo real. |
| 2 | **Tela de Cadastro** | Criar `SignupView` com campos: Nome, E-mail, Empresa, Departamento e Senha. |

---

### 🔲 Integração Back-end (Supabase)

| # | Funcionalidade | Descrição |
|---|---|---|
| 1 | **Autenticação Real** | Substituir o `Future.delayed` falso na `LoginView` pelo `Supabase Auth`. |
| 2 | **Listagem Real** | Substituir o mock `_chamados` por query real na tabela `tickets` do PostgreSQL. |
| 3 | **Atualização de Status** | O botão na `TicketDetailView` deve disparar um `UPDATE` na tabela `tickets` via Supabase. |
| 4 | **Realtime (StreamBuilder)** | Migrar a `HomeView` para `StreamBuilder` escutando a tabela `tickets`. O `setState(() {})` atual será removido nesta etapa. |
| 5 | **Perfil Dinâmico** | Substituir `usuarioLogado` (mock) por `auth.getUser()` + query na tabela `profiles`. |

---

### 🔲 Pendência com o Responsável pelo Banco de Dados

> **Ação necessária:** A tabela `profiles` no Supabase não possui um campo para controle de nível de acesso (RBAC). O campo `role` está sendo simulado no Front-end. É necessário definir com o colega DBA uma das duas abordagens:

| Opção | Abordagem | Observação |
|---|---|---|
| **A (Recomendada)** | Criar coluna `role` (`text` ou `enum`) na tabela `profiles` com valores: `admin`, `tecnico`, `funcionario`. | Mais simples e direto. |
| **B** | Vincular permissão ao `department_id` (ex: se o departamento for TI, herda permissões de técnico). | Aproveita a estrutura já existente. |

---

## 🗂️ Arquivos Alterados nesta Sprint

```
lib/
├── models/
│   ├── ticket_model.dart         ← Atualizado (dataAbertura, atendenteId, fromJson, toJson)
│   └── profile_model.dart        ← Criado (substituiu user_model.dart)
│
└── views/
    ├── ticket_detail_view.dart   ← Criado (Máquina de Estados + RBAC)
    ├── home_view.dart            ← Atualizado (async/await no onTap e no FAB)
    └── new_ticket_view.dart      ← Atualizado (Navigator.pop com objeto)
```

---


*Documentação gerada ao final da sprint de 29/03/2026.*
