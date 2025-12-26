import 'package:flutter/material.dart';

/// Usage:
/// LanguageButton(
///   current: 'en',
///   onChanged: (code) {
///     // TODO: handle language switch
///     // e.g., setState(() => _lang = code);
///     // or provider.changeLanguage(code);
///   },
/// ),
class LanguageButton extends StatelessWidget {
  const LanguageButton({
    super.key,
    required this.current,
    required this.onChanged,
    this.iconSize = 40, // visual diameter
  });

  final String current; // 'en' or 'ta'
  final ValueChanged<String> onChanged;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final double min = 32, max = 48;
    final double clamped = iconSize.clamp(min, max);
    final double innerIcon = (iconSize * 0.5).clamp(16, 24);

    return PopupMenuButton<String>(
      tooltip: 'Change language',
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'en', child: Text('English')),
        PopupMenuItem(value: 'ta', child: Text('Tamil')),
      ],
      child: Container(
        width: clamped,
        height: clamped,
        decoration: const ShapeDecoration(
          color: Color(0xFFCBF8DD),
          shape: OvalBorder(),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.translate, color: Colors.green, size: innerIcon),
      ),
    );
  }
}
