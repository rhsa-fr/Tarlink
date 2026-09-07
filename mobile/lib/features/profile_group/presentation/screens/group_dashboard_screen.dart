import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../catalog/data/models/package_model.dart';
import '../../domain/repositories/group_repository.dart';

class GroupDashboardScreen extends StatefulWidget {
  final String artistId;
  final String artistName;
  final GroupRepository repository;

  const GroupDashboardScreen({
    super.key,
    required this.artistId,
    required this.artistName,
    required this.repository,
  });

  @override
  State<GroupDashboardScreen> createState() => _GroupDashboardScreenState();
}

class _GroupDashboardScreenState extends State<GroupDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _autoAccept = true;
  int _totalHold = 2300000;
  int _totalCompleted = 14500000;
  List<DateTime> _blockedDates = [];
  final List<PackageModel> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final dates = await widget.repository.getBlockedDates(widget.artistId);
      final summary = await widget.repository.getPayoutSummary(widget.artistId);

      setState(() {
        _blockedDates = dates;
        _totalHold = summary['totalHold'] as int? ?? _totalHold;
        _totalCompleted = summary['totalCompleted'] as int? ?? _totalCompleted;
      });
    } catch (_) {
      // Offline mock fallback
      setState(() {
        _blockedDates = [
          DateTime.now().add(const Duration(days: 3)),
          DateTime.now().add(const Duration(days: 4)),
        ];
        if (_packages.isEmpty) {
          _packages.addAll([
            PackageModel(
              id: 'p-1',
              artistId: widget.artistId,
              name: 'Organ Tunggal Fullday',
              durationHours: 12,
              price: 8000000,
              includes: 'Sound 5.000W, 2 Penyanyi, 1 Pemain Keyboard.',
            ),
            PackageModel(
              id: 'p-2',
              artistId: widget.artistId,
              name: 'Tarling Dangdut Kombinasi',
              durationHours: 14,
              price: 15000000,
              includes: 'Sound Gantung 15.000W, 4 Biduan, Gamelan lengkap.',
            ),
          ]);
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddPackageDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final includesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Paket Pentas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Nama Paket', controller: nameCtrl, hint: 'Misal: Sandiwara 1 Hari 1 Malam'),
              const SizedBox(height: 12),
              AppTextField(label: 'Harga Dasar (Rp)', controller: priceCtrl, keyboardType: TextInputType.number, hint: '12000000'),
              const SizedBox(height: 12),
              AppTextField(label: 'Fasilitas & Personil', controller: includesCtrl, hint: 'Pemain, sound, durasi jam'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
              if (nameCtrl.text.isNotEmpty && price > 0) {
                try {
                  await widget.repository.createPackage(
                    artistId: widget.artistId,
                    name: nameCtrl.text.trim(),
                    price: price,
                    includes: includesCtrl.text.trim(),
                  );
                } catch (_) {}
                setState(() {
                  _packages.add(PackageModel(
                    id: 'pkg-${DateTime.now().millisecondsSinceEpoch}',
                    artistId: widget.artistId,
                    name: nameCtrl.text.trim(),
                    price: price,
                    includes: includesCtrl.text.trim(),
                  ));
                });
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Simpan Paket'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lapak: ${widget.artistName}'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: 'Paket Pentas'),
            Tab(icon: Icon(Icons.event_busy), text: 'Kalender Libur'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Payout Saldo'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Banner Pengaturan Cepat Pimpinan (Auto Accept & Saldo)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Terima Booking Otomatis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(
                                _autoAccept ? 'Instant Booking langsung bayar DP' : 'Manual approve (12 jam)',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          Switch(
                            value: _autoAccept,
                            activeTrackColor: AppColors.success,
                            onChanged: (val) async {
                              setState(() => _autoAccept = val);
                              try {
                                await widget.repository.updateAutoAccept(widget.artistId, val);
                              } catch (_) {}
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Saldo Tertahan (H+2)', style: TextStyle(fontSize: 12, color: AppColors.primaryDark)),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.formatRupiah(_totalHold),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Telah Cair', style: TextStyle(fontSize: 12, color: Colors.green.shade800)),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyFormatter.formatRupiah(_totalCompleted),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade900),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Paket & Ongkir
                      _buildPackagesTab(),
                      // Tab 2: Kalender Libur
                      _buildCalendarTab(),
                      // Tab 3: Payout
                      _buildPayoutTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPackagesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppButton(
          label: '+ Tambah Paket Baru',
          icon: Icons.add,
          onPressed: _showAddPackageDialog,
        ),
        const SizedBox(height: 16),
        ..._packages.map((pkg) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(CurrencyFormatter.formatRupiah(pkg.price),
                        style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                    if (pkg.includes != null) ...[
                      const SizedBox(height: 4),
                      Text(pkg.includes!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    setState(() => _packages.removeWhere((p) => p.id == pkg.id));
                  },
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildCalendarTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Tandai Tanggal Libur Mandiri (Fullday)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tanggal yang diliburkan otomatis menjadi MERAH di pencarian Bu Hajat dan tidak bisa di-booking.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Pilih Tanggal Untuk Diliburkan',
          icon: Icons.calendar_today,
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              await widget.repository.addBlockedDate(widget.artistId, picked, 'Libur mandiri');
              setState(() => _blockedDates.add(picked));
            }
          },
        ),
        const SizedBox(height: 20),
        const Text('Daftar Tanggal Libur Aktif:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        if (_blockedDates.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('Belum ada tanggal libur yang ditandai (Semua hari hijau)')),
          )
        else
          ..._blockedDates.map((date) => Card(
                child: ListTile(
                  leading: const Icon(Icons.block, color: AppColors.error),
                  title: Text(DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date)),
                  subtitle: const Text('Libur Mandiri Fullday'),
                  trailing: TextButton(
                    onPressed: () async {
                      await widget.repository.removeBlockedDate(widget.artistId, date);
                      setState(() => _blockedDates.remove(date));
                    },
                    child: const Text('Buka Hari', style: TextStyle(color: AppColors.success)),
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildPayoutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rekening Pencairan Bank Terdaftar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 8),
                Text('Bank BRI • No. Rek: 0123-4567-8901-23', style: TextStyle(fontSize: 14)),
                Text('Atas Nama: Sanggar Dharma Kudeta', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                Divider(height: 20),
                Text(
                  'Sisa uang DP (setelah fee platform 8%) otomatis ditransfer H+2 setelah acara berstatus Selesai.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Riwayat Pencairan Otomatis (Disbursement)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.hourglass_top, color: AppColors.primaryDark),
            ),
            title: const Text('Job TRG-2026-0042'),
            subtitle: const Text('Status: HOLD (Menunggu H+2 Acara)'),
            trailing: Text(
              CurrencyFormatter.formatRupiah(2300000),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.check, color: Colors.green.shade800),
            ),
            title: const Text('Job TRG-2026-0021'),
            subtitle: const Text('Status: COMPLETED (Ditransfer ke BRI)'),
            trailing: Text(
              CurrencyFormatter.formatRupiah(4600000),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green.shade800),
            ),
          ),
        ),
      ],
    );
  }
}
