import 'package:flutter/material.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _repository = AuthRepository();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.login(email, password);
    } catch (e) {
      _errorMessage = 'Email ou senha incorretos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> checkSession() async {
    _user = await _repository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> checkEmailExists(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.checkEmailExists(email);
    } catch (e) {
      _errorMessage = 'Erro ao verificar email.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    _user = await _repository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.register(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao cadastrar. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfileName(String name) async {
    final currentUser = _user;
    if (currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProfileName(userId: currentUser.id, name: name);
      _user = await _repository.getCurrentUser();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível atualizar o nome.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> leaveCurrentCompany() async {
    final currentUser = _user;
    if (currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.leaveCompany(userId: currentUser.id);
      _user = await _repository.getCurrentUser();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível sair da empresa.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
