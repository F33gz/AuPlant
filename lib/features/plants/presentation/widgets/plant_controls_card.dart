import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';

class PlantControlsCard extends StatefulWidget {
  final bool isOnline;
  final bool initialAutoMode;
  final VoidCallback onWaterNow;
  final ValueChanged<bool> onAutoModeChanged;
  final VoidCallback? onOpenSettings;

  const PlantControlsCard({
    super.key,
    required this.isOnline,
    required this.initialAutoMode,
    required this.onWaterNow,
  required this.onAutoModeChanged,
  this.onOpenSettings,
  });

  @override
  State<PlantControlsCard> createState() => _PlantControlsCardState();
}

class _PlantControlsCardState extends State<PlantControlsCard> {
  late bool _auto;

  @override
  void initState() {
    super.initState();
    _auto = widget.initialAutoMode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(UIConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _waterButton(),
          const SizedBox(height: UIConstants.spacingL),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _autoModeRow()),
              const SizedBox(width: UIConstants.spacingM),
              _settingsButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _waterButton() {
  final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.isOnline ? widget.onWaterNow : null,
        icon: const Icon(Icons.water_drop),
        label: const Text('Regar'),
        style: ElevatedButton.styleFrom(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _autoModeRow() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_mode, color: cs.primary),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Modo Automático', style: AppTextStyles.titleSmall),
                Text(_auto ? 'Activado' : 'Desactivado', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: _auto,
            activeThumbColor: cs.primary,
            activeTrackColor: AppColors.primaryGreenAlpha30,
            onChanged: (v) {
              setState(() => _auto = v);
              widget.onAutoModeChanged(v);
            },
          )
        ],
      ),
    );
  }

  Widget _settingsButton() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: widget.onOpenSettings,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.primary),
          ),
          child: Icon(Icons.settings, color: cs.primary),
        ),
      ),
    );
  }
}
