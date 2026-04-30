import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/order_provider.dart';
import '../../core/models/order_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    
    // Filtrar los pedidos localmente
    final orders = orderProvider.orders.where((order) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Completados') return order.estado.toLowerCase() == 'completado';
      if (_selectedFilter == 'Pendientes') return order.estado.toLowerCase() == 'pendiente';
      if (_selectedFilter == 'Anulados') return order.estado.toLowerCase() == 'anulado' || order.estado.toLowerCase() == 'cancelado';
      return true;
    }).toList();

    final double totalSpent = orderProvider.orders
        .where((o) => o.estado.toLowerCase() == 'completado')
        .fold(0, (sum, item) => sum + item.total);

    final int completedCount = orderProvider.orders.where((o) => o.estado.toLowerCase() == 'completado').length;
    final int cancelledCount = orderProvider.orders.where((o) => o.estado.toLowerCase() == 'anulado' || o.estado.toLowerCase() == 'cancelado').length;

    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JolusColors.primary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Historial de Compras',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: JolusColors.primary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // Stats Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatCard('Total Invertido', '\$${totalSpent.toStringAsFixed(2)}'),
                  const SizedBox(width: 12),
                  _buildStatCard('Completados', '$completedCount', color: Colors.green),
                  const SizedBox(width: 12),
                  _buildStatCard('Anulados', '$cancelledCount', color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildFilterChip('Todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completados'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pendientes'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Anulados'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // History List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: orders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'Todos' 
                                ? 'Aún no tienes pedidos registrados.'
                                : 'No hay pedidos con el estado "$_selectedFilter".',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: orders.map((order) {
                        final String displayId = order.id?.toString() ?? '---';
                        
                        // Determinar color por estado
                        Color statusColor = Colors.orange;
                        if (order.estado.toLowerCase() == 'completado') statusColor = Colors.green;
                        if (order.estado.toLowerCase() == 'anulado' || order.estado.toLowerCase() == 'cancelado') statusColor = Colors.red;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildHistoryItem(
                            order: order,
                            title: 'Pedido #$displayId',
                            date: "${order.fecha.day}/${order.fecha.month}/${order.fecha.year}",
                            price: '\$${order.total.toStringAsFixed(2)}',
                            status: order.estado,
                            statusColor: statusColor,
                            icon: Icons.shopping_bag_outlined,
                            actionText: 'Ver detalles >',
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {Color? color}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JolusColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? JolusColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? JolusColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? JolusColors.primary : JolusColors.outlineVariant.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Detalles del Pedido',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: JolusColors.primary),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID del Pedido:', '#${order.id}'),
                _buildDetailRow('Fecha:', "${order.fecha.day}/${order.fecha.month}/${order.fecha.year} ${order.fecha.hour}:${order.fecha.minute.toString().padLeft(2, '0')}"),
                _buildDetailRow('Estado:', order.estado.toUpperCase(), valueColor: order.estado.toLowerCase() == 'completado' ? Colors.green : (order.estado.toLowerCase() == 'anulado' || order.estado.toLowerCase() == 'cancelado' ? Colors.red : Colors.orange)),
                const Divider(height: 32),
                _buildDetailRow('Método de Pago:', order.metodoPago ?? 'No especificado'),
                _buildDetailRow('Dirección:', order.direccionEntrega ?? 'No especificada'),
                _buildDetailRow('Teléfono:', order.telefonoContacto ?? 'No especificado'),
                if (order.comentario != null && order.comentario!.isNotEmpty)
                  _buildDetailRow('Comentario:', order.comentario!),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL:',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: JolusColors.primary),
                    ),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: JolusColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: JolusColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, color: valueColor ?? Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required OrderModel order,
    required String title,
    required String date,
    required String price,
    required String status,
    required Color statusColor,
    required IconData icon,
    required String actionText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JolusColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JolusColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: JolusColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status.toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: JolusColors.primary,
                ),
              ),
              InkWell(
                onTap: () => _showOrderDetails(context, order),
                child: Text(
                  actionText,
                  style: GoogleFonts.inter(
                    color: JolusColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
