import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../shared/widgets/buttons/action_buttons.dart';
import '../../../../shared/widgets/qr_scanner_page.dart';
import '../widgets/station_emoji_selector.dart';
import '../../domain/entities/station.dart';
import '../../domain/usecases/add_station_usecase.dart';

/// Add Station Page
/// 
/// Form to add a new greenhouse monitoring station
class AddStationPage extends StatefulWidget {
  const AddStationPage({super.key});

  @override
  State<AddStationPage> createState() => _AddStationPageState();
}

class _AddStationPageState extends State<AddStationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AddStationUseCase _addStationUseCase = GetIt.instance<AddStationUseCase>();
  
  String _selectedEmoji = '🌡️';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _deviceIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textOnDark : AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Agregar Nueva Estación',
        style: TextStyle(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStationNameField(),
            const SizedBox(height: 24),
            _buildEmojiSelector(),
            const SizedBox(height: 24),
            _buildLocationField(),
            const SizedBox(height: 24),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            _buildDeviceField(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStationNameField() {
    return CustomTextField(
      controller: _nameController,
      label: 'Nombre de la estación',
      hintText: 'Ej: Estación Norte, Sector A',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el nombre de la estación';
        }
        return null;
      },
    );
  }

  Widget _buildEmojiSelector() {
    return StationEmojiSelector(
      selectedEmoji: _selectedEmoji,
      onEmojiSelected: (emoji) {
        setState(() {
          _selectedEmoji = emoji;
        });
      },
    );
  }

  Widget _buildLocationField() {
    return CustomTextField(
      controller: _locationController,
      label: 'Ubicación',
      hintText: 'Ej: Invernadero 1, Zona Norte',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa una ubicación';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return CustomTextField(
      controller: _descriptionController,
      label: 'Descripción (opcional)',
      hintText: 'Ej: Monitorea tomates y pimientos',
      maxLines: 2,
    );
  }

  Widget _buildDeviceField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomTextField(
      controller: _deviceIdController,
      label: 'Dispositivo IoT',
      hintText: 'Ingresa el ID del dispositivo o escanea el código QR',
      suffixIcon: IconButton(
        icon: Icon(Icons.qr_code_scanner, color: isDark ? AppColors.textMutedOnDark : AppColors.textSecondary),
        onPressed: () async {
          final scanned = await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (_) => const QrScannerPage()),
          );
          if (scanned != null && scanned.isNotEmpty) {
            _deviceIdController.text = scanned.trim();
          }
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el ID del dispositivo';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: 'Cancelar',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            text: 'Agregar Estación',
            isLoading: _isLoading,
            onPressed: _saveStation,
          ),
        ),
      ],
    );
  }
  
  Future<void> _saveStation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _addStationUseCase.call(
      name: _nameController.text.trim(),
      deviceId: _deviceIdController.text.trim(),
      emoji: _selectedEmoji,
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
    );
    
    switch (result) {
      case Success<Station> success:
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.of(context).pop(success.data);
        }
        break;
      case Error<Station> error:
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        break;
    }
  }
}
