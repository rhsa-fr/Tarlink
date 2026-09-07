import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/booking_offer_model.dart';
import '../../data/repositories/booking_repository_impl.dart';

class CustomNegoScreen extends StatefulWidget {
  final String bookingId;
  final String bookingCode;
  final String artistName;
  final String eventDate;
  final int initialPrice;
  final bool isGroupLeader;

  const CustomNegoScreen({
    super.key,
    required this.bookingId,
    required this.bookingCode,
    required this.artistName,
    required this.eventDate,
    required this.initialPrice,
    this.isGroupLeader = false,
  });

  @override
  State<CustomNegoScreen> createState() => _CustomNegoScreenState();
}

class _CustomNegoScreenState extends State<CustomNegoScreen> {
  final _msgCtrl = TextEditingController();
  List<BookingOfferModel> _offers = [];
  List<BookingMessageModel> _messages = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _loadNegoData();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    try {
      final client = SupabaseService.client;
      _realtimeChannel = client.channel('booking_nego_${widget.bookingId}')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'booking_offers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'booking_id',
            value: widget.bookingId,
          ),
          callback: (_) => _loadNegoData(silent: true),
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'booking_id',
            value: widget.bookingId,
          ),
          callback: (_) => _loadNegoData(silent: true),
        )
        ..subscribe();
    } catch (_) {
      // Offline fallback
    }
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNegoData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final repo = BookingRepositoryImpl(SupabaseService.client);
      final offers = await repo.getOffers(widget.bookingId);
      final msgs = await repo.getMessages(widget.bookingId);

      if (mounted) {
        setState(() {
          _offers = offers;
          _messages = msgs;
        });
      }
    } catch (_) {
      // Mock initial data if offline / preview
      if (mounted) {
        setState(() {
          _offers = [
            BookingOfferModel(
              id: 'off-1',
              bookingId: widget.bookingId,
              offeredBy: 'customer',
              amount: widget.initialPrice,
              note: 'Minta tambah biduan Siti + main sampai jam 01.00 malam',
              round: 1,
              status: 'proposed',
              expiresAt: DateTime.now().add(const Duration(hours: 10)),
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
          ];
          _messages = [
            BookingMessageModel(
              id: 'msg-1',
              bookingId: widget.bookingId,
              senderId: 'customer',
              text: 'Assalamu alaikum pimpinan, bisa tambah biduan Siti dan main sampai jam 1 malam?',
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
          ];
        });
      }
    } finally {
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  int get _currentRound => _offers.isEmpty ? 1 : _offers.last.round;
  BookingOfferModel? get _latestOffer => _offers.isEmpty ? null : _offers.last;

  Future<void> _handleAccept() async {
    final offer = _latestOffer;
    if (offer == null) return;

    setState(() => _isProcessing = true);
    try {
      final repo = BookingRepositoryImpl(SupabaseService.client);
      await repo.acceptOffer(
        bookingId: widget.bookingId,
        offerId: offer.id,
        lockedPrice: offer.amount,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Kesepakatan Tercapai!'),
          content: Text(
            'Harga telah TERKUNCI pada ${CurrencyFormatter.formatRupiah(offer.amount)}.\nStatus booking kini WAITING_DP. Silakan lakukan pembayaran DP 20% dalam waktu 24 jam untuk mengunci tanggal pentas.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Lanjut ke Pembayaran DP'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showCounterOfferDialog() {
    if (_currentRound >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batas maksimal 3 ronde tawar-menawar telah tercapai. Harap Terima atau Tolak.')),
      );
      return;
    }

    final priceCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ajukan Tawaran Balasan (Ronde ${_currentRound + 1}/3)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Nominal Tawaran Baru (Rp)',
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              hint: '13500000',
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Alasan / Catatan Penawaran',
              controller: noteCtrl,
              hint: 'Misal: Tambah biaya akomodasi kru malam',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final newPrice = int.tryParse(priceCtrl.text.trim()) ?? 0;
              if (newPrice > 0) {
                final nextRound = _currentRound + 1;
                final newOffer = BookingOfferModel(
                  id: 'off-${DateTime.now().millisecondsSinceEpoch}',
                  bookingId: widget.bookingId,
                  offeredBy: widget.isGroupLeader ? 'group' : 'customer',
                  amount: newPrice,
                  note: noteCtrl.text.trim(),
                  round: nextRound,
                  status: 'proposed',
                  expiresAt: DateTime.now().add(const Duration(hours: 12)),
                  createdAt: DateTime.now(),
                );

                setState(() => _offers.add(newOffer));
                Navigator.of(ctx).pop();

                try {
                  final repo = BookingRepositoryImpl(SupabaseService.client);
                  final userId = SupabaseService.client.auth.currentUser?.id ?? 'user-id';
                  await repo.submitOffer(
                    bookingId: widget.bookingId,
                    offeredBy: userId,
                    amount: newPrice,
                    round: nextRound,
                    note: noteCtrl.text.trim(),
                  );
                } catch (_) {}
              }
            },
            child: const Text('Kirim Tawaran'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final newMsg = BookingMessageModel(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: widget.bookingId,
      senderId: widget.isGroupLeader ? 'group' : 'customer',
      text: text,
      createdAt: DateTime.now(),
    );

    setState(() => _messages.add(newMsg));
    _msgCtrl.clear();

    try {
      final repo = BookingRepositoryImpl(SupabaseService.client);
      final userId = SupabaseService.client.auth.currentUser?.id ?? 'user-id';
      await repo.sendMessage(
        bookingId: widget.bookingId,
        senderId: userId,
        text: text,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nego Custom: ${widget.bookingCode}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Banner Ronde & Status Anti-PHP
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColors.primaryLight,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ronde $_currentRound / 3',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Batas Waktu: 12 Jam per Ronde',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                            ),
                            Text(
                              'Jika lewat 12 jam tanpa respon, penawaran otomatis batal.',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Riwayat Tawaran Harga
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tawaran Harga Terakhir:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _latestOffer != null
                                ? CurrencyFormatter.formatRupiah(_latestOffer!.amount)
                                : CurrencyFormatter.formatRupiah(widget.initialPrice),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                          if (_latestOffer != null && _latestOffer!.note != null)
                            Expanded(
                              child: Text(
                                '"${_latestOffer!.note!}"',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chat Log Per-Booking
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      final isMe = widget.isGroupLeader ? m.senderId == 'group' : m.senderId == 'customer';
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.secondary : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMe ? 'Anda' : (widget.isGroupLeader ? 'Bu Hajat (Customer)' : widget.artistName),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isMe ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('HH:mm').format(m.createdAt),
                                style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : Colors.black45),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Chat Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          decoration: InputDecoration(
                            hintText: 'Tulis pesan nego / koordinasi...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onSubmitted: (_) => _handleSendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: _handleSendMessage,
                      ),
                    ],
                  ),
                ),

                // Decision Action Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Tolak', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_currentRound < 3)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: AppColors.secondary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _showCounterOfferDialog,
                            child: const Text('Nego Balik', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      if (_currentRound < 3) const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isProcessing ? null : _handleAccept,
                          child: const Text('Sepakat & Lock', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
