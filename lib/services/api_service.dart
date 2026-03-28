import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

// 1. Exceção customizada para manter os erros limpos
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = "http://localhost:3000/api";
  static const int _timeoutInSeconds = 10;

  // 2. Construtor privado de headers (evita repetição em cada método)
  static Map<String, String> _buildHeaders(String? token) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 3. Validador centralizado de respostas
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      // Tenta extrair a mensagem de erro da API Node.js ou usa um padrão
      final errorBody = jsonDecode(response.body);
      throw ApiException(errorBody['message'] ?? 'Erro no servidor: ${response.statusCode}');
    }
  }

  // MÉTODOS HTTP

  static Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _buildHeaders(token))
          .timeout(const Duration(seconds: _timeoutInSeconds));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('A conexão expirou. Verifique sua internet.');
    } catch (e) {
      throw ApiException('Falha ao processar a requisição: $e');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'), 
            headers: _buildHeaders(token), 
            body: jsonEncode(body)
          )
          .timeout(const Duration(seconds: _timeoutInSeconds));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('A conexão expirou. Verifique sua internet.');
    } catch (e) {
      throw ApiException('Falha ao processar a requisição: $e');
    }
  }
}