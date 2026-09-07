import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Logo resmi aplikasi Tarlink (Pure Flutter Widget, zero asset dependency)
class TarlinkLogo extends StatelessWidget {
  final double height;
  final bool showSubtitle;
  final Color? textColor;

  const TarlinkLogo({
    super.key,
    this.height = 32,
    this.showSubtitle = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = height;
    final fontSize = height * 0.62;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Mark Icon (Gradient Tile with Music Glyph)
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(height * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.queue_music,
              size: height * 0.58,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: height * 0.25),

        // Brand Typography
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.02 * fontSize,
                ),
                children: [
                  TextSpan(
                    text: 'Tar',
                    style: TextStyle(
                      color: textColor ?? AppColors.primary,
                    ),
                  ),
                  const TextSpan(
                    text: 'link',
                    style: TextStyle(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showSubtitle)
              Text(
                'SENI PANTURA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: fontSize * 0.42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
