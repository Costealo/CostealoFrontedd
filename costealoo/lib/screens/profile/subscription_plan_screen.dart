import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/services/auth_service.dart';
import 'package:costealoo/services/api_client.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  final int currentPlanType; // 0=Free, 1=Básico, 2=Estándar, 3=Premium

  const SubscriptionPlanScreen({super.key, required this.currentPlanType});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  final _authService = AuthService();
  late int _selectedPlan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.currentPlanType;
  }

  Future<void> _savePlan() async {
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

      // 2. Prepare update data (ONLY planType and isActive)
      final data = {'planType': _selectedPlan, 'isActive': true};

      // 3. Update subscription
      await _authService.updateSubscription(subId, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan actualizado correctamente'),
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
    return Scaffold(
      backgroundColor: CostealoColors.primaryLight,
      appBar: AppBar(
        title: const Text('Cambiar suscripción'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPlanCard(
                  title: 'Básico',
                  price: 'Bs 29,99/mes',
                  description:
                      'Acceso a 10 planillas y 1 base de datos mensualmente.',
                  planValue: 1,
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  title: 'Estándar',
                  price: 'Bs 49,99/mes',
                  description:
                      'Acceso a 25 planillas y 2 bases de datos distintas mensualmente.',
                  planValue: 2,
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  title: 'Premium',
                  price: 'Bs 89,99/mes',
                  description:
                      'Acceso ilimitado a planillas y bases de datos mensualmente.',
                  planValue: 3,
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CostealoColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _savePlan,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String description,
    required int planValue,
  }) {
    final isSelected = _selectedPlan == planValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = planValue),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? CostealoColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CostealoColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: CostealoColors.primary,
                size: 28,
              )
            else
              const Icon(Icons.circle_outlined, color: Colors.grey, size: 28),
          ],
        ),
      ),
    );
  }
}
