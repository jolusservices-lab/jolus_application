import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/order_provider.dart';
import 'payment_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '11:00';
  String _paymentMethod = 'Transferencia';
  List<DateTime> _reservedDates = [];

  @override
  void initState() {
    super.initState();
    _loadReservedDates();
  }

  Future<void> _loadReservedDates() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final dates = await orderProvider.getReservedDates();
    setState(() {
      _reservedDates = dates;
    });
  }

  bool _isDateTimeReserved(DateTime date, String time) {
    return _reservedDates.any((reserved) {
      return reserved.year == date.year &&
          reserved.month == date.month &&
          reserved.day == date.day &&
          '${reserved.hour.toString().padLeft(2, '0')}:${reserved.minute.toString().padLeft(2, '0')}' == time;
    });
  }

  String _getFormattedFullDate() {
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${days[_selectedDate.weekday - 1]}, ${_selectedDate.day} de ${months[_selectedDate.month - 1]}, ${_selectedDate.year}';
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_selectedTime.split(':')[0]),
        minute: int.parse(_selectedTime.split(':')[1]),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00236F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF00236F),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _selectedTime = '$hour:$minute';
      });
    }
  }

  List<String> _generateTimeSlots() {
    return [
      '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', 
      '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'
    ];
  }

  Future<void> _processCheckout(BuildContext context, CartProvider cart, UserProvider user, OrderProvider orderProvider) async {
    final double total = cart.totalAmount * 1.07 + 5.0;
    
    // Combinar fecha y hora para el pedido
    final int hour = int.parse(_selectedTime.split(':')[0]);
    final int minute = int.parse(_selectedTime.split(':')[1]);
    final DateTime fullOrderDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    // Verificar si sigue disponible justo antes de crear
    final reserved = await orderProvider.getReservedDates();
    final isTaken = reserved.any((r) => 
      r.year == fullOrderDate.year && 
      r.month == fullOrderDate.month && 
      r.day == fullOrderDate.day && 
      r.hour == fullOrderDate.hour && 
      r.minute == fullOrderDate.minute
    );

    if (isTaken) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lo sentimos, este horario acaba de ser reservado. Por favor elige otro.')),
      );
      _loadReservedDates();
      return;
    }

    // 1. Crear el pedido en Supabase
    final String? pedidoId = await orderProvider.placeOrder(
      userId: user.id,
      total: total,
      items: cart.items.values.toList(),
      fecha: fullOrderDate,
      direccion: user.address,
      metodoPago: _paymentMethod,
      telefono: user.phone,
      comentario: 'Agendado para ${_getFormattedFullDate()} a las $_selectedTime',
    );

    if (pedidoId != null) {
      if (_paymentMethod == 'Transferencia') {
        // Ir a subir el comprobante
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailScreen(orderId: pedidoId, total: total),
          ),
        );
      } else {
        // Flujo WhatsApp para otros métodos
        _sendWhatsAppMessage(context, cart, user, pedidoId);
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al procesar el pedido. Intente de nuevo.')),
      );
    }
  }

  Future<void> _sendWhatsAppMessage(BuildContext context, CartProvider cart, UserProvider user, String pedidoId) async {
    final String itemsDetail = cart.items.values
        .map((item) => '${item.quantity}x ${item.title}')
        .join(', ');
    
    final double total = cart.totalAmount * 1.07 + 5.0;
    
    final String message = '''
NUEVO PEDIDO - JOLUS SERVICES
Pedido ID: $pedidoId
Cliente: ${user.name}
Entrega en: ${user.address}
Fecha de Servicio: ${_getFormattedFullDate()}
Hora: $_selectedTime
Detalle: $itemsDetail
Total: \$${total.toStringAsFixed(2)} USD
''';

    final Uri url = Uri.parse("https://wa.me/593992512048?text=${Uri.encodeComponent(message)}");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      cart.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final user = Provider.of<UserProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: JolusColors.surfaceLow,
            child: Icon(Icons.person, color: JolusColors.primary, size: 20),
          ),
        ),
        title: Text(
          'Jolus Services',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00236F),
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            tooltip: 'Vaciar carrito',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('¿Vaciar carrito?', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                    content: const Text('¿Estás seguro de que deseas eliminar todos los servicios del carrito?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancelar', style: GoogleFonts.manrope(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          cart.clear();
                          Navigator.of(context).pop();
                        },
                        child: Text('Vaciar', style: GoogleFonts.manrope(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF00236F)),
            onPressed: () {},
          ),
        ],
      ),
      body: cart.items.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Tu carrito está vacío', style: GoogleFonts.manrope(fontSize: 18, color: Colors.grey)),
              ],
            ),
          )
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi Carrito',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00236F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa tus servicios seleccionados para agendar.',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Items del Carrito
            ...cart.items.values.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCartItem(
                id: item.id,
                title: item.title,
                subtitle: 'Arreglos Florales y Mobiliario', // Placeholder subtitle
                price: item.price.toStringAsFixed(2),
                quantity: item.quantity,
                imageUrl: item.imageUrl,
                cart: cart,
              ),
            )),

            Text(
              'Servicio para el ${_selectedDate.day}/${_selectedDate.month} a las $_selectedTime',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00236F),
              ),
            ),
            const SizedBox(height: 16),
            
            // Selector de Fecha
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))
                ],
                border: Border.all(color: const Color(0xFFEEF2FF), width: 1),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF00236F),
                                onPrimary: Colors.white,
                                onSurface: Color(0xFF00236F),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      constraints: const BoxConstraints(minHeight: 80),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00236F), Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF00236F).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 28, color: Colors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'FECHA Y HORA DE SERVICIO SELECCIONADA',
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_getFormattedFullDate()} - $_selectedTime',
                                  style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PRÓXIMAS 3 SEMANAS',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 1),
                        ),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF00236F)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(21, (index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final isSelected = date.day == _selectedDate.day && 
                                         date.month == _selectedDate.month && 
                                         date.year == _selectedDate.year;
                        
                        // Verificar si el día tiene algún horario disponible
                        final allSlots = _generateTimeSlots();
                        final availableSlots = allSlots.where((t) => !_isDateTimeReserved(date, t)).toList();
                        final isFullyReserved = availableSlots.isEmpty;

                        final daysShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: isFullyReserved ? null : () => setState(() {
                              _selectedDate = date;
                              // Si el horario actual no está disponible en la nueva fecha, elegir el primero disponible
                              if (_isDateTimeReserved(date, _selectedTime)) {
                                _selectedTime = availableSlots.isNotEmpty ? availableSlots.first : '11:00';
                              }
                            }),
                            child: Opacity(
                              opacity: isFullyReserved ? 0.3 : 1.0,
                              child: _buildMiniCalendarDay(
                                daysShort[date.weekday - 1], 
                                date.day, 
                                isSelected
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, size: 16, color: Color(0xFF00236F)),
                        const SizedBox(width: 8),
                        Text(
                          'HORARIOS DISPONIBLES',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey[600], letterSpacing: 1),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _selectTime(context),
                          child: Text(
                            'RELOJ',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF00236F), decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ..._generateTimeSlots().where((time) => !_isDateTimeReserved(_selectedDate, time)).map((time) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildTimeChip(time, _selectedTime == time),
                        )),
                        GestureDetector(
                          onTap: () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F8),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: const Icon(Icons.more_time_rounded, size: 20, color: Color(0xFF00236F)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text(
              'Método de Pago',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00236F),
              ),
            ),
            const SizedBox(height: 16),

            _buildPaymentOption(
              icon: Icons.credit_card,
              title: 'Tarjeta de Crédito/Débito',
              subtitle: 'Visa, Mastercard, AMEX',
              isSelected: _paymentMethod == 'Tarjeta',
              onTap: () => setState(() => _paymentMethod = 'Tarjeta'),
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              icon: Icons.account_balance,
              title: 'Transferencia Bancaria',
              subtitle: 'Pago directo desde tu banca',
              isSelected: _paymentMethod == 'Transferencia',
              onTap: () => setState(() => _paymentMethod = 'Transferencia'),
            ),

            const SizedBox(height: 32),
            // Resumen de Orden
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FC),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Orden',
                    style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF00236F)),
                  ),
                  const SizedBox(height: 20),
                  _buildSummaryRow('Subtotal', '\$${cart.totalAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Impuestos (7%)', '\$${(cart.totalAmount * 0.07).toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Cargos por servicio', '\$5.00'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF00236F))),
                      Text('\$${(cart.totalAmount * 1.07 + 5.0).toStringAsFixed(2)}', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF00236F))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: orderProvider.isLoading 
                        ? null 
                        : () => _processCheckout(context, cart, user, orderProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001F60),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: orderProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Proceder a Pagar',
                            style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Al confirmar, aceptas nuestros términos\ny condiciones.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500], height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required String id, 
    required String title, 
    required String subtitle, 
    required String price, 
    required int quantity, 
    required String imageUrl,
    required CartProvider cart,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF00236F))),
                    ),
                    GestureDetector(
                      onTap: () => cart.removeItem(id),
                      child: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => cart.removeSingleItem(id),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.remove, size: 16, color: Color(0xFF00236F)),
                            ),
                          ),
                          Text('$quantity', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF00236F))),
                          GestureDetector(
                            onTap: () => cart.addItem(id, title, double.parse(price), imageUrl),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.add, size: 16, color: Color(0xFF00236F)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('\$${price} USD', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF00236F), fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String time, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00236F) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[200]!),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFF00236F).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCalendarDay(String day, int date, bool isSelected) {
    return Column(
      children: [
        Text(day, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00236F) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? null : Border.all(color: Colors.grey[100]!),
          ),
          child: Text(
            '$date',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (date < 21 ? Colors.grey[300] : const Color(0xFF1A1B21)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({required IconData icon, required String title, required String subtitle, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00236F) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF00236F), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF00236F))),
                  Text(subtitle, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11)),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF00236F) : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: Color(0xFF00236F), shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF00236F))),
      ],
    );
  }
}
