import 'dart:convert';
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
        '/Auth/login',
        body: {'email': correo, 'password': password},
      );

      // Backend returns the token as a plain string or in a wrapper
      final token =
          response['token'] as String? ?? response['data'] as String? ?? '';

      if (token.isEmpty) {
        throw ApiException(message: 'No se recibió token', statusCode: 401);
      }

      // Store the token immediately
      _apiClient.setToken(token);

      // Decode token to get user ID and other info
      int userId = 0;
      String userName = '';
      try {
        final Map<String, dynamic> payload = _decodeToken(token);
        // Look for nameid (standard) or sub or custom fields
        // Azure/ASP.NET usually uses http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier
        // or just 'nameid' or 'sub'
        if (payload.containsKey('nameid')) {
          userId = int.tryParse(payload['nameid'].toString()) ?? 0;
        } else if (payload.containsKey(
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
        )) {
          userId =
              int.tryParse(
                payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
                    .toString(),
              ) ??
              0;
        } else if (payload.containsKey('sub')) {
          // 'sub' is sometimes the ID, sometimes the email
          final sub = payload['sub'].toString();
          if (int.tryParse(sub) != null) {
            userId = int.parse(sub);
          }
        }

        if (payload.containsKey('unique_name')) {
          userName = payload['unique_name'].toString();
        } else if (payload.containsKey('name')) {
          userName = payload['name'].toString();
        }
      } catch (e) {
        print('Error decoding token: $e');
      }

      // Create user with real ID
      _currentUser = User(
        id: userId,
        nombre: userName.isNotEmpty ? userName : (organizacion ?? 'Usuario'),
        correo: correo,
        organizacion: organizacion ?? 'Empresa',
        token: token,
      );

      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = parts[1];
    String normalized = base64Url.normalize(payload);
    String decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded);
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
      // Step 1: Create User
      await _apiClient.post(
        '/Users',
        body: {
          'name': nombre,
          'email': correo,
          'password': password,
          'role': 1, // Default to User role
        },
      );

      // Step 2: Login to get token
      await login(
        correo: correo,
        password: password,
        organizacion: organizacion,
      );

      // Step 3: Create Subscription
      // Map subscription name to enum/int if needed.
      // Assuming 'Básico' -> 0, 'Estándar' -> 1, 'Premium' -> 2
      int planType = 0;
      if (subscription == 'Estándar') planType = 1;
      if (subscription == 'Premium') planType = 2;

      try {
        await _apiClient.post(
          '/Subscriptions',
          body: {
            'planType': planType,
            'cardLastFourDigits': last4Digits,
            'paymentMethodType': paymentType,
            // Add other fields if required by backend
            'isActive': true,
          },
          includeAuth: true,
        );
      } catch (e) {
        // If subscription fails, we still return the user but maybe log the error
        // or show a warning. The user is created and logged in.
        print('Error creating subscription: $e');
      }

      // Update local user name since login might not have it
      updateCurrentUser(nombre: nombre, organizacion: organizacion);

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
