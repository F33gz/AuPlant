import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuración de Supabase remoto
  await Supabase.initialize(
    url: 'https://wkzkzjwzxsvkflxclbqu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indremt6and6eHN2a2ZseGNsYnF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5MzQ1OTgsImV4cCI6MjA2NzUxMDU5OH0.fQpLDNX31CStY_eCUIqabpr7sfm004At8JbZTf1o1k0',
  );
  runApp(const AuPlantRoot());
}

/// Root widget que decide si mostrar login o la app principal según autenticación
class AuPlantRoot extends StatefulWidget {
  const AuPlantRoot({super.key});

  @override
  State<AuPlantRoot> createState() => _AuPlantRootState();
}

class _AuPlantRootState extends State<AuPlantRoot> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Siempre retorna App, que maneja rutas y navegación
        return const App();
      },
    );
  }
}