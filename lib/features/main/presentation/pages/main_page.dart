import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../plants/presentation/pages/plants_overview_page.dart';
import '../../../monitoring/presentation/pages/monitoring_dashboard_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';

/// Main Page with Bottom Navigation
/// 
/// The main entry point of the application featuring bottom navigation
/// to switch between different sections: Plants, Monitoring, and Profile.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // List of pages for each tab
  final List<Widget> _pages = [
    const PlantsOverviewPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingL,
              vertical: UIConstants.paddingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.eco,
                  label: 'Plantas',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Perfil',
                  index: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingL,
          vertical: UIConstants.paddingM,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? AppColors.primaryGreen 
                  : AppColors.textSecondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: UIConstants.spacingS),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Profile Page
/// 
/// User profile page with settings and account management.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.paddingL),
          child: Column(
            children: [
              const SizedBox(height: UIConstants.spacingXL),
              _buildProfileHeader(),
              const SizedBox(height: UIConstants.spacingXXL),
              _buildMenuSection(),
              const SizedBox(height: UIConstants.spacingXXL),
              _buildAccountSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primaryGreen,
          child: Icon(
            Icons.person,
            size: 60,
            color: AppColors.backgroundWhite,
          ),
        ),
        const SizedBox(height: UIConstants.spacingL),
        Text(
          'Usuario AuPlant',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: UIConstants.spacingS),
        Text(
          'usuario@auplant.com',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: UIConstants.spacingL),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Configurar alertas y notificaciones',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Configuración de la App',
            subtitle: 'Personalizar la aplicación',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.devices,
            title: 'Mis Dispositivos',
            subtitle: 'Gestionar sensores IoT',
            onTap: () {},
          ),
        ]),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuenta',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: UIConstants.spacingL),
        _buildMenuCard([
          _buildMenuItem(
            icon: Icons.person,
            title: 'Editar Perfil',
            subtitle: 'Cambiar información personal',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.security,
            title: 'Seguridad',
            subtitle: 'Cambiar contraseña',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.help,
            title: 'Ayuda y Soporte',
            subtitle: 'Obtener ayuda',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            subtitle: 'Salir de la aplicación',
            onTap: () {},
            isDestructive: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primaryGreen,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
