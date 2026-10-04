import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/tokens.dart';
import 'data/repository.dart';
import 'screens/splash_screen.dart';

/// App-wide theme mode (toggled from Settings).
final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await repo.restore();
  runApp(const MedFleetApp());
}

class MedFleetApp extends StatelessWidget {
  const MedFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (_, mode, __) => MaterialApp(
        title: 'مدفليت',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar', 'IQ'),
        supportedLocales: const [Locale('ar', 'IQ'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: mode,
        home: const SplashScreen(),
      ),
    );
  }
}
