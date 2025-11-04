import 'package:flutter/material.dart';
import 'pages/comum/tela_selecao_perfil.dart'; // Import da nova tela

// --- PONTO DE ENTRADA DO APLICATIVO ---
void main() {
  runApp(const ClinicaApp()); // Nome do App atualizado
}

// --- WIDGET PRINCIPAL (ROOT) ---
class ClinicaApp extends StatelessWidget {
  const ClinicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão Clínica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 1,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
        ),

        // --- CORREÇÃO 1 AQUI ---
        // O Flutter espera um 'CardThemeData', e não 'CardTheme'.
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // --- CORREÇÃO 2 AQUI ---
      // Removemos o 'const' porque TelaSelecaoPerfil não é uma constante
      // (ela inicializa um repositório).
      home: TelaSelecaoPerfil(),
    );
  }
}
