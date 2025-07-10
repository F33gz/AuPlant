import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../plants/presentation/pages/plants_overview_page.dart';
import '../../../monitoring/presentation/pages/monitoring_dashboard_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../../core/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
/// User profile page with only a logout button.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _userModel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final data = await supabase
        .from('users')
        .select('id, email, subscribed')
        .eq('id', user.id)
        .single();
    setState(() {
      _userModel = UserModel.fromJson(data);
      _loading = false;
    });
  }

  void _logout(BuildContext context) {
    Supabase.instance.client.auth.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Icono de usuario grande con fondo suave
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, size: 60, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 28),
                  // Email
                  if (_userModel != null)
                    Text(
                      _userModel!.email,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),
                  // Estado de suscripción como badge
                  if (_userModel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: _userModel!.subscribed ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _userModel!.subscribed ? Icons.verified : Icons.cancel,
                            color: _userModel!.subscribed ? Colors.green : Colors.red,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _userModel!.subscribed ? 'Suscripción Activa' : 'Suscripción Inactiva',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: _userModel!.subscribed ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Botón de suscribirse
                  if (_userModel != null && !_userModel!.subscribed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _subscribeUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Suscribirse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
                  if (_userModel != null && !_userModel!.subscribed)
                    const SizedBox(height: 20),
                  // Botón de cancelar suscripción
                  if (_userModel != null && _userModel!.subscribed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _unsubscribeUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Cancelar suscripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
                  if (_userModel != null && _userModel!.subscribed)
                    const SizedBox(height: 20),
                  // Botón de cerrar sesión
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _logout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
      ),
    );
  }

  Future<void> _subscribeUser() async {
    if (_userModel == null) return;
    final supabase = Supabase.instance.client;
    await supabase.from('users').update({'subscribed': true}).eq('id', _userModel!.id);
    setState(() {
      _userModel = UserModel(
        id: _userModel!.id,
        email: _userModel!.email,
        subscribed: true,
      );
    });
  }

  Future<void> _unsubscribeUser() async {
    if (_userModel == null) return;
    final supabase = Supabase.instance.client;
    await supabase.from('users').update({'subscribed': false}).eq('id', _userModel!.id);
    setState(() {
      _userModel = UserModel(
        id: _userModel!.id,
        email: _userModel!.email,
        subscribed: false,
      );
    });
  }
}
