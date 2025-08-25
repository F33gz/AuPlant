import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Common loading indicators for the application
class LoadingIndicators {
  /// Standard circular progress indicator with app colors
  static Widget circular({Color? color}) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? AppColors.primaryGreen,
      ),
    );
  }

  /// Small circular progress indicator for buttons
  static Widget circularSmall({Color? color}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }

  /// Loading overlay for full screen
  static Widget overlay({String? message}) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            circular(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
