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
  Future<User> login({required String correo, required String password}) async {
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

      // Create user with real ID (organization will be fetched from profile)
      _currentUser = User(
        id: userId,
        nombre: userName.isNotEmpty ? userName : 'Usuario',
        correo: correo,
        organizacion: 'Empresa', // Default, will be updated from profile
        token: token,
      );

      // Fetch organization from profile
      try {
        final profile = await getProfile();
        if (profile != null && profile['organization'] != null) {
          _currentUser = _currentUser!.copyWith(
            organizacion: profile['organization'].toString(),
          );
        }
      } catch (e) {
        print('Error fetching organization from profile: $e');
      }

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
    String? cardHolderName,
    String? expirationDate,
    String? securityCode,
  }) async {
    try {
      // Step 1: Create User
      // Convert organization to role number: 0 = Empresa, 1 = Independiente
      final role = organizacion == 'Independiente' ? 1 : 0;

      await _apiClient.post(
        '/Users',
        body: {
          'name': nombre,
          'email': correo,
          'password': password,
          'role': role,
        },
      );

      // Step 2: Login to get token
      await login(correo: correo, password: password);

      // Step 3: Update Subscription (backend creates one automatically)
      // Map subscription name to enum/int if needed.
      // 0 = Free, 1 = Básico, 2 = Estándar, 3 = Premium
      int planType = 1; // Default to Básico
      if (subscription == 'Free' || subscription == 'Gratis') planType = 0;
      if (subscription == 'Básico') planType = 1;
      if (subscription == 'Estándar') planType = 2;
      if (subscription == 'Premium') planType = 3;

      try {
        // First, get the subscription ID created by the backend
        final sub = await getSubscription();
        if (sub == null) {
          print('Warning: No subscription found for user after registration');
        } else {
          final subId = sub['id'];
          // Update the subscription with payment details
          await _apiClient.put(
            '/Subscriptions/$subId',
            body: {
              'planType': planType,
              'cardLastFourDigits': last4Digits,
              'cardHolderName': cardHolderName,
              'paymentMethodType': paymentType,
              'expirationDate': expirationDate,
              'securityCode': securityCode,
              'isActive': true,
            },
            includeAuth: true,
          );
        }
      } catch (e) {
        // If subscription update fails, we still return the user but log the error
        // The user is created and logged in with default subscription.
        print('Error updating subscription: $e');
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

  /// Update user profile
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await _apiClient.put('/Users/$id', body: data, includeAuth: true);
    // Update local state
    updateCurrentUser(nombre: data['name'], organizacion: data['organization']);
  }

  /// Delete user account
  Future<void> deleteUser(int id) async {
    await _apiClient.delete('/Users/$id', includeAuth: true);
    logout();
  }

  /// Get full profile data
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _apiClient.get('/profile', includeAuth: true);
      return response;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// Update user subscription
  Future<void> updateSubscription(int id, Map<String, dynamic> data) async {
    await _apiClient.put('/Subscriptions/$id', body: data, includeAuth: true);
  }

  /// Get current user subscription
  Future<Map<String, dynamic>?> getSubscription() async {
    try {
      final response = await _apiClient.get(
        '/Subscriptions/me', // Assuming this endpoint exists based on standard REST patterns
        includeAuth: true,
      );
      return response;
    } catch (e) {
      print('Error fetching subscription: $e');
      return null;
    }
  }

  /// Get the API client instance
  ApiClient get apiClient => _apiClient;
}
