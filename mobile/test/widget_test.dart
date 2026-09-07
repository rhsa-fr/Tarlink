import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/app_button.dart';
import 'package:mobile/core/widgets/status_badge.dart';

void main() {
  testWidgets('AppButton and StatusBadge smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppButton(label: 'Pesan Sekarang', onPressed: null),
              StatusBadge(status: 'DP_PAID'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Pesan Sekarang'), findsOneWidget);
    expect(find.text('DP LUNAS'), findsOneWidget);
  });
}
