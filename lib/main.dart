import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/dependency_injection.dart';
import 'app/app.dart';

/// Updated main.dart with dependency injection
/// 
/// This is the refactored version that initializes the new architecture.
/// Replace your current main.dart with this once you're ready to migrate.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await initializeDependencies();
  
  // Configure Supabase
  await Supabase.initialize(
    url: 'https://wkzkzjwzxsvkflxclbqu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indremt6and6eHN2a2ZseGNsYnF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5MzQ1OTgsImV4cCI6MjA2NzUxMDU5OH0.fQpLDNX31CStY_eCUIqabpr7sfm004At8JbZTf1o1k0',
  );
  
  runApp(const AuPlantRoot());
}

/// Root widget with authentication state management
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
        return const App();
      },
    );
  }
}
