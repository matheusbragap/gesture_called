import 'package:flutter/material.dart';
import '../../../core/constants/user_roles.dart';
import '../data/tickets_repository.dart';

enum AttendantTicketsView { allCompany, inbox, mine }

class TicketsProvider extends ChangeNotifier {
  final _repository = TicketsRepository();

  bool _isLoading = false;
  bool _loadingTickets = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _tickets = [];

  bool get isLoading => _isLoading;
  bool get loadingTickets => _loadingTickets;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get tickets => _tickets;

  Future<void> loadCategories({required int companyId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getCategories(companyId);
    } catch (e) {
      _errorMessage = 'Erro ao carregar categorias.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTicketsForUser({
    required String userId,
    required String role,
    required int? companyId,
    AttendantTicketsView attendantView = AttendantTicketsView.allCompany,
  }) async {
    _loadingTickets = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (role == UserRoles.employee) {
        _tickets = await _repository.listTicketsForEmployee(userId);
      } else if (role == UserRoles.admin || role == UserRoles.attendant) {
        if (companyId == null) {
          _tickets = [];
        } else {
          final companyTickets = await _repository.listTicketsForCompany(
            companyId,
          );
          _tickets = _filterByView(
            companyTickets,
            userId: userId,
            view: attendantView,
          );
        }
      } else {
        _tickets = [];
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar chamados.';
      _tickets = [];
    } finally {
      _loadingTickets = false;
      notifyListeners();
    }
  }

  Future<bool> createTicket({
    required String title,
    required String description,
    required String creatorId,
    required int departmentId,
    required int categoryId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createTicket(
        title: title,
        description: description,
        creatorId: creatorId,
        departmentId: departmentId,
        categoryId: categoryId,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao criar chamado.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _filterByView(
    List<Map<String, dynamic>> rows, {
    required String userId,
    required AttendantTicketsView view,
  }) {
    switch (view) {
      case AttendantTicketsView.allCompany:
        return rows;
      case AttendantTicketsView.inbox:
        return rows.where((row) {
          final status = (row['status'] as String?) ?? '';
          final currentAttendantId = row['current_attendant_id'] as String?;
          final isOpen = status == 'open';
          final isWithAnotherAttendant =
              status == 'in_progress' &&
              currentAttendantId != null &&
              currentAttendantId != userId;
          return isOpen || isWithAnotherAttendant;
        }).toList();
      case AttendantTicketsView.mine:
        return rows.where((row) {
          final currentAttendantId = row['current_attendant_id'] as String?;
          return currentAttendantId != null && currentAttendantId == userId;
        }).toList();
    }
  }
}
