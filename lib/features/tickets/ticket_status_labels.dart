/// Rótulos em PT-BR alinhados ao schema (`tickets.status`) e ao fluxo do GitBook.
String ticketStatusLabelPt(String status) {
  switch (status) {
    case 'open':
      return 'Aberto';
    case 'in_progress':
      return 'Em atendimento';
    case 'pending':
      return 'Pendente';
    case 'resolved':
      return 'Resolvido';
    case 'closed':
      return 'Finalizado';
    case 'cancelled':
      return 'Cancelado';
    default:
      return status;
  }
}
