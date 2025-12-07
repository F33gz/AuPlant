import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/auth_logo.dart';
import '../widgets/login_form_widget.dart';
import '../widgets/auth_actions.dart';

/// Login Page - ThingsBoard Authentication
/// 
/// Handles user login using ThingsBoard API.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.paddingXXL),
          child: Column(
            children: [
              const SizedBox(height: UIConstants.spacingXXXL),
              const AuthLogo(),
              const SizedBox(height: UIConstants.spacingXXL),
              LoginFormWidget(
                onLogin: _handleLogin,
                isLoading: _isLoading,
              ),
              const SizedBox(height: UIConstants.spacingXXL),
              const AuthActions(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() => _isLoading = true);
    
    try {
      final authRepository = GetIt.instance<AuthRepository>();
      final result = await authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      result.when(
        success: (user) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        failure: (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error de login: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de login: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

