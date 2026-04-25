import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/user_provider.dart';
import '../widgets/main_navigation.dart';

class PaymentDetailScreen extends StatelessWidget {
  const PaymentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    // final user = Provider.of<UserProvider>(context); // Not used in original snippet but imported
    final total = cart.totalAmount * 1.07 + 5.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00236F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalles de Pago',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00236F),
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cuentas Bancarias',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00236F),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildBankCard(
                    bankName: 'Banco Mercantil',
                    holderName: 'Jolus Services S.A.',
                    accountNumber: '0105 1234 5678 9012 3456',
                    ruc: '12345678-9',
                    email: 'pagos@jolus-services.com',
                    type: 'Corriente',
                    color: const Color(0xFF002266),
                  ),
                  const SizedBox(width: 16),
                  _buildBankCard(
                    bankName: 'Banco Pichincha',
                    holderName: 'Jolus Services S.A.',
                    accountNumber: '2201 9876 5432 1098 7654',
                    ruc: '12345678-9',
                    email: 'transferencias@jolus.com',
                    type: 'Ahorros',
                    color: const Color(0xFF535865),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reportar Pago',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00236F),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildReportField('Nombre Completo', 'Ej: Juan Pérez'),
                  const SizedBox(height: 16),
                  _buildReportField('Número de Identificación', 'Cédula o Pasaporte'),
                  const SizedBox(height: 16),
                  _buildReportField('Fecha de Pago', 'mm/dd/yyyy', suffixIcon: Icons.calendar_today_outlined),
                  const SizedBox(height: 16),
                  _buildReportField('Nombre del Banco', 'Banco emisor'),
                  const SizedBox(height: 16),
                  _buildReportField('Correo Electrónico', 'usuario@ejemplo.com'),
                  const SizedBox(height: 16),
                  _buildReportField('Monto Pagado', '\$ ${total.toStringAsFixed(2)}'),
                  const SizedBox(height: 24),
                  Text(
                    'Recibo de Pago',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.2), style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_rounded, color: Color(0xFF00236F), size: 32),
                        const SizedBox(height: 12),
                        Text(
                          'Subir comprobante',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF00236F)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Soporta JPG, PNG o PDF (Máx. 5MB)',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6FF),
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: Color(0xFF00236F), width: 4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_rounded, color: Color(0xFF00236F), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información importante',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF00236F)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Asegúrese de que toda la información sea correcta antes de enviarla. Su pago se procesará en un plazo de 1-3 días hábiles tras la verificación.',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF00236F).withOpacity(0.7), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pago reportado con éxito. Procesando verificación.')),
                  );
                  cart.clear();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainNavigation()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001F60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Enviar Pago',
                  style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBankCard({
    required String bankName,
    required String holderName,
    required String accountNumber,
    required String ruc,
    required String email,
    required String type,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bankName, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const Icon(Icons.account_balance, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text('NOMBRE DEL TITULAR', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          Text(holderName, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 16),
          Text('NÚMERO DE CUENTA', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          Text(accountNumber, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RUC: $ruc', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 9)),
                  Text(email, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 9)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(type, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportField(String label, String hint, {IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18, color: Colors.grey[400]) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }
}
