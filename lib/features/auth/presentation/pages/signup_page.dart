import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../widgets/auth_logo.dart';

/// Signup Page - Informational
/// 
/// ThingsBoard does not support self-registration.
/// Users must be created by an administrator.
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textOnDark : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.paddingXXL),
          child: Column(
            children: [
              const SizedBox(height: UIConstants.spacingL),
              const AuthLogo(),
              const SizedBox(height: UIConstants.spacingXL),
              Text(
                'Crear cuenta',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXXL),
              _buildInfoCard(context, isDark),
              const SizedBox(height: UIConstants.spacingXL),
              _buildLoginPrompt(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingXL),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.surfaceDark 
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: UIConstants.spacingL),
          Text(
            'Registro no disponible',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingM),
          Text(
            'El registro de nuevas cuentas debe ser realizado por un administrador del sistema.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingM),
          Text(
            'Por favor, contacta al administrador para solicitar acceso.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes una cuenta? ',
          style: AppTextStyles.bodyMedium,
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Inicia sesión',
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
