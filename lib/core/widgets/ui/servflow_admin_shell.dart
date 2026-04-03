import 'package:flutter/material.dart';

import 'sf_content_header.dart';

/// Layout admin de conteúdo com cabeçalho e área rolável.
class ServflowAdminShell extends StatelessWidget {
  const ServflowAdminShell({
    super.key,
    required this.title,
    this.subtitle,
    required this.userName,
    required this.currentRoute,
    required this.body,
    this.floatingActionButton,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final String userName;
  final String currentRoute;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SfContentHeader(
              title: title,
              subtitle: subtitle,
              actions: actions,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
