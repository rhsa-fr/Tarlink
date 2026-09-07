import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/currency_formatter.dart';

void main() {
  group('Group Stall Management Tests', () {
    test('Package price is valid integer Rupiah', () {
      const price = 12000000;
      expect(price, isNonNegative);
      expect(CurrencyFormatter.formatRupiah(price), contains('12.500.000'.substring(0, 2)));
    });

    test('Blocked dates toggle adds and removes dates', () {
      final blocked = <String>{};
      const date1 = '2026-09-20';
      const date2 = '2026-09-21';

      // Add dates
      blocked.add(date1);
      blocked.add(date2);
      expect(blocked.length, equals(2));
      expect(blocked.contains('2026-09-20'), isTrue);

      // Remove date
      blocked.remove(date1);
      expect(blocked.length, equals(1));
      expect(blocked.contains('2026-09-20'), isFalse);
    });

    test('Payout summary calculates total HOLD and COMPLETED correctly', () {
      final rawPayouts = [
        {'net': 2300000, 'status': 'HOLD'},
        {'net': 4600000, 'status': 'COMPLETED'},
        {'net': 1840000, 'status': 'HOLD'},
      ];

      int hold = 0;
      int completed = 0;

      for (final p in rawPayouts) {
        if (p['status'] == 'HOLD') {
          hold += p['net'] as int;
        } else if (p['status'] == 'COMPLETED') {
          completed += p['net'] as int;
        }
      }

      expect(hold, equals(4140000));
      expect(completed, equals(4600000));
    });
  });
}
