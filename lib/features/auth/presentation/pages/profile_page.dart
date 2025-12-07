import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/theme_mode_selector.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart' as app_user;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  app_user.User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authRepo = GetIt.instance<AuthRepository>();
    final result = await authRepo.getCurrentUser();
    if (result.isSuccess && mounted) {
      setState(() {
        _user = result.dataOrNull;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final authRepo = GetIt.instance<AuthRepository>();
      await authRepo.signOut();
      
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: AppTextStyles.headlineMedium.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.paddingXXL),
          child: Column(
            children: [
              const SizedBox(height: UIConstants.spacingXL),
              _buildProfileHeader(_user),
              const SizedBox(height: UIConstants.spacingXXL),
              _buildProfileOptions(context),
              const Spacer(),
              _buildLogoutButton(context),
              const SizedBox(height: UIConstants.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(app_user.User? user) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            border: Border.all(
              color: AppColors.primaryGreen,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.person,
            size: 50,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: UIConstants.spacingL),
        
        // User name
        Text(
          user?.displayName ?? 'Usuario',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: UIConstants.spacingS),
        
        // Email
        Text(
          user?.email ?? 'email@ejemplo.com',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          context: context,
          icon: Icons.palette_outlined,
          title: 'Apariencia',
          onTap: () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Modo de tema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 12),
                    ThemeModeSelector(),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: UIConstants.spacingM),
        _buildOptionTile(
          context: context,
          icon: Icons.notifications_outlined,
          title: 'Notificaciones',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
        ),
        const SizedBox(height: UIConstants.spacingM),
        _buildOptionTile(
          context: context,
          icon: Icons.person_outline,
          title: 'Editar Perfil',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.editProfile),
        ),
        const SizedBox(height: UIConstants.spacingM),
        
  // Removed Help & Support section as requested
        
        _buildOptionTile(
          context: context,
          icon: Icons.info_outline,
          title: 'Acerca de AuPlant',
          onTap: () {
            _showAboutDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1C1E) : AppColors.backgroundWhite,
        border: Border.all(color: isDark ? const Color(0xFF2B2E31) : AppColors.border),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.primaryGreen,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? const Color(0xFFE6E8E6) : AppColors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? const Color(0xFF8B938C) : AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF2B1F21) : Colors.red.shade50,
          foregroundColor: isDark ? const Color(0xFFFFB4AB) : Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
            side: BorderSide(color: isDark ? const Color(0xFFFFB4AB) : Colors.red.shade200),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cerrar diálogo primero
                await _logout(context); // Usar el context original de la página
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.eco,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              const Text('AuPlant'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Versión 1.0.0',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: UIConstants.spacingM),
              Text(
                'AuPlant es tu asistente inteligente para el cuidado de plantas. Monitorea, riega y mantén tus plantas saludables con tecnología IoT.',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }
}
