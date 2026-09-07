import 'package:intl/intl.dart';

/// Formatter for pure Rupiah integer values per AGENTS.md clean code guidelines.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Formats integer to full Rupiah: Rp 12.500.000
  static String formatRupiah(int amount) {
    return _formatter.format(amount);
  }

  /// Formats compact representation for filters / badges: Rp 12,5jt
  static String formatCompact(int amount) {
    if (amount >= 1000000000) {
      final val = (amount / 1000000000).toStringAsFixed(1).replaceAll('.0', '').replaceAll('.', ',');
      return 'Rp ${val}M';
    } else if (amount >= 1000000) {
      final val = (amount / 1000000).toStringAsFixed(1).replaceAll('.0', '').replaceAll('.', ',');
      return 'Rp ${val}jt';
    } else if (amount >= 1000) {
      final val = (amount / 1000).toStringAsFixed(0);
      return 'Rp ${val}rb';
    }
    return formatRupiah(amount);
  }
}
