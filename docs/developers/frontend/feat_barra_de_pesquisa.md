# feat: Implementação da Barra de Pesquisa — `HomeView`

**Data:** 30/03/2026  
**Projeto:** Gesture Called  
**Arquivo principal modificado:** `lib/views/home_view.dart`  
**Branch:** `feat/frontend-sprint`

---

## Visão Geral

Nesta sessão foi implementada uma **barra de pesquisa dinâmica** na `HomeView`, permitindo ao usuário buscar chamados pelo título ou pelo número de ID diretamente na tela principal do aplicativo. A solução foi arquitetada com foco na **preparação para integração futura com o Supabase**, simulando o comportamento de uma query `ILIKE` do banco de dados.

---

## 1. Variáveis de Estado Adicionadas

Três variáveis foram declaradas no topo da classe `_HomeViewState` para controlar o comportamento da barra de pesquisa:

```dart
bool _isSearching = false;
final TextEditingController _searchController = TextEditingController();
String _searchQuery = '';
```

| Variável | Tipo | Função |
|---|---|---|
| `_isSearching` | `bool` | Controla se a barra de busca está ativa ou não |
| `_searchController` | `TextEditingController` | Gerencia o texto digitado no campo de busca |
| `_searchQuery` | `String` | Armazena a string atual para filtrar a lista |

---

## 2. AppBar com Modo de Pesquisa

A `AppBar` foi transformada em um componente interativo. Ao pressionar o ícone de lupa, o título é substituído por um `TextField` de busca. Ao pressionar o ícone de fechar (`X`), a busca é cancelada e a lista é restaurada.

```dart
appBar: AppBar(
  backgroundColor: const Color.fromARGB(232, 255, 255, 255),
  foregroundColor: Colors.blue,
  title: _isSearching
      ? TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.blue),
          decoration: const InputDecoration(
            hintText: 'Buscar por título ou #ID...',
            hintStyle: TextStyle(color: Colors.blue),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        )
      : const Text('Chamados'),
  actions: [
    IconButton(
      icon: Icon(_isSearching ? Icons.close : Icons.search),
      onPressed: () {
        setState(() {
          if (_isSearching) {
            _isSearching = false;
            _searchController.clear();
            _searchQuery = '';
          } else {
            _isSearching = true;
          }
        });
      },
    ),
  ],
  bottom: const TabBar(
    labelColor: Colors.blue,
    unselectedLabelColor: Colors.grey,
    indicatorColor: Colors.blue,
    tabs: [
      Tab(text: 'Abertos'),
      Tab(text: 'Em Andamento'),
      Tab(text: 'Resolvidos'),
    ],
  ),
),
```

---

## 3. Lógica de Filtragem — Dois Funis

O método `_buildListaChamados` foi refatorado para aplicar dois filtros sequenciais antes de renderizar a lista. Essa abordagem imita o padrão de uma query no banco de dados.

```dart
Widget _buildListaChamados(String status) {
  // Funil 1 — Filtra pela aba selecionada (status)
  var chamadosFiltrados = _filtrarPorStatus(status);

  // Funil 2 — Filtra pelo texto digitado na barra de busca
  // Preparado para ser substituído por: supabase.from('tickets').select().ilike('title', '%$query%')
  if (_searchQuery.isNotEmpty) {
    chamadosFiltrados = chamadosFiltrados.where((c) {
      final query = _searchQuery.toLowerCase();
      final tituloMatches = c.titulo.toLowerCase().contains(query);
      final idMatches = c.id.toString().contains(query);
      return tituloMatches || idMatches;
    }).toList();
  }

  if (chamadosFiltrados.isEmpty) {
    return Center(
      child: Text(
        _searchQuery.isEmpty ? 'Nenhum chamado $status.' : 'Nenhum chamado encontrado.',
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: chamadosFiltrados.length,
    itemBuilder: (context, index) {
      // ... renderização dos cards
    },
  );
}
```

> **Nota arquitetural:** O "Funil 2" foi intencionalmente estruturado para ser facilmente substituído por uma chamada ao Supabase no futuro. Basta trocar o `.where()` em memória por uma query `ilike` no banco.

---

## 4. Correções de Interface (UI/UX)

### 4.1 Contraste da TabBar

Com o fundo da `AppBar` alterado para branco, as abas não selecionadas ficavam invisíveis. A correção foi ajustar a propriedade `unselectedLabelColor`:

```dart
// Antes — invisível no fundo claro
unselectedLabelColor: Color.fromARGB(141, 255, 255, 255),

// Depois — legível
unselectedLabelColor: Colors.grey,
```

---

## Resumo das Alterações

| Item | Status |
|---|---|
| Variáveis de estado da busca | ✅ Implementado |
| AppBar com modo de pesquisa | ✅ Implementado |
| Filtro duplo (status + busca) | ✅ Implementado |
| Mensagem de lista vazia contextual | ✅ Implementado |
| Contraste da TabBar corrigido | ✅ Corrigido |
