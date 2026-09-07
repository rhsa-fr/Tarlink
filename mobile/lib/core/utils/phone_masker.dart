/// Phone number masking utility to enforce Anti-Bocor rules prior to DP payment.
class PhoneMasker {
  PhoneMasker._();

  /// Masks phone number into `0812-****-**78` format.
  /// If [isDpPaid] is true, returns clean unmasked phone number.
  static String maskPhone(String phone, {bool isDpPaid = false}) {
    if (isDpPaid) return phone;

    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) {
      return '08**-****-**';
    }

    final prefix = digits.substring(0, 4);
    final suffix = digits.substring(digits.length - 2);
    return '$prefix-****-**$suffix';
  }
}
