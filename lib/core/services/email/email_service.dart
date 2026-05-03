import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../../models/payment_receipt_model.dart';
import '../../models/order_model.dart';
import '../database_service.dart';

class EmailService {
  // Configuración de la cuenta de la empresa (se recomienda usar variables de entorno o un config seguro)
  // Para este ejemplo usaremos Gmail como proveedor común.
  // IMPORTANTE: Para Gmail se requiere "Contraseña de aplicación" si tienes 2FA.
  static const String _companyEmail = 'tu-correo-empresa@gmail.com'; 
  static const String _appPassword = 'tu-password-de-aplicacion'; 

  final _dbService = DatabaseService();

  Future<bool> sendPaymentConfirmationEmail({
    required PaymentReceiptModel receipt,
    required String customerEmail,
    required String orderId,
    File? receiptImage,
  }) async {
    // 1. Obtener detalles del pedido para el cuerpo del correo
    // Nota: Podrías querer obtener también los items del pedido si es necesario
    
    final smtpServer = gmail(_companyEmail, _appPassword);

    // Crear el mensaje
    final message = Message()
      ..from = Address(_companyEmail, 'Jolus Services')
      ..recipients.add(customerEmail)
      ..bccRecipients.add(_companyEmail) // Copia oculta a la empresa
      ..subject = 'Confirmación de Reporte de Pago - Pedido #$orderId'
      ..html = """
        <div style="font-family: sans-serif; max-width: 600px; margin: auto; border: 1px solid #eee; padding: 20px;">
          <h2 style="color: #1F6FE5; text-align: center;">¡Hemos recibido tu reporte de pago!</h2>
          <p>Hola <strong>${receipt.fullName}</strong>,</p>
          <p>Gracias por realizar tu pago. Hemos recibido la información de tu comprobante y nuestro equipo procederá con la verificación.</p>
          
          <div style="background-color: #f9f9f9; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <h3 style="margin-top: 0; font-size: 16px;">Resumen del Reporte:</h3>
            <ul style="list-style: none; padding: 0;">
              <li><strong>ID del Pedido:</strong> #$orderId</li>
              <li><strong>Monto Reportado:</strong> \$${receipt.amount.toStringAsFixed(2)}</li>
              <li><strong>Banco:</strong> ${receipt.bankName}</li>
              <li><strong>Nº de Comprobante:</strong> ${receipt.receiptNumber}</li>
              <li><strong>Fecha de Reporte:</strong> ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}</li>
            </ul>
          </div>
          
          <p style="font-size: 14px; color: #666;">
            <strong>Nota importante:</strong> Tu pago se procesará en un plazo de 1 a 3 días hábiles. Una vez verificado, recibirás una notificación de actualización de tu pedido.
          </p>
          
          <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
          
          <p style="text-align: center; font-size: 12px; color: #999;">
            Este es un correo automático, por favor no respondas a este mensaje.<br>
            &copy; ${DateTime.now().year} Jolus Services. Todos los derechos reservados.
          </p>
        </div>
      """;

    // Agregar el comprobante como adjunto si existe
    if (receiptImage != null && await receiptImage.exists()) {
      message.attachments.add(FileAttachment(receiptImage)
        ..location = Location.attachment
        ..fileName = 'comprobante_pago_$orderId.jpg');
    }

    try {
      final sendReport = await send(message, smtpServer);
      print('Correo enviado: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Error al enviar correo: $e');
      for (var p in e.problems) {
        print('Problema: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }
}
