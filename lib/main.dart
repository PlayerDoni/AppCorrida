import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geosprint/telas/tela_carregamento.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(const GeoSprintApp());
  });
}

class GeoSprintApp extends StatelessWidget {
  const GeoSprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoSprint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('pt', 'BR'),
      home: const TelaCarregamento(),
    );
  }
}
