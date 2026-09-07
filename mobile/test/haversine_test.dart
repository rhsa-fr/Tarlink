import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/haversine.dart';

void main() {
  group('Haversine Distance Tests', () {
    test('Calculates distance between Kandanghaur and Jatibarang accurately', () {
      // Kandanghaur coords
      const lat1 = -6.3263;
      const lng1 = 108.1500;
      // Jatibarang coords
      const lat2 = -6.4716;
      const lng2 = 108.3073;

      final distance = calculateHaversineDistance(lat1, lng1, lat2, lng2);

      // Expected approx 23-25 km
      expect(distance, greaterThan(20.0));
      expect(distance, lessThan(30.0));
    });

    test('Same coordinates return zero distance', () {
      final distance = calculateHaversineDistance(-6.3263, 108.1500, -6.3263, 108.1500);
      expect(distance, closeTo(0.0, 0.001));
    });
  });
}
