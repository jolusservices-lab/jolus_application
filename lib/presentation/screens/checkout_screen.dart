import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../widgets/main_navigation.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';

  final List<String> _timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM',
    '04:00 PM', '05:00 PM', '06:00 PM', '07:00 PM'
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        title: Text('Finalizar Pedido', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: JolusColors.primary)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JolusColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha del Evento',
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: JolusColors.primary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: JolusColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: JolusColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: JolusColors.primary,
                                onPrimary: Colors.white,
                                onSurface: JolusColors.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Text('Cambiar', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: JolusColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Hora de Inicio',
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: JolusColors.primary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _timeSlots.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? JolusColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? JolusColors.primary : JolusColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : JolusColors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text(
              'Ubicación del Evento',
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: JolusColors.primary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: JolusColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: JolusColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Casa Principal', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        Text('12 Calle 4-56 Zona 10, Edificio Jolus', style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Resumen del Pago',
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: JolusColors.primary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: JolusColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: 'Subtotal', value: '\$${cart.totalAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _SummaryRow(label: 'Impuestos (12%)', value: '\$${(cart.totalAmount * 0.12).toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _SummaryRow(label: 'Tarifa de Servicio', value: '\$15.00'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  _SummaryRow(
                    label: 'Total a Pagar',
                    value: '\$${(cart.totalAmount * 1.12 + 15).toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // Guardar el pedido localmente
                  final total = (cart.totalAmount * 1.12 + 15);
                  Provider.of<OrderProvider>(context, listen: false).addOrder(
                    cart.items.values.toList(),
                    total,
                  );

                  // Simular éxito de reserva
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          const Icon(Icons.check_circle, color: Colors.green, size: 80),
                          const SizedBox(height: 24),
                          Text(
                            '¡Reserva Exitosa!',
                            style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tu servicio ha sido programado para el ${_selectedDate.day}/${_selectedDate.month} a las $_selectedTime.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                cart.clear();
                                Navigator.of(ctx).pop(); // Cerrar Dialog
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const MainNavigation()),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: JolusColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Volver al Inicio'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: JolusColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmar y Reservar',
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? JolusColors.primary : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: isTotal ? 22 : 16,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? JolusColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }
}
