import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'DP_PAID':
      case 'FULL_PAID':
      case 'COMPLETED':
        return AppColors.success;
      case 'WAITING_DP':
      case 'PENDING':
        return AppColors.warning;
      case 'CANCELLED':
      case 'EXPIRED':
      case 'REFUNDED':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _getReadableText() {
    switch (status.toUpperCase()) {
      case 'DP_PAID':
        return 'DP LUNAS';
      case 'FULL_PAID':
        return 'LUNAS PENUH';
      case 'COMPLETED':
        return 'SELESAI';
      case 'WAITING_DP':
        return 'MENUNGGU DP';
      case 'PENDING':
        return 'MENUNGGU';
      case 'CANCELLED':
        return 'DIBATALKAN';
      case 'EXPIRED':
        return 'KADALUARSA';
      case 'REFUNDED':
        return 'DIKEMBALIKAN';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        _getReadableText(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
