import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

import 'service_locator.dart';
import 'routes.dart';
import 'core/theme/theme_controller.dart';

final ValueNotifier<double> fontScaleNotifier = ValueNotifier<double>(1.0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Database? database;

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    database = await openDatabase(
      'aura_database.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE notificacoes (id TEXT PRIMARY KEY, titulo TEXT, mensagem TEXT, dataCriacao TEXT, lida INTEGER, usuarioId TEXT)');
      },
    );
  }

  ServiceLocator.instance.setupRepository(database: database);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = GetIt.I<ThemeController>();

    return ListenableBuilder(
      listenable: Listenable.merge([themeController, fontScaleNotifier]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Sistema Aura',
          debugShowCheckedModeBanner: false,
          themeMode: themeController.themeMode,
          theme: ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E), brightness: Brightness.dark),
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(fontScaleNotifier.value),
              ),
              child: child!,
            );
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR')],
          locale: const Locale('pt', 'BR'),
          initialRoute: AppRoutes.login,
          routes: AppRoutes.getRoutes(),
        );
      },
    );
  }
}