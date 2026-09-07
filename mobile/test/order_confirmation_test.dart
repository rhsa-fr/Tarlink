import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/booking/presentation/screens/order_confirmation_screen.dart';

void main() {
  testWidgets('OrderConfirmationScreen displays booking confirmation and Pantura blessing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OrderConfirmationScreen(
          artistName: 'Dian Anic & Anica Nada',
          packageName: 'Paket Komplit Siang-Malam',
          customerName: 'Budi Pratama',
          customerPhone: '0812-3456-7890',
        ),
      ),
    );

    // Verify celebratory heading
    expect(find.text('Pesanan Berhasil Dikonfirmasi!'), findsOneWidget);
    expect(find.text('Jadwal Panggung Terkunci'), findsOneWidget);

    // Verify troupe info
    expect(find.text('Dian Anic & Anica Nada'), findsOneWidget);
    expect(find.text('E-Voucher Pentas Tarling'), findsOneWidget);

    // Verify next steps & action buttons
    expect(find.text('Langkah Selanjutnya'), findsOneWidget);
    expect(find.text('Kembali ke Beranda'), findsOneWidget);
    expect(find.textContaining('Mugi lancar berkah hajatane'), findsOneWidget);
  });
}
