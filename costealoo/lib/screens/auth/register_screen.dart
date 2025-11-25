import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/services/auth_service.dart';
import 'package:costealoo/services/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;

  // Paso 1
  final _formKeyStep1 = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _organization = 'Empresa';

  // Paso 2
  final _formKeyStep2 = GlobalKey<FormState>();
  String _subscription = 'Básico';
  String _paymentType = 'Tarjeta de débito';
  final _last4Ctrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _last4Ctrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _goToStep2OrRegister() {
    if (!_formKeyStep1.currentState!.validate()) return;

    // Ahora ambos tipos de organización van al paso 2 (suscripción)
    setState(() => _step = 1);
  }

  // _registerCompany eliminado ya que ahora todos pasan por _finishRegistration

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: CostealoColors.primary,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                '¡Cuenta creada!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            'Tu cuenta de empresa ha sido creada exitosamente. Vamos a comenzar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CostealoColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // Cerrar diálogo y navegar al Home (ya estamos logueados)
                  Navigator.of(context).pop(); // Cerrar diálogo
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home', // Asumiendo que esta es la ruta home
                    (route) => false,
                  );
                },
                child: const Text('Continuar'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _finishRegistration() async {
    if (!_formKeyStep2.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Call AuthService to register the user (Independiente con suscripción)
      await _authService.register(
        nombre: _nameCtrl.text.trim(),
        correo: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        organizacion: _organization,
        subscription: _subscription,
        paymentType: _paymentType,
        last4Digits: _last4Ctrl.text,
        expiryDate: _expiryCtrl.text,
        cvv: _cvvCtrl.text,
      );

      // register() ya hace login y actualiza el perfil automáticamente
      // No need to call login() again

      // Registration successful, show success dialog
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    } on ApiException catch (e) {
      // Handle API errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSubscriptionInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sobre nuestras suscripciones',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'Básico:\n'
                '• Acceso a 10 planillas y 1 base de datos mensualmente.\n\n'
                'Estándar:\n'
                '• Acceso a 25 planillas y 2 bases de datos distintas mensualmente.\n\n'
                'Premium:\n'
                '• Acceso ilimitado a planillas y bases de datos mensualmente.',
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CostealoColors.primaryLight,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Crear cuenta', style: textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    _step == 0
                        ? 'Paso 1 de 2 · Regístrate'
                        : 'Paso 2 de 2 · Método de pago',
                    style: textTheme.bodyMedium!.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_step == 0)
                    _buildStep1(textTheme)
                  else
                    _buildStep2(textTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(TextTheme textTheme) {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          TextFormField(
            controller: _nameCtrl,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingrese su nombre' : null,
          ),
          const SizedBox(height: 14),

          Text('Correo electrónico', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingrese su correo';
              if (!v.contains('@')) return 'Correo no válido';
              return null;
            },
          ),
          const SizedBox(height: 14),

          Text('Contraseña', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingrese una contraseña';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 14),

          Text('Verificar contraseña', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: true,
            validator: (v) {
              if (v != _passwordCtrl.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          Text('Organización', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _organization,
            items: const [
              DropdownMenuItem(value: 'Empresa', child: Text('Empresa')),
              DropdownMenuItem(
                value: 'Independiente',
                child: Text('Independiente'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _organization = value);
              }
            },
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CostealoColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : _goToStep2OrRegister,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(TextTheme textTheme) {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila: Suscripción + ícono info
          Row(
            children: [
              Text('Suscripción', style: textTheme.bodyMedium),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showSubscriptionInfo,
                child: const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: CostealoColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _subscription,
            items: const [
              DropdownMenuItem(
                value: 'Básico',
                child: Text('Básico · Bs 29,99/mes'),
              ),
              DropdownMenuItem(
                value: 'Estándar',
                child: Text('Estándar · Bs 49,99/mes'),
              ),
              DropdownMenuItem(
                value: 'Premium',
                child: Text('Premium · Bs 89,99/mes'),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _subscription = v);
            },
          ),
          const SizedBox(height: 16),

          Text('Tipo de pago', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _paymentType,
            items: const [
              DropdownMenuItem(
                value: 'Tarjeta de débito',
                child: Text('Tarjeta de débito'),
              ),
              DropdownMenuItem(
                value: 'Tarjeta de crédito',
                child: Text('Tarjeta de crédito'),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _paymentType = v);
            },
          ),
          const SizedBox(height: 16),

          Text('Ingrese los últimos 4 dígitos', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          TextFormField(
            controller: _last4Ctrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(counterText: ''),
            validator: (v) {
              if (v == null || v.length != 4) {
                return 'Ingrese 4 dígitos';
              }
              if (int.tryParse(v) == null) return 'Solo números';
              return null;
            },
          ),
          const SizedBox(height: 16),

          Text('Fecha de vencimiento (MM/AA)', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          TextFormField(
            controller: _expiryCtrl,
            keyboardType: TextInputType.datetime,
            validator: (v) => (v == null || v.isEmpty)
                ? 'Ingrese la fecha de vencimiento'
                : null,
          ),
          const SizedBox(height: 16),

          Text('Código de seguridad', style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          TextFormField(
            controller: _cvvCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(counterText: ''),
            validator: (v) {
              if (v == null || v.length < 3) {
                return 'Ingrese el código de seguridad';
              }
              if (int.tryParse(v) == null) return 'Solo números';
              return null;
            },
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => _step = 0),
                child: const Text('Volver'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CostealoColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _finishRegistration,
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('¡Comenzar ya!'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
