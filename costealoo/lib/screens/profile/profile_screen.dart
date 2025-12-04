import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/services/auth_service.dart';
import 'package:costealoo/screens/profile/subscription_edit_screen.dart';
import 'package:costealoo/screens/profile/subscription_plan_screen.dart';
import 'package:costealoo/routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(text: '********');
  final _organizationCtrl = TextEditingController();

  final _subscriptionCtrl = TextEditingController(text: 'Cargando...');
  final _paymentMethodCtrl = TextEditingController(text: '****');
  final _last4Ctrl = TextEditingController(text: '****');
  final _expiryCtrl = TextEditingController(text: '**/**');
  final _cvvCtrl = TextEditingController(text: '***');

  bool _passwordVisible = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _authService.getProfile();

      if (profile != null) {
        // Populate User Data
        _nameCtrl.text = profile['userName'] ?? '';
        _emailCtrl.text = profile['email'] ?? '';
        _organizationCtrl.text = profile['organization'] ?? '';

        // Populate Password
        final password = profile['password'];
        if (password != null && password.toString().isNotEmpty) {
          _passwordCtrl.text = password.toString();
        } else {
          _passwordCtrl.text = '********';
        }

        // Populate Subscription Data
        final planType = profile['planType'];
        String planName = 'Free'; // Default for planType == 0
        if (planType == 1) planName = 'Básico';
        if (planType == 2) planName = 'Estándar';
        if (planType == 3) planName = 'Premium';
        _subscriptionCtrl.text = planName;

        // Populate Payment Data
        _paymentMethodCtrl.text = profile['paymentMethodType'] ?? 'Tarjeta';
        _last4Ctrl.text = profile['cardLastFourDigits'] ?? '****';

        // Expiration Date
        final expiryValue = profile['expirationDate'];
        if (expiryValue != null) {
          _expiryCtrl.text = expiryValue.toString();
        } else {
          _expiryCtrl.text = '**/**';
        }

        // Security Code (CVV)
        final securityCode = profile['securityCode'];
        if (securityCode != null && securityCode.toString().isNotEmpty) {
          _cvvCtrl.text = securityCode.toString();
        } else {
          _cvvCtrl.text = '***';
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editPlan() async {
    // Map current plan name to int
    int currentPlan = 0;
    if (_subscriptionCtrl.text == 'Estándar') currentPlan = 1;
    if (_subscriptionCtrl.text == 'Premium') currentPlan = 2;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SubscriptionPlanScreen(currentPlanType: currentPlan),
      ),
    );

    if (result == true) {
      _loadUserData(); // Refresh data if updated
    }
  }

  Future<void> _editPaymentMethod() async {
    // Get current profile data to pass
    final profileData = {
      'paymentMethodType': _paymentMethodCtrl.text,
      'cardLastFourDigits': _last4Ctrl.text,
      'expirationDate': _expiryCtrl.text,
      'securityCode': _cvvCtrl.text,
      'userName': _nameCtrl.text,
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SubscriptionEditScreen(currentProfile: profileData),
      ),
    );

    if (result == true) {
      _loadUserData(); // Refresh data if updated
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _organizationCtrl.dispose();
    _subscriptionCtrl.dispose();
    _paymentMethodCtrl.dispose();
    _last4Ctrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final user = _authService.currentUser;
        if (user != null) {
          await _authService.deleteUser(user.id);
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.welcome,
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar cuenta: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Row(
        children: [
          const SidebarMenu(),
          Expanded(
            child: Container(
              color: CostealoColors.primaryLight,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Perfil del usuario',
                                      style: textTheme.headlineMedium,
                                    ),
                                    // "Guardar Cambios" button removed as per request
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // FILA PRINCIPAL: datos usuario (izquierda) + suscripción / pago (derecha)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // IZQUIERDA: avatar + datos básicos
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    CostealoColors.primary,
                                                child: Text(
                                                  _nameCtrl.text.isNotEmpty
                                                      ? _nameCtrl.text[0]
                                                            .toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              // "Editar" button removed as per request
                                            ],
                                          ),
                                          const SizedBox(height: 24),

                                          _buildLabel('Nombre'),
                                          TextField(
                                            controller: _nameCtrl,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Color(0xFFF5F5F5),
                                            ),
                                          ),
                                          const SizedBox(height: 14),

                                          _buildLabel('Correo electrónico'),
                                          TextField(
                                            controller: _emailCtrl,
                                            readOnly: true,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Color(0xFFF5F5F5),
                                            ),
                                          ),
                                          const SizedBox(height: 14),

                                          _buildLabel('Contraseña'),
                                          TextField(
                                            controller: _passwordCtrl,
                                            obscureText: !_passwordVisible,
                                            readOnly: true, // Also read-only
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: const Color(
                                                0xFFF5F5F5,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _passwordVisible
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed:
                                                    _togglePasswordVisibility,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 14),

                                          _buildLabel('Organización'),
                                          TextField(
                                            controller: _organizationCtrl,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Color(0xFFF5F5F5),
                                            ),
                                          ),
                                          const SizedBox(height: 105),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton(
                                              onPressed: _deleteAccount,
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text(
                                                'Eliminar cuenta',
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 32),

                                    // DERECHA: suscripción + método de pago
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Suscripción'),
                                          TextField(
                                            controller: _subscriptionCtrl,
                                            readOnly: true,
                                          ),
                                          const SizedBox(height: 8),

                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '¿Quieres cambiar tu suscripción?\n'
                                                  '¡Mejórala aquí!',
                                                  style: textTheme.bodyMedium,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: _editPlan,
                                                child: const Text(
                                                  'Ver opciones',
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 20),

                                          _buildLabel('Método de pago'),
                                          TextField(
                                            controller: _paymentMethodCtrl,
                                            readOnly: true,
                                          ),
                                          const SizedBox(height: 12),

                                          _buildLabel('Últimos 4 dígitos'),
                                          TextField(
                                            controller: _last4Ctrl,
                                            readOnly: true,
                                          ),
                                          const SizedBox(height: 12),

                                          _buildLabel('Fecha de vencimiento'),
                                          TextField(
                                            controller: _expiryCtrl,
                                            readOnly: true,
                                          ),
                                          const SizedBox(height: 12),

                                          _buildLabel('Código de seguridad'),
                                          TextField(
                                            controller: _cvvCtrl,
                                            readOnly: true,
                                          ),
                                          const SizedBox(height: 16),

                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: _editPaymentMethod,
                                              child: const Text(
                                                'Cambiar método de pago',
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
