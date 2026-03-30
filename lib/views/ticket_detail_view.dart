import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../models/profile_model.dart';

class TicketDetailView extends StatefulWidget {
  final TicketModel chamado;

  const TicketDetailView({super.key, required this.chamado});

  @override
  State<TicketDetailView> createState() => _TicketDetailViewState();
}

class _TicketDetailViewState extends State<TicketDetailView> {
  Color _getCorStatus(String status) {
    switch (status) {
      case 'Aberto': return Colors.red.shade700;
      case 'Em Andamento': return Colors.orange.shade700;
      case 'Resolvido': return Colors.green.shade700;
      default: return Colors.grey;
    }
  }

  void _atualizarStatus() {
    setState(() {
      if (widget.chamado.status == 'Aberto') {
        widget.chamado.status = 'Em Andamento';
        widget.chamado.atendenteId = 'Arlisson (Técnico)'; // Simula você assumindo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você assumiu este chamado!')),
        );
      } else if (widget.chamado.status == 'Em Andamento') {
        widget.chamado.status = 'Resolvido';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chamado finalizado com sucesso!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final corStatus = _getCorStatus(widget.chamado.status);
    
    // Lógica da Máquina de Estados para a UI
    String textoBotao;
    IconData iconeBotao;
    bool botaoHabilitado = true;

    if (widget.chamado.status == 'Aberto') {
      textoBotao = 'ASSUMIR CHAMADO';
      iconeBotao = Icons.back_hand;
    } else if (widget.chamado.status == 'Em Andamento') {
      textoBotao = 'RESOLVER CHAMADO';
      iconeBotao = Icons.check_circle;
    } else {
      textoBotao = 'CHAMADO FINALIZADO';
      iconeBotao = Icons.lock;
      botaoHabilitado = false; // Trava o botão
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chamado #${widget.chamado.id}'),
        backgroundColor: corStatus,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: corStatus.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: corStatus),
              ),
              child: Text(
                widget.chamado.status.toUpperCase(),
                style: TextStyle(color: corStatus, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.chamado.titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Divider(height: 40),
            const Text('DESCRIÇÃO', style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text(widget.chamado.descricao, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 30),
            
            // Mostra quem assumiu o chamado, se houver
            if (widget.chamado.atendenteId != null) ...[
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.support_agent, color: Colors.blue),
                title: const Text('Atendente Responsável'),
                subtitle: Text(widget.chamado.atendenteId!),
              ),
            ],
          ],
        ),
      ),
      
      bottomNavigationBar: usuarioLogado.isTecnico 
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  onPressed: botaoHabilitado ? _atualizarStatus : null,
                  icon: Icon(iconeBotao),
                  label: Text(textoBotao),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corStatus,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Apenas a equipe de TI pode alterar o status deste chamado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            ),
    );
  }
}