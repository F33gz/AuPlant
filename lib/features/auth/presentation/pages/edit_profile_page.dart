import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/auth_repository.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  bool _loading = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authRepo = GetIt.instance<AuthRepository>();
    final result = await authRepo.getCurrentUser();
    if (result.isSuccess && result.dataOrNull != null && mounted) {
      setState(() {
        _userName = result.dataOrNull!.displayName;
        _nameCtrl.text = _userName ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // TODO: Implementar actualización de perfil en ThingsBoard
      // ThingsBoard no permite cambiar datos de usuario desde la app cliente
      // El cambio de contraseña requiere endpoint admin o flujo de reset
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidad no disponible aún'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop(false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Tu nombre'),
              ),
              const SizedBox(height: 16),
              Text('Nueva contraseña (opcional)', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: '••••••••'),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Confirmar contraseña', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordConfirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: '••••••••'),
                validator: (v) {
                  if (_passwordCtrl.text.isNotEmpty && v != _passwordCtrl.text) return 'No coincide';
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading ? const CircularProgressIndicator() : const Text('Guardar cambios'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
