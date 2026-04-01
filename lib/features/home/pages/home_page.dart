import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/widgets/admin_app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == 'admin';

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('ServFlow'),
      ),
      drawer: isAdmin
          ? AdminAppDrawer(
              userName: user?.name ?? 'Usuário',
              currentRoute: '/home',
            )
          : Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    child: Text(user?.name ?? 'Usuario'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.assignment),
                    title: const Text('Chamados'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/tickets');
                    },
                  ),
                ],
              ),
            ),
      body: const Center(
        child: Text('Pagina inicial'),
      ),
    );
  }
}
