import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget Logo GreenSpace officiel
/// Utilise greenspace_logo.svg (icône cacao) + greenspace_text.svg (wordmark)
class GSLogoWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool withText;
  final bool textOnly;
  final bool horizontal;
  final Color? textColor;

  const GSLogoWidget({
    super.key,
    this.width = 80,
    this.height = 80,
    this.withText = true,
    this.textOnly = false,
    this.horizontal = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (textOnly) {
      return _wordmark(width * 0.28);
    }

    final icon = SvgPicture.asset(
      'assets/svg/greenspace_logo.svg',
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => _fallback(width, height),
    );

    if (!withText) return icon;

    if (horizontal) {
      final iconSize = width * 0.45;
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/greenspace_logo.svg',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => _fallback(iconSize, iconSize),
          ),
          const SizedBox(width: 8),
          _wordmark(iconSize * 0.32),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 10),
        _wordmark(width * 0.22),
      ],
    );
  }

  /// Texte GREENSPACE bicolore (GREEN vert + SPACE marron)
  Widget _wordmark(double fontSize) {
    if (textColor != null) {
      // Version monochrome (ex: sur fond vert)
      return Text(
        'GREENSPACE',
        style: TextStyle(
          fontSize: fontSize.clamp(10, 40),
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          color: textColor,
          letterSpacing: 1.5,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'GREEN',
            style: TextStyle(
              fontSize: fontSize.clamp(10, 40),
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF2E7D32),
              letterSpacing: 1.5,
            ),
          ),
          TextSpan(
            text: 'SPACE',
            style: TextStyle(
              fontSize: fontSize.clamp(10, 40),
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF6D4C1F),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(double w, double h) => Container(
    width: w, height: h,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text('🌿', style: TextStyle(fontSize: w * 0.45)),
    ),
  );
}
