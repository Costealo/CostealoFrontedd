import 'package:costealoo/models/user.dart';
import 'package:costealoo/services/api_client.dart';

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
        '/Auth/login', // Note: Capital 'A' in Auth
        body: {
          'email': correo, // Backend expects 'email', not 'correo'
          'password': password,
        },
      );

      // Backend returns the token as a plain string, which our ApiClient wraps in {'token': ...}
      final token =
          response['token'] as String? ?? response['data'] as String? ?? '';

      // Create a user object
      // Note: Backend doesn't return user info on login, only the token
      _currentUser = User(
        id: 0, // Placeholder
        nombre: '', // Placeholder
        correo: correo,
        organizacion: organizacion ?? 'Empresa',
        token: token,
      );

      // Store the token in the API client for future requests
      _apiClient.setToken(token);

      return _currentUser!;
    } catch (e) {
      rethrow;
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
  }) async {
    try {
      // Call the API register endpoint
      // Note: Backend RegisterDto only accepts nombre, email, and password
      await _apiClient.post(
        '/Auth/register', // Note: Capital 'A' in Auth
        body: {
          'nombre': nombre,
          'email': correo, // Backend expects 'email', not 'correo'
          'password': password,
          // Backend doesn't support organizacion, subscription, paymentType, or last4Digits
        },
      );

      // Backend doesn't return user data on registration
      // Create a user object with the provided data
      _currentUser = User(
        id: 0, // Placeholder
        nombre: nombre,
        correo: correo,
        organizacion: organizacion,
        token: null, // Register doesn't return a token
      );

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
