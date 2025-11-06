import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart' as app;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Referência para a coleção 'usuarios'
  late final CollectionReference<app.Usuario> _usuariosRef;

  FirestoreService() {
    // Inicializa a referência com o conversor
    _usuariosRef = _db
        .collection('usuarios')
        .withConverter(
          fromFirestore: app.Usuario.fromFirestore,
          toFirestore: (app.Usuario usuario, _) => usuario.toFirestore(),
        );
  }

  // --- MÉTODOS DE USUÁRIO ---

  /// Cria um novo documento de usuário no Firestore
  /// Chamado logo após o usuário criar uma conta no Auth
  Future<void> createUserProfile(String uid, String email, String nome) async {
    try {
      // Cria um usuário com tipo 'indefinido' por enquanto
      final novoUsuario = app.Usuario(
        id: uid,
        nome: nome,
        email: email,
        tipo: 'indefinido', // O usuário vai escolher o tipo na tela de seleção
      );
      // Salva o documento no Firestore usando o UID do Auth como ID
      await _usuariosRef.doc(uid).set(novoUsuario);
    } catch (e) {
      print('Erro ao criar perfil de usuário: $e');
      // Tratar erro (ex: mostrar snackbar)
    }
  }

  /// Busca um perfil de usuário do Firestore
  Future<app.Usuario?> getUserProfile(String uid) async {
    try {
      final docSnap = await _usuariosRef.doc(uid).get();
      return docSnap.data(); // Retorna o objeto Usuario ou null
    } catch (e) {
      print('Erro ao buscar perfil de usuário: $e');
      return null;
    }
  }

  /// Atualiza o 'tipo' (medico/paciente) do usuário
  Future<void> setUserProfileType(String uid, String tipo) async {
    try {
      await _usuariosRef.doc(uid).update({'tipo': tipo});
    } catch (e) {
      print('Erro ao definir tipo de perfil: $e');
      // Tratar erro
    }
  }

  // --- (Em breve) MÉTODOS DE PRONTUÁRIO/TAREFA ---
  // (Aqui entrará a lógica de getProntuarios, getPacientes, etc.,
  // substituindo o app_repository.dart)
}
