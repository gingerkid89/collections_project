import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/visits_provider.dart';
import 'providers/user_provider.dart';
import 'l10n/app_localizations.dart';


void main() {
  runApp(const MyApp());
}

class AppInitializer extends StatefulWidget {
  final Widget child;
  
  const AppInitializer({super.key, required this.child});
  
  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    // Schedule initialization for the next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }
  
  Future<void> _initializeApp() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.tryAutoLogin();
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return widget.child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => VisitsProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Collection App',

            // Internationalization Setup
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleProvider.supportedLocales,
            locale: localeProvider.locale, // ← Das ist wichtig!

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),

            home: const AppInitializer(child: HomeScreen()),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}