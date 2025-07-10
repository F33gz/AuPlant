import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'plant_detail_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/plant_service.dart';
import '../../../../core/models/plant_model.dart';

/// Plant Controls Section
/// 
/// Provides irrigation and automation controls for the plant.
/// Includes manual watering, automatic mode toggle, and settings access.
/// 
/// Features:
/// - Manual irrigation button with loading animation
/// - Automatic mode toggle switch
/// - Settings button for threshold configuration
/// - Proper state management and user feedback
/// - Accessibility support
class PlantControlsSection extends StatefulWidget {
  final bool isOnline;
  final bool isAutoMode;
  final bool isWatering;
  final String plantName;
  final VoidCallback? onWaterNow;
  final ValueChanged<bool>? onAutoModeToggle;
  final VoidCallback? onSettingsPressed;
  // NUEVO: Recibe el modelo de planta para obtener el accessToken
  final PlantModel plant;

  const PlantControlsSection({
    super.key,
    required this.isOnline,
    required this.isAutoMode,
    required this.isWatering,
    required this.plantName,
    required this.plant,
    this.onWaterNow,
    this.onAutoModeToggle,
    this.onSettingsPressed,
  });

  @override
  State<PlantControlsSection> createState() => _PlantControlsSectionState();
}

class _PlantControlsSectionState extends State<PlantControlsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final PlantService _plantService = PlantService();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: PlantDetailConstants.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PlantDetailConstants.spacingL),
      decoration: PlantDetailConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWaterNowButton(),
          const SizedBox(height: PlantDetailConstants.spacingL),
          _buildControlsRow(),
        ],
      ),
    );
  }

  /// Builds the manual irrigation button with animation
  Widget _buildWaterNowButton() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            height: 56, // Increased height for better touch target
            child: ElevatedButton(
              onPressed: widget.isOnline ? _handleWaterNow : null,
              style: widget.isOnline
                  ? _getEnhancedButtonStyle()
                  : PlantDetailConstants.disabledButtonStyle,
              child: _buildButtonContent(),
            ),
          ),
        );
      },
    );
  }

  /// Enhanced button style with better contrast and mobile-friendly design
  ButtonStyle _getEnhancedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 3,
      shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(
        horizontal: PlantDetailConstants.spacingL,
        vertical: PlantDetailConstants.spacingM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Add a subtle border for better definition
      side: BorderSide(
        color: AppColors.primaryGreen.withValues(alpha: 0.8),
        width: 1,
      ),
    );
  }

  /// Builds the button content with loading state
  Widget _buildButtonContent() {
    if (widget.isWatering) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Regando...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.water_drop,
          size: 22,
          color: Colors.white,
        ),
        const SizedBox(width: 12),
        Text(
          'Regar',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Builds the controls row with auto mode toggle and settings
  Widget _buildControlsRow() {
    return Row(
      children: [
        Expanded(child: _buildAutoModeToggle()),
        const SizedBox(width: PlantDetailConstants.spacingL),
        _buildSettingsButton(),
      ],
    );
  }

  /// Builds the automatic mode toggle
  Widget _buildAutoModeToggle() {
    return Container(
      padding: const EdgeInsets.all(PlantDetailConstants.spacingL),
      decoration: PlantDetailConstants.controlItemDecoration,
      child: Row(
        children: [
          Icon(
            widget.isAutoMode ? Icons.auto_mode : Icons.touch_app,
            color: PlantDetailConstants.primaryGreen,
            size: PlantDetailConstants.iconSizeL,
          ),
          const SizedBox(width: PlantDetailConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo Automático',
                  style: PlantDetailConstants.titleSmall,
                ),
                Text(
                  widget.isAutoMode ? 'Activado' : 'Desactivado',
                  style: PlantDetailConstants.bodyMedium,
                ),
              ],
            ),
          ),
          Switch(
            value: widget.isAutoMode,
            onChanged: widget.isOnline ? (value) async {
              if (widget.onAutoModeToggle != null) widget.onAutoModeToggle!(value);
            } : null,
            activeColor: PlantDetailConstants.successColor,
          ),
        ],
      ),
    );
  }

  /// Builds the settings button
  Widget _buildSettingsButton() {
    return Container(
      decoration: PlantDetailConstants.controlItemDecoration,
      child: IconButton(
        onPressed: widget.onSettingsPressed,
        icon: const Icon(
          Icons.settings,
          color: PlantDetailConstants.primaryGreen,
        ),
        tooltip: 'Configurar umbrales',
      ),
    );
  }

  /// Handles water now button press with animation
  void _handleWaterNow() async {
    if (_isSending) return;
    final accessToken = widget.plant.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('AccessToken inesperadamente null o vacío. Revisa el modelo de planta.');
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Regar ${widget.plant.name}'),
        content: const Text('¿Estás seguro de que quieres regar esta planta ahora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Regar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    print('[DEBUG] Enviando regado: accessToken= [32m$accessToken [0m, atributos={ "manual": true }');
    setState(() { _isSending = true; });
    try {
      await _plantService.sendRegadoCommand(
        accessToken: accessToken,
        atributos: { 'manual': true },
      );
      if (widget.onWaterNow != null) widget.onWaterNow!();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comando de riego enviado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando comando: $e')),
      );
    } finally {
      setState(() { _isSending = false; });
    }
  }
}
