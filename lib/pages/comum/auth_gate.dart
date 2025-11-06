import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_mobile_professor_diego/models/usuario_model.dart'
    as app;
import 'package:projeto_mobile_professor_diego/pages/medico/tela_lista_pacientes.dart';
import 'package:projeto_mobile_professor_diego/pages/paciente/tela_lista_tarefas_paciente.dart';
import 'package:projeto_mobile_professor_diego/service/auth_service.dart';
import 'package:projeto_mobile_professor_diego/service/firestore_service.dart';
import 'tela_login.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        // Se o Auth está carregando, mostra um spinner
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário NÃO está logado
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const TelaLogin();
        }

        // Se o usuário ESTÁ logado, busca o perfil no Firestore
        User user = authSnapshot.data!;
        return FutureBuilder<app.Usuario?>(
          future: firestoreService.getUserProfile(user.uid),
          builder: (context, userSnapshot) {
            // Se o perfil do Firestore está carregando
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Se não encontrou o perfil (ou erro)
            if (!userSnapshot.hasData || userSnapshot.data == null) {
              // Isso não deve acontecer se o cadastro funcionar,
              // mas é uma segurança. Pode levar ao Login ou uma tela de erro.
              return const TelaLogin();
            }

            // --- LÓGICA SIMPLIFICADA (REQ 1) ---
            final usuario = userSnapshot.data!;

            // Não precisamos mais verificar por 'indefinido'
            if (usuario.tipo == 'medico') {
              return TelaListaPacientes(medico: usuario);
            }

            // Se não for médico, é paciente (pois o padrão agora é 'paciente')
            return TelaListaTarefasPaciente(paciente: usuario);
          },
        );
      },
    );
  }
}
