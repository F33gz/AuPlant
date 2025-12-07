import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class WateringButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const WateringButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: AppColors.info,
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.water_drop, color: Colors.white),
      label: Text(
        isLoading ? 'Regando...' : 'Regar',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
