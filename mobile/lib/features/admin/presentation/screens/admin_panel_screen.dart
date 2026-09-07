import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminPanelScreen extends StatefulWidget {
  final AdminRepository repository;

  const AdminPanelScreen({super.key, required this.repository});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  List<Map<String, dynamic>> _pendingVerifications = [];
  List<Map<String, dynamic>> _disputes = [];
  List<Map<String, dynamic>> _failedPayouts = [];
  List<Map<String, dynamic>> _allArtists = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      final verifs = await widget.repository.getPendingVerifications();
      final disps = await widget.repository.getDisputes();
      final payouts = await widget.repository.getFailedPayouts();
      final artists = await widget.repository.getAllArtists();

      setState(() {
        _pendingVerifications = verifs;
        _disputes = disps;
        _failedPayouts = payouts;
        _allArtists = artists;
      });
    } catch (_) {
      // Mock data for preview
      setState(() {
        _pendingVerifications = [
          {
            'id': 'art-mock-1',
            'display_name': 'Sandiwara Langensari Asli',
            'category': 'sandiwara-full',
            'base_city': 'Indramayu',
            'base_district': 'Patrol',
            'users': {'name': 'H. Darmawan', 'phone': '081298765432'},
          },
        ];
        _disputes = [
          {
            'id': 'disp-1',
            'booking_id': 'book-101',
            'reason': 'Grup datang terlambat 3 jam dan sound system mati-mati saat malam',
            'status': 'open',
            'bookings': {'code': 'TRG-2026-0038', 'total_price': 14000000},
          },
        ];
        _failedPayouts = [
          {
            'id': 'payout-f1',
            'booking_id': 'book-099',
            'net': 2300000,
            'retry_count': 1,
            'artist_profiles': {
              'display_name': 'Tarling Bintang Pantura',
              'bank_name': 'BCA',
              'bank_no': '8910293847',
            },
          },
        ];
        _allArtists = [
          {
            'id': 'art-1',
            'display_name': 'Sandiwara Dharma Kudeta',
            'category': 'sandiwara-full',
            'base_city': 'Indramayu',
            'status': 'verified',
            'rating_avg': 4.9,
            'total_job': 84,
          },
          {
            'id': 'art-2',
            'display_name': 'Dangdut Gelora Pantura',
            'category': 'tarling-dangdut',
            'base_city': 'Cirebon',
            'status': 'suspended',
            'rating_avg': 3.2,
            'total_job': 12,
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
        title: const Text('Panel Pasar Admin (Pengawas)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.secondaryDark,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Verifikasi KTP'),
            Tab(text: 'Sengketa & Tiket'),
            Tab(text: 'Payout Gagal'),
            Tab(text: 'Kelola Lapak'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildVerificationTab(),
                _buildDisputesTab(),
                _buildPayoutTab(),
                _buildStallTab(),
              ],
            ),
    );
  }

  Widget _buildVerificationTab() {
    if (_pendingVerifications.isEmpty) {
      return const Center(child: Text('Tidak ada antrean verifikasi KTP'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingVerifications.length,
      itemBuilder: (context, index) {
        final item = _pendingVerifications[index];
        final user = item['users'] as Map<String, dynamic>?;

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['display_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 4),
                Text('Kategori: ${item['category']} • Wilayah: ${item['base_district']}, ${item['base_city']}'),
                Text('Pemilik: ${user?['name'] ?? '-'} (${user?['phone'] ?? '-'})'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey.shade100,
                  child: const Row(
                    children: [
                      Icon(Icons.badge, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Dokumen KTP & Bukti Panggung Asli Terlampir'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        onPressed: () {
                          widget.repository.rejectArtist(item['id'] as String);
                          setState(() => _pendingVerifications.removeAt(index));
                        },
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                        onPressed: () {
                          widget.repository.approveArtist(item['id'] as String);
                          setState(() => _pendingVerifications.removeAt(index));
                        },
                        child: const Text('Verifikasi Lapak'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisputesTab() {
    if (_disputes.isEmpty) {
      return const Center(child: Text('Tidak ada sengketa aktif. Semua berjalan lancar.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _disputes.length,
      itemBuilder: (context, index) {
        final d = _disputes[index];
        final booking = d['bookings'] as Map<String, dynamic>?;

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tiket: ${booking?['code'] ?? d['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                      child: const Text('PAYOUT TERKUNCI', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Laporan Masalah:\n"${d['reason']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                        onPressed: () {
                          widget.repository.resolveDispute(
                            disputeId: d['id'] as String,
                            bookingId: d['booking_id'] as String,
                            verdict: 'Refund penuh ke customer karena kelalaian grup',
                            refundToCustomer: true,
                          );
                          setState(() => _disputes.removeAt(index));
                        },
                        child: const Text('Refund Customer'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                        onPressed: () {
                          widget.repository.resolveDispute(
                            disputeId: d['id'] as String,
                            bookingId: d['booking_id'] as String,
                            verdict: 'Kompensasi ditolak, sisa DP dicairkan ke grup',
                            refundToCustomer: false,
                          );
                          setState(() => _disputes.removeAt(index));
                        },
                        child: const Text('Cairkan ke Grup'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPayoutTab() {
    if (_failedPayouts.isEmpty) {
      return const Center(child: Text('Semua transfer disbursement berhasil (0 FAILED)'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _failedPayouts.length,
      itemBuilder: (context, index) {
        final p = _failedPayouts[index];
        final artist = p['artist_profiles'] as Map<String, dynamic>?;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.error, color: AppColors.error, size: 36),
            title: Text(artist?['display_name'] ?? 'Grup'),
            subtitle: Text('Bank: ${artist?['bank_name']} • ${artist?['bank_no']}\nNominal: ${CurrencyFormatter.formatRupiah(p['net'] as int)} (Gagal coba: ${p['retry_count']}x)'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                widget.repository.retryPayout(p['id'] as String);
                setState(() => _failedPayouts.removeAt(index));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disbursement dijadwalkan ulang (Retry)')));
              },
              child: const Text('Retry'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStallTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allArtists.length,
      itemBuilder: (context, index) {
        final a = _allArtists[index];
        final isSuspended = a['status'] == 'suspended';

        return Card(
          child: ListTile(
            title: Text(a['display_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${a['category']} • ${a['base_city']} • ${a['total_job']} Pentas'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuspended ? AppColors.success : AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newStatus = !isSuspended;
                widget.repository.toggleSuspendArtist(a['id'] as String, newStatus);
                setState(() {
                  a['status'] = newStatus ? 'suspended' : 'verified';
                });
              },
              child: Text(isSuspended ? 'Buka Blokir' : 'Blokir Lapak'),
            ),
          ),
        );
      },
    );
  }
}
