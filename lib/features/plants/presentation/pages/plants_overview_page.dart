import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/constants/ui_constants.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/plant.dart';
import '../../domain/usecases/get_plants_usecase.dart';

/// Plants Overview Page
/// 
/// The main page that displays all user plants in a list format.
/// Includes an app bar with navigation and add plant functionality.
class PlantsOverviewPage extends StatefulWidget {
  const PlantsOverviewPage({super.key});

  @override
  State<PlantsOverviewPage> createState() => _PlantsOverviewPageState();
}

class _PlantsOverviewPageState extends State<PlantsOverviewPage> {
  final GetPlantsUseCase _getPlantsUseCase = GetIt.instance<GetPlantsUseCase>();
  
  List<Plant> _plants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _getPlantsUseCase.call();
    
    switch (result) {
      case Success<List<Plant>> success:
        setState(() {
          _plants = success.data;
          _isLoading = false;
        });
        break;
      case Error<List<Plant>> error:
        setState(() {
          _error = error.failure.message;
          _isLoading = false;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Builds the app bar with title and actions
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      title: Text(
        'AuPlant',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        const SizedBox(width: UIConstants.spacingS),
      ],
    );
  }

  /// Builds the main body content
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.spacingM),
            ElevatedButton(
              onPressed: _loadPlants,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_plants.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPlants,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(UIConstants.paddingL),
        itemCount: _plants.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.spacingM),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingM,
                vertical: UIConstants.paddingS,
              ),
              child: ListTile(
                leading: Text(
                  _plants[index].emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                title: Text(
                  _plants[index].name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _plants[index].location ?? 'Sin ubicación',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                onTap: () => _navigateToPlantDetail(_plants[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the header section with description
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola! 👋',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: UIConstants.spacingS),
        Text(
          'Monitorea tus plantas y mantén tu jardín saludable',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: UIConstants.spacingL),
          Text(
            'No tienes plantas aún',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Añade tu primera planta para empezar a monitorear tu jardón',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingXL),
          ElevatedButton.icon(
            onPressed: _handleAddPlant,
            icon: const Icon(Icons.add),
            label: const Text('Añadir planta'),
          ),
        ],
      ),
    );
  }

  /// Builds the floating action button
  Widget _buildFloatingActionButton() {
    if (_plants.isEmpty) return const SizedBox.shrink();
    
    return FloatingActionButton(
      onPressed: _navigateToAddPlant,
      backgroundColor: AppColors.primaryGreen,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _navigateToPlantDetail(Plant plant) {
    Navigator.pushNamed(
      context,
      '/plant-detail',
      arguments: plant,
    );
  }

  void _navigateToAddPlant() {
    Navigator.pushNamed(context, '/add-plant').then((_) {
      _loadPlants(); // Reload plants after adding
    });
  }

  void _handleAddPlant() {
    Navigator.pushNamed(context, '/add-plant').then((_) {
      _loadPlants();
    });
  }
}
