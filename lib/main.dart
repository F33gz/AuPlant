import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Para desarrollo local, cambia estas URLs
  await Supabase.initialize(
    url: 'http://127.0.0.1:54321', // URL local de Supabase
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0', // Anon key local
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