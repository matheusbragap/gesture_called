import 'package:flutter/material.dart';
import '../../../core/constants/user_roles.dart';
import '../data/tickets_repository.dart';

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

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
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
          _tickets = await _repository.listTicketsForCompany(companyId);
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
}
