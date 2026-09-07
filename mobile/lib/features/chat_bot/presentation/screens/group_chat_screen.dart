import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../voucher/presentation/screens/evoucher_screen.dart';
import '../../../voucher/data/models/evoucher_model.dart';

class GroupChatMessage {
  final String id;
  final String sender; // 'troupe' or 'user'
  final String senderName;
  final String text;
  final String time;
  final String? imageUrl;
  final String? imageTitle;
  final String? statusTag;

  const GroupChatMessage({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.text,
    required this.time,
    this.imageUrl,
    this.imageTitle,
    this.statusTag,
  });
}

class GroupChatScreen extends StatefulWidget {
  final String artistName;
  final String bookingCode;
  final String eventDate;
  final String venue;

  const GroupChatScreen({
    super.key,
    this.artistName = 'Dian Anic & Anica Nada',
    this.bookingCode = '#TRL-20251115-8892',
    this.eventDate = '15 Nov 2025',
    this.venue = 'Resepsi Pernikahan (Gunungjati, Cirebon)',
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<GroupChatMessage> _messages = [
    const GroupChatMessage(
      id: 'm1',
      sender: 'troupe',
      senderName: 'Manajemen Mbak Dian Anic',
      text: 'Sugeng siang Bpk. Sohibul Hajat, salam budaya 🙏 Kami dari manajemen Mbak Dian Anic siap mempersiapkan pentas hajatan di Gunungjati Cirebon.',
      time: '10:15 WIB',
    ),
    const GroupChatMessage(
      id: 'm2',
      sender: 'troupe',
      senderName: 'Manajemen Mbak Dian Anic',
      text: 'Untuk denah panggung dan pasokan daya genset 15.000 Watt apakah titik drop kru truk panggung sudah aman jalan masuknya?',
      time: '10:16 WIB',
    ),
    const GroupChatMessage(
      id: 'm3',
      sender: 'user',
      senderName: 'Sohibul Hajat',
      text: 'Siang Mas Broto. Jalan desa sudah diaspal lebar 5 meter, aman untuk truk fuso sound system. Ini saya kirim foto denah terop pengantin.',
      time: '10:20 WIB',
    ),
    const GroupChatMessage(
      id: 'm4',
      sender: 'user',
      senderName: 'Sohibul Hajat',
      text: 'Denah tenda & arah hadap panggung utama',
      time: '10:21 WIB',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBNqI48e0GsbZkJuSS-RHINyojd5eJFMpD2NLmYuHkM7yEzrt5AWKoVq9BlIpxKKKtiy8ZPrmfjs7hhDY9XqMFu_-8lDHDksBYga6FMNFAIveqhQLX6YVGQ9YnVFk_vxh5g2X_sI2mxRdbtCjOu2WiWg8qVJNQ6F6U7dNQHslbftCTPuSLlfmiqhtYJbpwBH5o597f2SMQV1jgavlaBJrvsHMw2yk9nauFYHTz0L4ZagZxb3R8avSp2DQ',
      imageTitle: 'IMG_DENAH_TEROP.JPG',
    ),
    const GroupChatMessage(
      id: 'm5',
      sender: 'troupe',
      senderName: 'Manajemen Mbak Dian Anic',
      text: 'Matur kesuwun Pak! Sangat jelas. Kami jadwalkan tim teknisi sound check tiba H-1 pukul 16:00 WIB nggih.',
      time: '10:25 WIB',
      statusTag: 'Jadwal Tersimpan',
    ),
  ];

  final List<String> _quickReplies = [
    '🎶 Request 10 Lagu Favorit',
    '👥 Konfirmasi Personil Sinden',
    '🍛 Info Konsumsi Kru Pentas',
    '⚡ Titik Stop Kontak Genset',
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage([String? customText]) {
    final txt = customText ?? _msgCtrl.text.trim();
    if (txt.isEmpty) return;

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    setState(() {
      _messages.add(
        GroupChatMessage(
          id: 'u-${DateTime.now().millisecondsSinceEpoch}',
          sender: 'user',
          senderName: 'Sohibul Hajat',
          text: txt,
          time: timeStr,
        ),
      );
    });

    _msgCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            boxShadow: const [
              BoxShadow(color: Color(0x0A22252A), blurRadius: 8, offset: Offset(0, 1)),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuB0FlD67Div0hvmGow2DtJUK8OA3-Qwu4-Lhd13GUVl-K_2N9giV7g0VoASjdBExJ4xaxZFd5eRaQ7vYHp6gnflQfHKUoWmaZ6yzws1T5wrZXCizF-FLzjYRVQttAb8dXOpTQRJKahMTrxeK8d0nVBeJRnRtoqStgwFe79Rly9qcSLW7n10HXK5_8TV3MPobPnWpo8C7dmEXMZ4_JxHhVwxoDrqb0mSN7kA--Ab145sa1N4oo-EKXmhEA',
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified, size: 10, color: AppColors.onSecondaryFixed),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.artistName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Online • Biasanya membalas dlm 1 jam',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppColors.tertiaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: AppColors.primary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menghubungi manajer grup: 0812-3456-7890')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Booking Context Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceContainerLow,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.confirmation_number, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.bookingCode,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            ' • Pentas ${widget.eventDate}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Text(
                        widget.venue,
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    final voucher = EVoucherModel(
                      code: widget.bookingCode,
                      voucherQrData: 'TRG-AUTH-${widget.bookingCode}',
                      artistName: widget.artistName,
                      packageName: 'Paket Komplit Siang-Malam',
                      eventDate: widget.eventDate,
                      venueAddress: widget.venue,
                      zone: 'Pantura Zona 1',
                      totalPrice: 25000000,
                      dpPaid: 5000000,
                      remainingCash: 20000000,
                      customerName: 'Bpk. Sohibul Hajat',
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EVoucherScreen(voucher: voucher)));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Kontrak',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSecondaryFixed,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward, size: 12, color: AppColors.onSecondaryFixed),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Date Chip Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'Hari Ini • Koordinasi Teknis Pagelaran',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Messages List View
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return _buildMessageBubble(m);
              },
            ),
          ),

          // Quick Replies Bar
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickReplies.length,
              itemBuilder: (context, index) {
                final r = _quickReplies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9999),
                    onTap: () => _sendMessage(r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        r,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Sticky Bottom Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan atau koordinasi lagu...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(GroupChatMessage m) {
    final isMe = m.sender == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAGU0VHbAExi6BpYHBJ5xec_fvB2Vw_Xc2ZCCuBkZJCoLq2-sS26bTuHIfo1RLaNKfJxgAIF1PSZLZ3k_LzZpQhD6wsR7attpVXRic_8FEuIhXrprFcyOgRlnIL1nOdKtb4ufsTtR5zysz_eszBXmXdxDKkBEqdHrsOfmqK8Q8Cxp5TKdLZxF6K7VcNIbUHZVSy9pqfTcskl4jbkKvt-XhhuDNe8gxUhrfNPPwY0i4b9tba8soQ07oP3A',
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryContainer : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x0622252A), blurRadius: 6, offset: Offset(0, 1)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Text(
                      m.senderName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  if (m.imageUrl != null) ...[
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.surfaceContainerHigh,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(m.imageUrl!, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    m.text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (m.statusTag != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            m.statusTag!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onTertiaryFixed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        m.time,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : AppColors.textMuted,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all, size: 14, color: AppColors.secondaryContainer),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
