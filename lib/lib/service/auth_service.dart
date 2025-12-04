import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart'; // Importamos o novo serviço

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Agora o AuthService "conhece" o FirestoreService
  final FirestoreService _firestoreService = FirestoreService();

  // Stream para ouvir o estado de autenticação (logado ou não)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obter o usuário atual
  User? get currentUser => _auth.currentUser;

  // Método para Login
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Método para Criar Conta (AGORA ATUALIZADO)
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
    String nome, // Pedimos o nome
  ) async {
    // 1. Cria o usuário no Firebase Auth
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      // 2. Se a criação no Auth foi um sucesso,
      // cria o perfil dele no banco de dados Firestore
      await _firestoreService.createUserProfile(
        userCredential.user!.uid,
        email,
        nome,
      );
    }
    return userCredential;
  }

  // Método para Sair (Logout)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
