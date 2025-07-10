import 'package:flutter/material.dart';
import 'plant_detail_constants.dart';

/// Plant Detail App Bar
/// 
/// A custom app bar component for the plant detail view that displays
/// the plant name, emoji, connection status, and back button.
/// 
/// Features:
/// - Plant name with emoji
/// - Online/offline status indicator
/// - Custom back button with proper navigation
/// - Consistent styling with the app theme
/// - Responsive text handling with overflow protection
class PlantDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String plantName;
  final String plantEmoji;
  final bool isOnline;
  final VoidCallback? onBackPressed;

  const PlantDetailAppBar({
    super.key,
    required this.plantName,
    required this.plantEmoji,
    required this.isOnline,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: PlantDetailConstants.cardBackground,
      elevation: PlantDetailConstants.elevationLow,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      leading: _buildBackButton(context),
      title: _buildTitle(),
      actions: [_buildConnectionStatus()],
    );
  }

  /// Builds the back button with custom styling
  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios,
        color: PlantDetailConstants.primaryGreen,
      ),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      tooltip: 'Volver',
    );
  }

  /// Builds the title section with plant emoji and name
  Widget _buildTitle() {
    return Row(
      children: [
        Text(
          plantEmoji,
          style: const TextStyle(fontSize: PlantDetailConstants.iconSizeL),
        ),
        const SizedBox(width: PlantDetailConstants.spacingM),
        Expanded(
          child: Text(
            plantName,
            style: PlantDetailConstants.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the connection status indicator
  Widget _buildConnectionStatus() {
    return Container(
      margin: const EdgeInsets.only(right: PlantDetailConstants.spacingL),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: PlantDetailConstants.connectionIndicatorSize,
            height: PlantDetailConstants.connectionIndicatorSize,
            decoration: BoxDecoration(
              color: isOnline 
                  ? PlantDetailConstants.successColor 
                  : PlantDetailConstants.errorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: PlantDetailConstants.spacingS),
          Text(
            isOnline ? 'En línea' : 'Sin conexión',
            style: (isOnline 
                ? PlantDetailConstants.successText 
                : PlantDetailConstants.errorText),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
