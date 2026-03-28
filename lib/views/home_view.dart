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
  // Lista de chamados simulada com mais dados para testarmos as abas
  final List<TicketModel> _chamados = [
    TicketModel(id: 1, titulo: 'Lâmpada queimada', descricao: 'Trocar no estoque', status: 'Aberto', unidadeOrigemId: 101),
    TicketModel(id: 2, titulo: 'Sistema lento', descricao: 'PDV 3 travando constantemente', status: 'Em Andamento', unidadeOrigemId: 101),
    TicketModel(id: 3, titulo: 'Impressora sem tinta', descricao: 'Trocar toner da impressora fiscal', status: 'Resolvido', unidadeOrigemId: 101),
    TicketModel(id: 4, titulo: 'Ar condicionado', descricao: 'Não está gelando', status: 'Aberto', unidadeOrigemId: 101),
  ];

  // Função limpa para filtrar a lista pela aba selecionada
  List<TicketModel> _filtrarPorStatus(String status) {
    return _chamados.where((c) => c.status == status).toList();
  }

  
  Widget _buildListaChamados(String status) {
    final chamadosFiltrados = _filtrarPorStatus(status);

    if (chamadosFiltrados.isEmpty) {
      return Center(
        child: Text('Nenhum chamado $status.', style: const TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: chamadosFiltrados.length,
      itemBuilder: (context, index) {
        final chamado = chamadosFiltrados[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: status == 'Aberto' ? Colors.red.shade50 : status == 'Em Andamento' ? Colors.orange.shade50 : Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment, 
                color: status == 'Aberto' ? Colors.red.shade700 : status == 'Em Andamento' ? Colors.orange.shade700 : Colors.green.shade700,
              ),
            ),
            title: Text(chamado.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(chamado.descricao, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // Próxima funcionalidade: Abrir os detalhes completos do chamado
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
            accountName: Text('Arlisson Santos', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Navigator.pop(context); // Fecha o menu lateral
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileView()),
              );
            },
          ),
          const Divider(), // Linha separadora
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/'); // Volta para o login
            },
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
          // Removemos o 'actions' daqui para a barra ficar limpa
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewTicketView()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Chamado'),
        ),
      ),
    );
  }
}