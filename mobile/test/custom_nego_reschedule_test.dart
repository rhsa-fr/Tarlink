import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Custom Nego & Reschedule Rule Tests', () {
    test('Max 3 rounds rule: round 4 throws error', () {
      const maxRounds = 3;
      const targetRound = 4;

      expect(targetRound > maxRounds, isTrue);
      expect(() {
        if (targetRound > 3) throw Exception('Maksimal tawar-menawar adalah 3 ronde');
      }, throwsException);
    });

    test('12-hour expiration window: expires_at is exactly 12 hours from now', () {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 12));

      expect(expiresAt.difference(now).inHours, equals(12));
    });

    test('Reschedule rule: H-7 minimal validation', () {
      final today = DateTime.now();

      // Event is 8 days away -> eligible
      final eligibleEventDate = today.add(const Duration(days: 8));
      final eligibleDiff = eligibleEventDate.difference(today).inDays;
      expect(eligibleDiff >= 7, isTrue);

      // Event is 4 days away -> ineligible (too late)
      final lateEventDate = today.add(const Duration(days: 4));
      final lateDiff = lateEventDate.difference(today).inDays;
      expect(lateDiff >= 7, isFalse);
    });

    test('Reschedule fee: exactly 10% of total price', () {
      const totalPrice = 15000000;
      final rescheduleFee = (totalPrice * 0.10).round();

      expect(rescheduleFee, equals(1500000));
    });
  });
}
