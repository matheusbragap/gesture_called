import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/ui/sf_content_header.dart';
import '../../../core/widgets/ui/sf_glass_card.dart';
import '../../../core/widgets/ui/sf_list_tile_card.dart';
import '../../admin/data/departments_repository.dart';
import '../../admin/widgets/no_company_banner.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tickets/data/tickets_repository.dart';

class AttendantDepartmentsPage extends StatefulWidget {
  const AttendantDepartmentsPage({super.key});

  @override
  State<AttendantDepartmentsPage> createState() =>
      _AttendantDepartmentsPageState();
}

class _AttendantDepartmentsPageState extends State<AttendantDepartmentsPage> {
  final _departmentsRepo = DepartmentsRepository();
  final _ticketsRepo = TicketsRepository();

  List<Map<String, dynamic>> _departments = [];
  Map<int, int> _ticketCountByDepartment = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    final companyId = user?.companyId;

    if (companyId == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
        _departments = [];
        _ticketCountByDepartment = {};
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _departmentsRepo.listByCompany(companyId),
        _ticketsRepo.listTicketsForCompany(companyId),
      ]);

      final departments = List<Map<String, dynamic>>.from(results[0]);
      final tickets = List<Map<String, dynamic>>.from(results[1]);

      final counts = <int, int>{};
      for (final department in departments) {
        final raw = department['id'];
        if (raw is num) {
          counts[raw.toInt()] = 0;
        }
      }

      for (final ticket in tickets) {
        final raw = ticket['department_id'];
        if (raw is! num) continue;
        final departmentId = raw.toInt();
        counts[departmentId] = (counts[departmentId] ?? 0) + 1;
      }

      if (!mounted) return;
      setState(() {
        _departments = departments;
        _ticketCountByDepartment = counts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar departamentos da empresa.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;
    final hasCompany = user?.companyId != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SfContentHeader(
              title: 'Departamentos',
              subtitle: 'Lojas da empresa e quantidade de chamados por loja.',
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!hasCompany) const NoCompanyBanner(forAdmin: false),
                    if (hasCompany) ...[
                      SfInfoCard(
                        icon: Icons.store_mall_directory_rounded,
                        tint: cs.tertiary,
                        child: Text(
                          'Visualização operacional dos departamentos e do volume '
                          'de chamados em cada loja.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: cs.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Expanded(
                      child: !hasCompany
                          ? const SizedBox.shrink()
                          : _loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: cs.primary,
                                  ),
                                )
                              : _departments.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Nenhum departamento cadastrado.',
                                        style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      itemCount: _departments.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final row = _departments[index];
                                        final id = (row['id'] as num).toInt();
                                        final name =
                                            row['name'] as String? ?? 'Loja';
                                        final location =
                                            row['location'] as String?;
                                        final description =
                                            row['description'] as String?;
                                        final ticketCount =
                                            _ticketCountByDepartment[id] ?? 0;

                                        final subtitleParts = <String>[];
                                        if (location != null &&
                                            location.isNotEmpty) {
                                          subtitleParts.add(location);
                                        }
                                        if (description != null &&
                                            description.isNotEmpty) {
                                          subtitleParts.add(description);
                                        }

                                        return SfListTileCard(
                                          title: name,
                                          subtitle: subtitleParts.isEmpty
                                              ? null
                                              : subtitleParts.join(' · '),
                                          leading: CircleAvatar(
                                            backgroundColor: cs
                                                .tertiaryContainer
                                                .withValues(alpha: 0.95),
                                            foregroundColor: cs.tertiary,
                                            child: const Icon(
                                              Icons.storefront_rounded,
                                              size: 20,
                                            ),
                                          ),
                                          trailing: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 7,
                                                ),
                                            decoration: BoxDecoration(
                                              color: cs.primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              '$ticketCount chamado${ticketCount == 1 ? '' : 's'}',
                                              style: TextStyle(
                                                color: cs.onPrimaryContainer,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
