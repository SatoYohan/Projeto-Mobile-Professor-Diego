import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_mobile_professor_diego/models/usuario_model.dart'
    as app;
import 'package:projeto_mobile_professor_diego/pages/medico/tela_lista_pacientes.dart';
import 'package:projeto_mobile_professor_diego/pages/paciente/tela_lista_tarefas_paciente.dart';
import '../../service/firestore_service.dart';
import 'tela_login.dart';
import 'tela_selecao_perfil.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Se está verificando o Auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 1. Se NÃO tem usuário no Auth (não logado)
        if (!authSnapshot.hasData) {
          return const TelaLogin();
        }

        // 2. Se TEM usuário no Auth (logado)
        // Agora, precisamos verificar o perfil dele no Firestore
        final user = authSnapshot.data!;

        return FutureBuilder<app.Usuario?>(
          // Busca o perfil no Firestore
          future: firestoreService.getUserProfile(user.uid),
          builder: (context, profileSnapshot) {
            // Se está buscando o perfil
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Se deu erro ao buscar o perfil (improvável, mas bom verificar)
            if (profileSnapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Erro ao carregar perfil.')),
              );
            }

            final usuario = profileSnapshot.data;

            // 3. Se o perfil NÃO existe ou o tipo é 'indefinido'
            // (Primeiro login do usuário)
            if (usuario == null || usuario.tipo == 'indefinido') {
              // Manda para a tela de seleção de perfil
              // Passamos o usuário (com ID, email, nome) para a tela
              return TelaSelecaoPerfil(
                // Criamos um usuário local para passar o ID, Nome e Email
                // mesmo que o 'tipo' ainda não esteja definido.
                usuario: app.Usuario(
                  id: user.uid,
                  nome: user.displayName ?? '', // Tenta pegar o nome
                  email: user.email ?? '',
                  tipo: 'indefinido',
                ),
              );
            }

            // 4. Se o perfil EXISTE e tem um tipo definido
            if (usuario.tipo == 'medico') {
              return TelaListaPacientes(medico: usuario);
            } else if (usuario.tipo == 'paciente') {
              return TelaListaTarefasPaciente(paciente: usuario);
            }

            // Fallback (nunca deve acontecer)
            return const TelaLogin();
          },
        );
      },
    );
  }
}
