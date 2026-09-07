import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/phone_masker.dart';

void main() {
  group('Phone Masker Anti-Bocor Tests', () {
    test('Masks phone number when isDpPaid is false', () {
      final masked = PhoneMasker.maskPhone('081234567890', isDpPaid: false);
      expect(masked, equals('0812-****-**90'));
    });

    test('Reveals real phone number when isDpPaid is true', () {
      final unmasked = PhoneMasker.maskPhone('081234567890', isDpPaid: true);
      expect(unmasked, equals('081234567890'));
    });

    test('Handles short phone numbers gracefully', () {
      final masked = PhoneMasker.maskPhone('0812', isDpPaid: false);
      expect(masked, equals('08**-****-**'));
    });
  });
}
