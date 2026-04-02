import 'package:flutter/material.dart';

enum SfContentHeaderVariant { standard, contrast }

class SfContentHeader extends StatelessWidget {
  const SfContentHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 12),
    this.variant = SfContentHeaderVariant.standard,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;
  final SfContentHeaderVariant variant;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final titleColor = switch (variant) {
      SfContentHeaderVariant.standard => cs.onSurface,
      SfContentHeaderVariant.contrast => Colors.white,
    };

    final subtitleColor = switch (variant) {
      SfContentHeaderVariant.standard => cs.onSurfaceVariant,
      SfContentHeaderVariant.contrast => Colors.white.withValues(alpha: 0.82),
    };

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: tt.bodySmall?.copyWith(
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            IconTheme(
              data: IconThemeData(color: titleColor),
              child: Wrap(spacing: 8, runSpacing: 8, children: actions!),
            ),
        ],
      ),
    );
  }
}
