import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:laboratorio/data/models/navigation_model.dart';
import 'package:laboratorio/ui/screens/docente/history_docente.dart';
import 'package:laboratorio/ui/screens/docente/muestras_docente.dart';
import 'firebase_options.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'ui/screens/login/login_screen.dart';
import 'ui/screens/login/login_viewmodel.dart';
import 'data/repositories/auth_repository.dart';
import 'services/firebase_auth_service.dart';
import 'ui/screens/admin/home_screen.dart'; // Pantalla de administración
import 'ui/screens/docente/home_docente.dart'; // Nueva pantalla para docente

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Proveedor para el servicio de Firebase Auth
        Provider(create: (_) => FirebaseAuthService()),

        // ProxyProvider para crear el AuthRepository a partir de FirebaseAuthService
        ProxyProvider<FirebaseAuthService, AuthRepository>(
          update: (_, authService, __) => AuthRepository(authService),
        ),

        // ChangeNotifierProxyProvider para crear LoginViewModel a partir de AuthRepository
        ChangeNotifierProxyProvider<AuthRepository, LoginViewModel>(
          create: (context) => LoginViewModel(context.read<AuthRepository>()),
          update: (_, authRepository, previousViewModel) =>
              previousViewModel!..updateRepository(authRepository),
        ),

        // Proveedor para el modelo de navegación
        ChangeNotifierProvider(create: (_) => NavigationModel()),
      ],
      child: MaterialApp(
        title: 'Laboratorio de Ciencias Básicas',
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home-admin': (context) => const HomeAdminScreen(),
          '/home-docente': (context) => const HomeDocente(), // Ruta a la pantalla para docente
          '/history': (context) => const HistoryDocente(),
          '/muestras': (context) => const MuestrasDocente(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}