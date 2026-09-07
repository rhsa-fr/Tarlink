import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/currency_formatter.dart';

void main() {
  group('Currency Formatter Tests', () {
    test('Formats integer Rupiah without decimal digits', () {
      expect(CurrencyFormatter.formatRupiah(12500000), contains('12.500.000'));
      expect(CurrencyFormatter.formatRupiah(0), contains('0'));
    });

    test('Formats compact representation correctly for UI cards', () {
      expect(CurrencyFormatter.formatCompact(12500000), equals('Rp 12,5jt'));
      expect(CurrencyFormatter.formatCompact(500000), equals('Rp 500rb'));
      expect(CurrencyFormatter.formatCompact(1000000000), equals('Rp 1M'));
    });
  });
}
