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
  DateTime _selectedDate = DateTime(2024, 10, 24);
  String _selectedTime = '11:00 AM';
  String _paymentMethod = 'Transferencia';

  String _getFormattedFullDate() {
    final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${days[_selectedDate.weekday - 1]}, ${_selectedDate.day} de ${months[_selectedDate.month - 1]}, ${_selectedDate.year}';
  }

  Future<void> _sendWhatsAppMessage(BuildContext context, CartProvider cart, UserProvider user) async {
    final String itemsDetail = cart.items.values
        .map((item) => '${item.quantity}x ${item.title}')
        .join(', ');
    
    final double total = cart.totalAmount * 1.07 + 5.0;
    
    final String message = '''
NUEVO PEDIDO - JOLUS SERVICES
Cliente: \${user.name}
Entrega en: \${user.address}
Fecha de Servicio: \${_getFormattedFullDate()}
Hora: \$_selectedTime
Detalle: \$itemsDetail
Total: \\\$\${total.toStringAsFixed(2)} USD
''';

    // Guardar el pedido localmente en el historial
    await Provider.of<OrderProvider>(context, listen: false).addOrder(
      cart.items.values.toList(),
      total,
    );

    final Uri url = Uri.parse("https://wa.me/593992512048?text=\${Uri.encodeComponent(message)}");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      cart.clear();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final user = Provider.of<UserProvider>(context);

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

            const SizedBox(height: 32),
            Text(
              'Servicio para el \${_selectedDate.day}/\${_selectedDate.month} a las \$_selectedTime',
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          const Icon(Icons.calendar_month_rounded, size: 22, color: Colors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FECHA Y HORA DE SERVICIO',
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\${_getFormattedFullDate()} - \$_selectedTime',
                                  style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniCalendarDay('Lun', 19, false),
                      _buildMiniCalendarDay('Mar', 20, false),
                      _buildMiniCalendarDay('Mié', 21, false),
                      _buildMiniCalendarDay('Jue', 22, false),
                      _buildMiniCalendarDay('Vie', 23, false),
                      _buildMiniCalendarDay('Sáb', 24, true),
                      _buildMiniCalendarDay('Dom', 25, false),
                    ],
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTimeChip('09:00 AM', _selectedTime == '09:00 AM'),
                        const SizedBox(width: 12),
                        _buildTimeChip('11:00 AM', _selectedTime == '11:00 AM'),
                        const SizedBox(width: 12),
                        _buildTimeChip('01:00 PM', _selectedTime == '01:00 PM'),
                        const SizedBox(width: 12),
                        _buildTimeChip('03:00 PM', _selectedTime == '03:00 PM'),
                        const SizedBox(width: 12),
                        _buildTimeChip('05:00 PM', _selectedTime == '05:00 PM'),
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
                  _buildSummaryRow('Subtotal', '\\\$\${cart.totalAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Impuestos (7%)', '\\\$\${(cart.totalAmount * 0.07).toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Cargos por servicio', '\\\$5.00'),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF00236F))),
                      Text('\\\$\${(cart.totalAmount * 1.07 + 5.0).toStringAsFixed(2)}', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF00236F))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_paymentMethod == 'Transferencia') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaymentDetailScreen()),
                          );
                        } else {
                          _sendWhatsAppMessage(context, cart, user);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF001F60),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Proceder a Pagar',
                        style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Al confirmar, aceptas nuestros términos\\ny condiciones.',
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
                          Text('\$quantity', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF00236F))),
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
                    Text('\\\$\${price} USD', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF00236F), fontSize: 15)),
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
            '\$date',
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
