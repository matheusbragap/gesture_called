import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/user_roles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/widgets/admin_app_drawer.dart';
import '../../admin/widgets/no_company_banner.dart';
import '../providers/tickets_provider.dart';
import '../ticket_status_labels.dart';
import 'create_ticket_dialog.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshTickets());
  }

  void _refreshTickets() {
    final auth = context.read<AuthProvider>();
    final u = auth.user;
    if (u == null) return;
    context.read<TicketsProvider>().loadTicketsForUser(
          userId: u.id,
          role: u.role,
          companyId: u.companyId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final userRole = user?.role;
    final isAdmin = userRole == UserRoles.admin;
    final isEmployee = userRole == UserRoles.employee;
    final isAttendant = userRole == UserRoles.attendant;
    final hasCompany = user?.companyId != null;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Color(0xFF8B5CF6)),
            SizedBox(width: 12),
            Text(
              'ServFlow',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          if (hasCompany || isEmployee)
            IconButton(
              tooltip: 'Atualizar lista',
              icon: const Icon(Icons.refresh),
              onPressed: _refreshTickets,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                user?.name ?? 'Usuário',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: isAdmin
          ? AdminAppDrawer(
              userName: user?.name ?? 'Usuário',
              currentRoute: '/tickets',
            )
          : _buildStaffDrawer(
              userName: user?.name ?? 'Usuário',
              role: userRole,
            ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasCompany) NoCompanyBanner(forAdmin: isAdmin),
              Expanded(
                child: Consumer<TicketsProvider>(
                  builder: (context, ticketsState, _) {
                    if (ticketsState.loadingTickets &&
                        ticketsState.tickets.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B5CF6),
                        ),
                      );
                    }
                    if (ticketsState.errorMessage != null &&
                        ticketsState.tickets.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            ticketsState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    }
                    if (ticketsState.tickets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum chamado ainda',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _emptyStateHint(
                                  hasCompany: hasCompany,
                                  role: userRole,
                                  isAdmin: isAdmin,
                                  isEmployee: isEmployee,
                                  isAttendant: isAttendant,
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                      itemCount: ticketsState.tickets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        return _TicketCard(row: ticketsState.tickets[i]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isEmployee && hasCompany
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CreateTicketDialog(
                    user: user!,
                  ),
                ).then((_) => _refreshTickets());
              },
              label: const Text('Novo Chamado'),
              icon: const Icon(Icons.add),
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  /// Drawer para funcionário e atendente: ambos acessam Chamados (não é exclusivo do admin).
  Widget _buildStaffDrawer({
    required String userName,
    required String? role,
  }) {
    final badge = _roleBadgeLabel(role);
    final icon = role == UserRoles.attendant
        ? Icons.headset_mic_outlined
        : Icons.person_outline;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF6366F1),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.assignment,
                    label: 'Chamados',
                    isActive: true,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: _buildDrawerItem(
                icon: Icons.logout,
                label: 'Sair',
                isLogout: true,
                onTap: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pop(context);
                  context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? const Color(0xFF8B5CF6)
              : isLogout
                  ? Colors.red.shade600
                  : Colors.grey.shade700,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive
                ? const Color(0xFF8B5CF6)
                : isLogout
                    ? Colors.red.shade600
                    : Colors.grey.shade700,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  static String _roleBadgeLabel(String? role) {
    switch (role) {
      case UserRoles.employee:
        return 'Funcionário';
      case UserRoles.attendant:
        return 'Atendente';
      default:
        return 'Usuário';
    }
  }

  static String _emptyStateHint({
    required bool hasCompany,
    required String? role,
    required bool isAdmin,
    required bool isEmployee,
    required bool isAttendant,
  }) {
    if (!hasCompany) {
      if (isAdmin) {
        return 'Cadastre uma empresa para habilitar departamentos, categorias e o fluxo de chamados.';
      }
      return 'Aguarde o administrador vincular sua conta à empresa para usar os chamados.';
    }
    if (isEmployee) {
      return 'Abra um novo chamado para começar (perfil funcionário).';
    }
    if (isAttendant) {
      return 'Visualize e assuma chamados da empresa aqui (perfil atendente).';
    }
    if (isAdmin) {
      return 'Como administrador, você acompanha a operação; funcionários abrem chamados e atendentes tratam.';
    }
    return 'Você verá os chamados aqui.';
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.row});

  final Map<String, dynamic> row;

  static String? _name(dynamic embed) {
    if (embed is Map) return embed['name'] as String?;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = row['title'] as String? ?? '';
    final status = row['status'] as String? ?? '';
    final dept = _name(row['departments']);
    final cat = _name(row['categories']);

    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticketStatusLabelPt(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (dept != null || cat != null) ...[
                const SizedBox(height: 8),
                Text(
                  [
                    if (dept != null) 'Loja: $dept',
                    if (cat != null) 'Categoria: $cat',
                  ].join(' · '),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
