import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/services/auth_service.dart';

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
  bool _showUpgradeOptions = false;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _nameCtrl.text = user.nombre;
        _emailCtrl.text = user.correo;
        _organizationCtrl.text = user.organizacion;
      }

      final sub = await _authService.getSubscription();
      if (sub != null) {
        // Map plan type int to string if needed
        final planType = sub['planType'];
        String planName = 'Básico';
        if (planType == 1) planName = 'Estándar';
        if (planType == 2) planName = 'Premium';

        _subscriptionCtrl.text = planName;
        _paymentMethodCtrl.text = sub['paymentMethodType'] ?? 'Tarjeta';
        _last4Ctrl.text = sub['cardLastFourDigits'] ?? '****';
      } else {
        _subscriptionCtrl.text = 'Gratis / Sin suscripción';
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_nameCtrl.text.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        await _authService.updateUser(user.id, {
          'id': user.id,
          'name': _nameCtrl.text,
          'email': _emailCtrl
              .text, // Usually email is not editable or requires re-auth
          'organization': _organizationCtrl.text,
          // 'password': ... // Password change usually requires separate flow
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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

  void _openPaymentScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Aquí se abrirá la pantalla para cambiar el método de pago.',
        ),
      ),
    );
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
                                    ElevatedButton.icon(
                                      onPressed: _isSaving
                                          ? null
                                          : _saveChanges,
                                      icon: _isSaving
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.save),
                                      label: const Text('Guardar Cambios'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: CostealoColors.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
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
                                                radius: 40,
                                                backgroundColor:
                                                    CostealoColors.cardSoft,
                                                child: Icon(
                                                  Icons.person_outline,
                                                  size: 48,
                                                  color: Colors.grey.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Aquí podrás cambiar tu foto de perfil.',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                    ),
                                                    label: const Text('Editar'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),

                                          _buildLabel('Nombre'),
                                          TextField(controller: _nameCtrl),
                                          const SizedBox(height: 14),

                                          _buildLabel('Correo electrónico'),
                                          TextField(
                                            controller: _emailCtrl,
                                            readOnly:
                                                true, // Email usually immutable
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
                                            readOnly: true,
                                            decoration: InputDecoration(
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
                                                onPressed: () {
                                                  setState(() {
                                                    _showUpgradeOptions =
                                                        !_showUpgradeOptions;
                                                  });
                                                },
                                                child: const Text(
                                                  'Ver opciones',
                                                ),
                                              ),
                                            ],
                                          ),

                                          AnimatedCrossFade(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            firstChild: const SizedBox.shrink(),
                                            secondChild: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildUpgradeOption(
                                                    'Básico · Bs 29,99/mes',
                                                  ),
                                                  _buildUpgradeOption(
                                                    'Estándar · Bs 49,99/mes',
                                                  ),
                                                  _buildUpgradeOption(
                                                    'Premium · Bs 89,99/mes',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            crossFadeState: _showUpgradeOptions
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst,
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
                                              onPressed: _openPaymentScreen,
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

  Widget _buildUpgradeOption(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _subscriptionCtrl.text = text.split('·').first.trim();
          });
        },
        child: Row(
          children: [
            const Icon(Icons.arrow_right, size: 18),
            const SizedBox(width: 4),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
