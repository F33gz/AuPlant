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
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: plantEmojis.length,
            itemBuilder: (context, index) {
              final emoji = plantEmojis[index];
              final isSelected = emoji == selectedEmoji;
              
              return GestureDetector(
                onTap: () => onEmojiSelected(emoji),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryGreenAlpha10 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primaryGreen 
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
