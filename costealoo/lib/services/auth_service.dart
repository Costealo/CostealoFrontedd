import 'package:costealoo/services/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<void> login(String email, String password) async {
    try {
      // Asumiendo que el endpoint es /api/Auth/login
      // Ajustar si el endpoint real es diferente
      await _apiClient.post('/api/Auth/login', {
        'email': email,
        'password': password,
      });
      
      // Aquí normalmente guardaríamos el token o usuario
      // Por ahora solo validamos que no lance error
      
    } catch (e) {
      // Re-lanzar errores específicos para que la UI los maneje
      final msg = e.toString().toLowerCase();
      
      // Mapear errores comunes de login
      if (msg.contains('not found') || 
          msg.contains('usuario no encontrado') || 
          msg.contains('user not found') ||
          msg.contains('404') ||
          msg.contains('400') || // A veces es bad request
          msg.contains('401') || // Unauthorized
          msg.contains('unauthorized') ||
          msg.contains('invalid credentials')) {
        throw Exception('Usuario no registrado');
      }
      rethrow;
    }
  }
}
