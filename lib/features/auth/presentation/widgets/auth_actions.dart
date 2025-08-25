import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_routes.dart';

/// Authentication action widgets (forgot password, signup prompt)
class AuthActions extends StatelessWidget {
  const AuthActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildForgotPassword(context),
        const SizedBox(height: 24),
        _buildSignupPrompt(context),
      ],
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La funcionalidad de recuperar contraseña aún no está implementada'),
          ),
        );
      },
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildSignupPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes una cuenta? ',
          style: AppTextStyles.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.signup);
          },
          child: Text(
            'Regístrate',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
