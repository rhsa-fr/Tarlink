import 'package:flutter/material.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final userId = SupabaseService.client.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000001';
      final data = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() => _notifications = (data as List).map((e) => e as Map<String, dynamic>).toList());
    } catch (_) {
      // Mock data for preview
      setState(() {
        _notifications = [
          {
            'id': 'notif-1',
            'title': 'DP 20% Berhasil Diterima!',
            'body': 'Pesanan TRG-2026-0042 telah terbayar. Tanggal 20 Zulhijah resmi dikunci di kalender Anda.',
            'type': 'payment_success',
            'is_read': false,
            'created_at': '2026-09-07T12:00:00Z',
          },
          {
            'id': 'notif-2',
            'title': 'Pengingat Pentas H-1',
            'body': 'Besok hajatan di Desa Kandanghaur dimulai jam 09.00 WIB. Harap siapkan personil dan alat.',
            'type': 'event_reminder',
            'is_read': true,
            'created_at': '2026-09-06T08:00:00Z',
          },
          {
            'id': 'notif-3',
            'title': 'Pencairan Dana (Disbursement) Sukses',
            'body': 'Dana sisa DP sebesar Rp 2.300.000 telah ditransfer ke rekening BRI Anda.',
            'type': 'payout_completed',
            'is_read': true,
            'created_at': '2026-09-05T14:30:00Z',
          },
        ];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi & Peringatan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Belum ada notifikasi'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    final isRead = item['is_read'] as bool? ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isRead ? Colors.white : AppColors.primaryLight.withAlpha(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isRead ? Colors.grey.shade200 : AppColors.primaryLight,
                          child: Icon(
                            _getIcon(item['type'] as String?),
                            color: isRead ? AppColors.textSecondary : AppColors.primaryDark,
                          ),
                        ),
                        title: Text(
                          item['title'] as String? ?? 'Pemberitahuan',
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item['body'] as String? ?? '',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'payment_success':
        return Icons.check_circle_outline;
      case 'event_reminder':
        return Icons.alarm;
      case 'payout_completed':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
