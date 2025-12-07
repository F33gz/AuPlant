import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Custom Dropdown Widget
/// 
/// Reusable dropdown with consistent styling across the app
class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String? label;
  final String Function(T) getDisplayText;
  final void Function(T?) onChanged;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.getDisplayText,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          style: TextStyle(color: isDark ? AppColors.textOnDark : AppColors.textPrimary),
          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.backgroundWhite,
          iconEnabledColor: isDark ? AppColors.textMutedOnDark : null,
          iconDisabledColor: isDark ? AppColors.textMutedOnDark : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.backgroundWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryGreen),
            ),
          ),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                getDisplayText(item),
                style: TextStyle(color: isDark ? AppColors.textOnDark : AppColors.textPrimary),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
