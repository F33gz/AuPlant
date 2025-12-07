import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Station Emoji Selector Widget
/// 
/// Widget for selecting station/greenhouse emoji with grid layout
class StationEmojiSelector extends StatelessWidget {
  final String selectedEmoji;
  final List<String>? stationEmojis;
  final Function(String) onEmojiSelected;

  // Emojis relevant for greenhouse monitoring stations
  static const List<String> _defaultEmojis = [
    '🌡️', '💧', '🌿', '🌱', '🏠', '📡', '🔬',
    '🌾', '🌻', '🍅', '🥬', '🌶️', '🥕', '🍓',
  ];

  const StationEmojiSelector({
    super.key,
    required this.selectedEmoji,
    this.stationEmojis,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emojis = stationEmojis ?? _defaultEmojis;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elige el icono de la estación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double itemSize = 44;
              const double minSpacing = 8;

              final int columns =
                  (constraints.maxWidth / (itemSize + minSpacing))
                      .floor()
                      .clamp(1, emojis.length);

              final double remaining =
                  constraints.maxWidth - (columns * itemSize);
              final double spacing =
                  columns > 1 ? remaining / (columns - 1) : 0;

              return Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.start,
                spacing: spacing < minSpacing ? minSpacing : spacing,
                runSpacing: 12,
                children: emojis.map((emoji) {
                  final isSelected = emoji == selectedEmoji;
                  return SizedBox(
                    width: itemSize,
                    height: itemSize,
                    child: Material(
                      color: isSelected
                          ? AppColors.primaryGreenAlpha10
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => onEmojiSelected(emoji),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
