import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // En el futuro estos valores vendrán del backend / auth.
  final _nameCtrl = TextEditingController(text: 'Nombre de ejemplo');
  final _emailCtrl = TextEditingController(text: 'usuario@costealo.com');
  final _passwordCtrl = TextEditingController(text: '********');
  final _organizationCtrl = TextEditingController(text: 'Empresa');

  final _subscriptionCtrl = TextEditingController(text: 'Estándar');
  final _paymentMethodCtrl = TextEditingController(text: 'Tarjeta de débito');
  final _last4Ctrl = TextEditingController(text: '1234');
  final _expiryCtrl = TextEditingController(text: '05/28');
  final _cvvCtrl = TextEditingController(text: '***');

  bool _passwordVisible = false;
  bool _showUpgradeOptions = false;

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
      if (_passwordVisible && _passwordCtrl.text == '********') {
        _passwordCtrl.text = 'password-demo';
      } else if (!_passwordVisible) {
        _passwordCtrl.text = '********';
      }
    });
  }

  void _openPaymentScreen() {
    // Más adelante acá abrimos la pantalla de método de pago real.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Aquí se abrirá la pantalla para cambiar el método de pago.'),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Perfil del usuario',
                              style: textTheme.headlineMedium,
                            ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            color:
                                                Colors.grey.withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                // Más adelante: abrir selector de imagen
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Aquí podrás cambiar tu foto de perfil.'),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  Icons.edit_outlined),
                                              label: const Text('Editar'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    _buildLabel('Nombre'),
                                    TextField(
                                      controller: _nameCtrl,
                                    ),
                                    const SizedBox(height: 14),

                                    _buildLabel('Correo electrónico'),
                                    TextField(
                                      controller: _emailCtrl,
                                      keyboardType:
                                          TextInputType.emailAddress,
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
                                          onPressed: _togglePasswordVisibility,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          child: const Text('Ver opciones'),
                                        ),
                                      ],
                                    ),

                                    AnimatedCrossFade(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      firstChild: const SizedBox.shrink(),
                                      secondChild: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildUpgradeOption(
                                                'Básico · Bs 29,99/mes'),
                                            _buildUpgradeOption(
                                                'Estándar · Bs 49,99/mes'),
                                            _buildUpgradeOption(
                                                'Premium · Bs 89,99/mes'),
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
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
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
