import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ui/sf_content_header.dart';
import '../../auth/providers/auth_provider.dart';
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
  @override
  void initState() {
    super.initState();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [AppColors.ink900, AppColors.ink700],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SfContentHeader(
                title: 'Chamados',
                subtitle: hasCompany
                    ? 'Acompanhe e gerencie os chamados da operação.'
                    : 'Sua conta ainda não está vinculada a uma empresa.',
                variant: SfContentHeaderVariant.contrast,
                actions: [
                  if (hasCompany || isEmployee)
                    IconButton.filledTonal(
                      tooltip: 'Atualizar lista',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _refreshTickets,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  if (user != null)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 170),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (!hasCompany) NoCompanyBanner(forAdmin: isAdmin),
              Expanded(
                child: Consumer<TicketsProvider>(
                  builder: (context, ticketsState, _) {
                    if (ticketsState.loadingTickets &&
                        ticketsState.tickets.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.seed),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
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
                  builder: (context) => CreateTicketDialog(user: user!),
                ).then((_) => _refreshTickets());
              },
              label: const Text('Novo Chamado'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.seed,
              foregroundColor: Colors.white,
            )
          : null,
    );
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.seed.withValues(alpha: 0.35),
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
