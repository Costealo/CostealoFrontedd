import 'package:costealoo/models/user.dart';
import 'package:costealoo/services/api_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Login with email and password
  /// Returns the authenticated User on success
  /// Throws ApiException on failure
  Future<User> login({
    required String correo,
    required String password,
    String? organizacion,
  }) async {
    try {
      // Call the API login endpoint
      final response = await _apiClient.post(
        '/Auth/login',
        body: {'email': correo, 'password': password},
      );

      // Backend returns the token as a plain string, which our ApiClient wraps in {'token': ...}
      final token =
          response['token'] as String? ?? response['data'] as String? ?? '';

      // Store the token in the API client for future requests
      _apiClient.setToken(token);

      // Decode token to get User ID
      int userId = 0;
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        // Look for common ID claims - backend uses 'nameid'
        if (decodedToken.containsKey('nameid')) {
          userId = int.tryParse(decodedToken['nameid'].toString()) ?? 0;
        } else if (decodedToken.containsKey('id')) {
          userId = int.tryParse(decodedToken['id'].toString()) ?? 0;
        } else if (decodedToken.containsKey('sub')) {
          userId = int.tryParse(decodedToken['sub'].toString()) ?? 0;
        } else if (decodedToken.containsKey('UserId')) {
          userId = int.tryParse(decodedToken['UserId'].toString()) ?? 0;
        }

        print('Decoded Token: $decodedToken');
        print('Extracted User ID: $userId');
      } catch (e) {
        print('Error decoding token: $e');
      }

      // Create initial user object
      _currentUser = User(
        id: userId,
        nombre: '', // Placeholder, will be updated by fetchUserProfile
        correo: correo,
        organizacion: organizacion ?? 'Empresa',
        token: token,
      );

      // Fetch full user profile if we have an ID
      if (userId != 0) {
        try {
          await fetchUserProfile(userId);
        } catch (e) {
          print('Error fetching profile: $e');
        }
      }

      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch user profile from backend
  Future<void> fetchUserProfile(int userId) async {
    try {
      final response = await _apiClient.get(
        '/Users/$userId',
        includeAuth: true,
      );

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          id: response['id'] is int
              ? response['id']
              : int.tryParse(response['id'].toString()) ?? userId,
          nombre:
              response['nombre'] ?? response['name'] ?? _currentUser!.nombre,
          correo:
              response['email'] ?? response['correo'] ?? _currentUser!.correo,
          organizacion: response['organizacion'] ?? _currentUser!.organizacion,
          tipoSuscripcion: response['tipoSuscripcion'],
          tarjetaUltimos4Digitos: response['tarjetaUltimos4Digitos'],
          tarjetaCodigoSeguridad: response['tarjetaCodigoSeguridad'],
          tarjetaFechaVencimiento: response['tarjetaFechaVencimiento'],
        );
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      // Don't rethrow, just log
    }
  }

  /// Register a new user
  /// Returns the authenticated User on success
  /// Throws ApiException on failure
  Future<User> register({
    required String nombre,
    required String correo,
    required String password,
    required String organizacion,
    String? subscription,
    String? paymentType,
    String? last4Digits,
    String? expiryDate,
    String? cvv,
  }) async {
    try {
      // 1. Call the API register endpoint
      await _apiClient.post(
        '/Auth/register',
        body: {'nombre': nombre, 'email': correo, 'password': password},
      );

      // 2. Login to get the token and user ID
      final user = await login(
        correo: correo,
        password: password,
        organizacion: organizacion,
      );

      // 3. Update user profile with extra details
      if (user.id != 0) {
        try {
          await _apiClient.put(
            '/Users/${user.id}',
            body: {
              'nombre': nombre,
              'tipoUsuario': 'user', // Default
              'tipoSuscripcion': subscription ?? 'Básico',
              'tarjetaUltimos4Digitos': last4Digits,
              'tarjetaCodigoSeguridad': cvv,
              'tarjetaFechaVencimiento': expiryDate,
              // 'organizacion': organizacion, // Not in UpdateUserProfileDto
            },
            includeAuth: true,
          );

          // Refresh local user data
          await fetchUserProfile(user.id);
        } catch (e) {
          print('Error updating profile after registration: $e');
          // Continue, as the user is created and logged in
        }
      }

      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout the current user
  void logout() {
    _currentUser = null;
    _apiClient.setToken(null);
  }

  /// Update current user details locally
  void updateCurrentUser({String? nombre, String? organizacion}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        nombre: nombre,
        organizacion: organizacion,
      );
    }
  }

  /// Get the API client instance
  ApiClient get apiClient => _apiClient;
}
