import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:laboratorio/data/controllers/incidencias_controller.dart';
import 'package:laboratorio/data/models/navigation_model.dart';
import 'package:laboratorio/ui/screens/admin/incidencias_admin_screen.dart';
import 'package:laboratorio/ui/screens/admin/muestras_admin.dart';
import 'package:laboratorio/ui/screens/admin/solicitudes_admin.dart';
import 'package:laboratorio/ui/screens/docente/history_docente.dart';
import 'package:laboratorio/ui/screens/docente/home.dart';
import 'package:laboratorio/ui/screens/docente/muestras_docente.dart';
import 'package:laboratorio/ui/screens/superAdm/super_adm.dart';
import 'package:laboratorio/ui/screens/user/user_profile.dart';
import 'firebase_options.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'ui/screens/login/login_screen.dart';
import 'ui/screens/login/login_viewmodel.dart';
import 'data/repositories/auth_repository.dart';
import 'services/firebase_auth_service.dart';
import 'ui/screens/admin/home_screen.dart'; 
//import 'ui/screens/docente/home_docente.dart'; 

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
         ChangeNotifierProvider(create: (_) => IncidenciasController()),
        Provider(create: (_) => FirebaseAuthService()),

        ProxyProvider<FirebaseAuthService, AuthRepository>(
          update: (_, authService, __) => AuthRepository(authService),
        ),

        ChangeNotifierProxyProvider<AuthRepository, LoginViewModel>(
          create: (context) => LoginViewModel(context.read<AuthRepository>()),
          update: (_, authRepository, previousViewModel) =>
              previousViewModel!..updateRepository(authRepository),
        ),

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
          '/home-docente': (context) => const HomeDocente1(), // Ruta a la pantalla para docente
          '/history': (context) => const HistoryDocente(),
          '/muestras': (context) => const MuestrasDocente(),
          '/muestrasadm': (context) => const MuestrasAdminScreen(),
          '/super': (context) => const RegistroUsuarioScreen(),
          '/profile': (context) => const UserProfile(),
          '/solicitudes': (context) => const SolicitudesScreen(),
          '/incidencias': (context) => const IncidenciasAdminScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
