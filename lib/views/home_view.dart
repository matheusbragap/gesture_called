import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import 'new_ticket_view.dart';
import 'profile_view.dart';
import 'ticket_detail_view.dart';
import 'signup_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // --------------------------------------------------------
  // Variáveis de Estado (Busca)
  // --------------------------------------------------------
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // ignore: prefer_final_fields
  bool _isAdmin = true; // Simulando um usuário admin para mostrar o botão "Novo Colaborador"
  // --------------------------------------------------------
  // Lista de Chamados Simulada
  // --------------------------------------------------------
  final List<TicketModel> _chamados = [
    TicketModel(
      id: 1,
      titulo: 'Lâmpada queimada',
      descricao: 'Trocar no estoque',
      status: 'Aberto',
      unidadeOrigemId: 101,
      atendenteId: 'joão (TI)',
      dataAbertura: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TicketModel(
      id: 2,
      titulo: 'Sistema lento',
      descricao: 'PDV 3 travando constantemente',
      status: 'Em Andamento',
      unidadeOrigemId: 101,
      atendenteId: 'maria (TI)',
      dataAbertura: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TicketModel(
      id: 3,
      titulo: 'Impressora sem tinta',
      descricao: 'Trocar toner da impressora fiscal',
      status: 'Resolvido',
      unidadeOrigemId: 101,
      atendenteId: 'pedro (TI)',
      dataAbertura: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    TicketModel(
      id: 4,
      titulo: 'Ar condicionado',
      descricao: 'Não está gelando',
      status: 'Aberto',
      unidadeOrigemId: 101,
      atendenteId: 'ana (TI)',
      dataAbertura: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // --------------------------------------------------------
  // Métodos Utilitários e Filtros
  // --------------------------------------------------------
  List<TicketModel> _filtrarPorStatus(String status) {
    return _chamados.where((c) => c.status == status).toList();
  }
  // --------------------------------------------------------
  // Widgets Construtores
  // --------------------------------------------------------
  Widget _buildListaChamados(String status) {
    // 1. Primeiro Funil: Filtra pela aba atual
    var chamadosFiltrados = _filtrarPorStatus(status);

    // 2. Segundo Funil: Filtro da Barra de Busca
    if (_searchQuery.isNotEmpty) {
      chamadosFiltrados = chamadosFiltrados.where((c) {
        final query = _searchQuery.toLowerCase();
        final tituloMatches = c.titulo.toLowerCase().contains(query);
        final idMatches = c.id.toString().contains(query);
        return tituloMatches || idMatches;
      }).toList();
    }

    // Validação de lista vazia
    if (chamadosFiltrados.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? 'Nenhum chamado $status.' : 'Nenhum chamado encontrado.',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // 3. Desenha a lista final
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: chamadosFiltrados.length,
      itemBuilder: (context, index) {
        final chamado = chamadosFiltrados[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: status == 'Aberto'
                    ? const Color.fromARGB(162, 255, 244, 246)
                    : status == 'Em Andamento'
                        ? const Color.fromARGB(162, 255, 244, 246)
                        : const Color.fromARGB(162, 255, 244, 246),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment,
                color: status == 'Aberto'
                    ? Colors.red.shade700
                    : status == 'Em Andamento'
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
              ),
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
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketDetailView(chamado: chamado),
                ),
              );
              setState(() {});
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
            accountName: Text(
              'Arlisson Santos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('arlisson@email.com'),
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

         // Botão Novo Colaborador
         if (_isAdmin)
          ListTile(
            leading: const Icon(Icons.person_add_alt_1),
            title: const Text('Novo Colaborador'),
            onTap: () {
              Navigator.pop(context); // Fecha o menu lateral
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupView()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  } 

  // --------------------------------------------------------
  // Build Principal da Tela
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
        body: TabBarView(
          children: [
            _buildListaChamados('Aberto'),
            _buildListaChamados('Em Andamento'),
            _buildListaChamados('Resolvido'),
          ],
        ),
        drawer: _buildDrawer(context),
        floatingActionButton: FloatingActionButton.extended(
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
          icon: const Icon(Icons.add),
          label: const Text('Novo Chamado'),
        ),
      ),
    );
  }
}