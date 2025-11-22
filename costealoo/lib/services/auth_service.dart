import 'package:costealoo/services/api_client.dart';
import 'package:costealoo/models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  
  // Simple in-memory storage for the current session
  static UserModel? currentUser;

  Future<void> login(String email, String password) async {
    try {
      // Asumiendo que el endpoint es /api/Auth/login
      // Ajustar si el endpoint real es diferente
      final response = await _apiClient.post('/api/Auth/login', {
        'email': email,
        'password': password,
      });
      
      // El backend devuelve el token como string plano o en un JSON
      String token = '';
      if (response is Map && response.containsKey('token')) {
        token = response['token'];
      } else if (response is String) {
        token = response;
      }

      if (token.isNotEmpty) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        currentUser = UserModel.fromJson(decodedToken);
      }
      
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

  Future<void> register(String name, String email, String password) async {
    try {
      await _apiClient.post('/api/Auth/register', {
        'nombre': name,
        'email': email,
        'password': password,
      });
      
      // Después de registrar, iniciamos sesión automáticamente
      await login(email, password);
    } catch (e) {
      rethrow;
    }
  }
}
