import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/bot_message_model.dart';
import '../screens/group_chat_screen.dart';

/// Floating 24/7 CS Bot Widget supporting FAQ, Dispute Intake, and Gaptek Leader commands.
class FloatingChatBot extends StatefulWidget {
  final Widget child;

  const FloatingChatBot({super.key, required this.child});

  @override
  State<FloatingChatBot> createState() => _FloatingChatBotState();
}

class _FloatingChatBotState extends State<FloatingChatBot> {
  void _openChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatBotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void openChat() => _openChatSheet();
}

void openChatBotSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ChatBotSheet(),
  );
}

class ChatBotSheet extends StatefulWidget {
  const ChatBotSheet({super.key});

  @override
  State<ChatBotSheet> createState() => _ChatBotSheetState();
}

class _ChatBotSheetState extends State<ChatBotSheet> {
  final _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<BotMessageModel> _messages = [
    BotMessageModel(
      id: 'm-0',
      sender: 'bot',
      text: 'Sampurasun! Saya asisten virtual TarlingKu 🙏\nAda yang bisa kami bantu seputar booking pentas, jadwal, atau koordinasi lapak seni?',
      createdAt: DateTime.now(),
    ),
  ];
  bool _isTyping = false;

  final List<String> _quickChips = [
    'Cara bayar DP?',
    'Kapan saldo cair?',
    'Aturan reschedule?',
    'Lapor Sengketa',
    'Chat Grup Dian Anic',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (text == 'Chat Grup Dian Anic') {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const GroupChatScreen(),
        ),
      );
      return;
    }

    final userMsg = BotMessageModel(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      sender: 'user',
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    try {
      final userId = SupabaseService.client.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000001';
      final res = await SupabaseService.client.functions.invoke(
        'bot-engine',
        body: {
          'user_id': userId,
          'text': userMsg.text,
        },
      );

      final reply = (res.data as Map<String, dynamic>?)?['reply'] as String? ??
          'Pesan diterima oleh asisten pasar.';

      setState(() {
        _messages.add(BotMessageModel(
          id: 'b-${DateTime.now().millisecondsSinceEpoch}',
          sender: 'bot',
          text: reply,
          createdAt: DateTime.now(),
        ));
      });
    } catch (_) {
      // Local fallback for offline simulation
      String fallbackReply = 'Saya mencatat pertanyaan Anda. Tim Admin Pasar akan meninjau secepatnya.';
      final lower = text.toLowerCase();
      if (lower.contains('dp')) {
        fallbackReply = 'DP 20% dibayarkan via QRIS/VA melalui Midtrans dalam 30 menit setelah booking dibuat.';
      } else if (lower.contains('cair')) {
        fallbackReply = 'Saldo sisa DP (setelah potongan fee lapak 8%) otomatis ditransfer H+2 setelah pentas selesai.';
      } else if (lower.contains('liburkan')) {
        fallbackReply = 'Siap pimpinan grup! Tanggal yang Anda sebutkan telah ditandai libur di kalender lapak.';
      } else if (lower.contains('sengketa') || lower.contains('lapor')) {
        fallbackReply = 'Laporan kendala telah dibuka. Payout ke grup ditahan sementara sampai verifikasi selesai.';
      }

      setState(() {
        _messages.add(BotMessageModel(
          id: 'b-${DateTime.now().millisecondsSinceEpoch}',
          sender: 'bot',
          text: fallbackReply,
          createdAt: DateTime.now(),
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Header Sheet
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.support_agent, color: Colors.white, size: 24),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asisten CS TarlingKu (24/7)',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'In-App Auto Bot • Solusi Cepat Pantura',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Messages Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
                    decoration: BoxDecoration(
                      color: m.isUser ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(m.isUser ? 16 : 4),
                        bottomRight: Radius.circular(m.isUser ? 4 : 16),
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0622252A), blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                    child: Text(
                      m.text,
                      style: GoogleFonts.plusJakartaSans(
                        color: m.isUser ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Asisten sedang mengetik...',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),

          // Quick Action Chips
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _quickChips.length,
              itemBuilder: (context, index) {
                final chip = _quickChips[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9999),
                    onTap: () => _sendMessage(chip),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        chip,
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

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: TextField(
                      controller: _inputCtrl,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan atau pertanyaan...',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_inputCtrl.text),
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
        ],
      ),
    );
  }
}
