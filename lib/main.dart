import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import do Firebase
import 'pages/comum/auth_gate.dart'; // Import do nosso "Portão"
// import 'pages/comum/tela_selecao_perfil.dart'; // Não precisamos mais disso aqui

// --- PONTO DE ENTRADA DO APLICATIVO ---
void main() async {
  // 'main' agora é assíncrona
  // Garante que o Flutter esteja inicializado
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase
  await Firebase.initializeApp();

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

        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Ele vai decidir se mostra o Login ou a Tela de Seleção
      home: const AuthGate(),
    );
  }
}
