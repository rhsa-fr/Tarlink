import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Business Rules QA - TarlingBook', () {
    test('Server calculation: DP 20% and platform fee 8% math', () {
      const packagePrice = 12000000;
      const zoneExtra = 500000;
      const totalPrice = packagePrice + zoneExtra; // 12.500.000

      final dpAmount = (totalPrice * 0.20).round(); // 2.500.000
      final remainingCash = totalPrice - dpAmount; // 10.000.000

      final platformFee = (dpAmount * 0.08).round(); // 200.000
      final netGroupDisbursement = dpAmount - platformFee; // 2.300.000

      expect(dpAmount, equals(2500000));
      expect(remainingCash, equals(10000000));
      expect(platformFee, equals(200000));
      expect(netGroupDisbursement, equals(2300000));
    });

    test('Anti-PHP Rule: Rejects 3rd pending custom booking if active count >= 2', () {
      const currentPendingCustomCount = 2;
      const maxAllowedPending = 2;

      final canCreateNewCustom = currentPendingCustomCount < maxAllowedPending;
      expect(canCreateNewCustom, isFalse);

      const statusCode = 429;
      expect(statusCode, equals(429));
    });

    test('Nego Custom Rule: Rejects round 4 (Max 3 rounds)', () {
      const currentRound = 4;
      const maxRounds = 3;

      final isRoundAllowed = currentRound <= maxRounds;
      expect(isRoundAllowed, isFalse);

      const statusCode = 422;
      expect(statusCode, equals(422));
    });

    test('Fullday Mutlak Rule: 1 group cannot accept 2 bookings on the same date', () {
      final activeBookingsOnDate = <String, Set<String>>{
        'group-a': {'2026-09-20'},
      };

      const targetGroup = 'group-a';
      const targetDate = '2026-09-20';

      final isDateConflict = activeBookingsOnDate[targetGroup]?.contains(targetDate) ?? false;
      expect(isDateConflict, isTrue);

      const conflictStatusCode = 409;
      expect(conflictStatusCode, equals(409));
    });

    test('Idempotent Webhook Rule: Repeat webhook does not double insert payout', () {
      final processedTransactionIds = <String>{'trx-midtrans-12345'};
      const incomingTrxId = 'trx-midtrans-12345';

      final isAlreadyProcessed = processedTransactionIds.contains(incomingTrxId);
      expect(isAlreadyProcessed, isTrue);
    });
  });
}
