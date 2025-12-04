import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/services/auth_service.dart';
import 'package:costealoo/services/api_client.dart';

class SubscriptionEditScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const SubscriptionEditScreen({super.key, required this.currentProfile});

  @override
  State<SubscriptionEditScreen> createState() => _SubscriptionEditScreenState();
}

class _SubscriptionEditScreenState extends State<SubscriptionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late String _paymentType;
  final _last4Ctrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final profile = widget.currentProfile;

    _paymentType = profile['paymentMethodType'] ?? 'Tarjeta de débito';
    _last4Ctrl.text = profile['cardLastFourDigits'] ?? '';
    _expiryCtrl.text = profile['expirationDate'] ?? '';
    _cvvCtrl.text = profile['securityCode'] ?? '';
    _cardHolderCtrl.text =
        profile['userName'] ?? ''; // Default to username if not available
  }

  @override
  void dispose() {
    _last4Ctrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _cardHolderCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Get current subscription ID
      final sub = await _authService.getSubscription();
      if (sub == null) {
        throw ApiException(
          message: 'No se encontró suscripción activa',
          statusCode: 404,
        );
      }

      final subId = sub['id'];

      // 2. Prepare update data (ONLY payment details, NO planType)
      final data = {
        'isActive': true,
        'paymentMethodType': _paymentType,
        'cardLastFourDigits': _last4Ctrl.text,
        'cardHolderName': _cardHolderCtrl.text,
        'expirationDate': _expiryCtrl.text,
        'securityCode': _cvvCtrl.text,
      };

      // 3. Update subscription
      await _authService.updateSubscription(subId, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Método de pago actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CostealoColors.primaryLight,
      appBar: AppBar(
        title: const Text('Editar Método de Pago'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Card(
            margin: const EdgeInsets.all(24),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tipo de pago', style: textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _paymentType,
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

                    Text('Nombre del titular', style: textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _cardHolderCtrl,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Ingrese el nombre del titular'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    Text('Últimos 4 dígitos', style: textTheme.bodyMedium),
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

                    Text(
                      'Fecha de vencimiento (MM/AA)',
                      style: textTheme.bodyMedium,
                    ),
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
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CostealoColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isLoading ? null : _saveChanges,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Guardar Cambios'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
