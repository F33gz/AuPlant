import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../widgets/auth_logo.dart';
import '../widgets/signup_form_widget.dart';

/// Signup Page - Clean and Focused
/// 
/// Only handles page structure and navigation.
/// All form logic is extracted to separate widgets.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXL),
              SignupFormWidget(
                onSignup: _handleSignup,
                isLoading: _isLoading,
              ),
              const SizedBox(height: UIConstants.spacingL),
              _buildLoginPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
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

  Future<void> _handleSignup(String name, String email, String password) async {
    setState(() => _isLoading = true);
    
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      
      if (response.session != null && mounted) {
        Navigator.pushReplacementNamed(context, '/');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor verifica tu correo electrónico'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de registro: ${e.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de registro: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
