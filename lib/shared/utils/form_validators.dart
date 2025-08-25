class FormValidators {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa ${fieldName ?? 'este campo'}';
    }
    return null;
  }

  static String? validatePlantName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa el nombre de la planta';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateDeviceId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa el ID del dispositivo';
    }
    // Basic device ID format validation
    if (value.trim().length < 3) {
      return 'El ID del dispositivo debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? validateAccessToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa el token de acceso';
    }
    if (value.trim().length < 10) {
      return 'El token de acceso parece ser muy corto';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'La ubicación debe tener al menos 2 caracteres';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 5) {
      return 'La descripción debe tener al menos 5 caracteres';
    }
    return null;
  }
}
