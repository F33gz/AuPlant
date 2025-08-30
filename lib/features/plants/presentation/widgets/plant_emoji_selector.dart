import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Plant Emoji Selector Widget
/// 
/// Widget for selecting plant emoji with grid layout
class PlantEmojiSelector extends StatelessWidget {
  final String selectedEmoji;
  final List<String> plantEmojis;
  final Function(String) onEmojiSelected;

  const PlantEmojiSelector({
    super.key,
    required this.selectedEmoji,
    required this.plantEmojis,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elige el icono de la planta',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive, gapless layout using Wrap so the last row doesn't leave a big blank tail.
              const double itemSize = 44; // square tile
              const double minSpacing = 8; // minimum spacing between tiles

              // Calculate columns that fit while keeping at least the minimum spacing
              final int columns =
                  (constraints.maxWidth / (itemSize + minSpacing))
                      .floor()
                      .clamp(1, plantEmojis.length);

              // Distribute any extra space as additional spacing to avoid large blanks
              final double remaining =
                  constraints.maxWidth - (columns * itemSize);
              final double spacing =
                  columns > 1 ? remaining / (columns - 1) : 0;

              return Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.start,
                spacing: spacing < minSpacing ? minSpacing : spacing,
                runSpacing: 12,
                children: plantEmojis.map((emoji) {
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
