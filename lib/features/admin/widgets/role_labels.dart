import '../../../core/constants/user_roles.dart';

String roleLabelPt(String role) {
  switch (role) {
    case UserRoles.admin:
      return 'Administrador';
    case UserRoles.employee:
      return 'Funcionário';
    case UserRoles.attendant:
      return 'Atendente';
    default:
      return role;
  }
}
