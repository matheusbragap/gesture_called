import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/ui/sf_glass_card.dart';

/// Aviso quando não há empresa vinculada ao perfil.
class NoCompanyBanner extends StatelessWidget {
  const NoCompanyBanner({
    super.key,
    this.forAdmin = true,
  });

  final bool forAdmin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SfInfoCard(
        icon: Icons.apartment_rounded,
        tint: Colors.amber.shade800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              forAdmin ? 'Configure sua empresa' : 'Aguardando vínculo',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              forAdmin
                  ? 'Cadastre a empresa para liberar lojas, categorias, usuários e o fluxo completo de chamados.'
                  : 'Funcionários e atendentes precisam estar vinculados a uma empresa. Solicite ao administrador.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            if (forAdmin) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.go('/company'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Ir para Empresa'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
