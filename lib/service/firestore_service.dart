import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart'
    as app; // Usamos 'as app' para evitar conflito de nomes
import '../models/prontuario_model.dart';
import '../models/tarefa_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Referência para a coleção 'usuarios'
  late final CollectionReference<app.Usuario> _usuariosRef;

  // Referência para a coleção 'prontuarios', usando o conversor
  late final CollectionReference<Prontuario> _prontuariosRef;

  FirestoreService() {
    // Inicializa a referência de USUÁRIOS
    _usuariosRef = _db
        .collection('usuarios')
        .withConverter<app.Usuario>(
          fromFirestore: app.Usuario.fromFirestore,
          toFirestore: (app.Usuario usuario, _) => usuario.toFirestore(),
        );

    // Inicializa a referência de PRONTUÁRIOS
    _prontuariosRef = _db
        .collection('prontuarios')
        .withConverter<Prontuario>(
          fromFirestore: Prontuario.fromFirestore,
          toFirestore: (Prontuario prontuario, _) => prontuario.toFirestore(),
        );
  }

  // --- MÉTODOS DE USUÁRIO ---
  // (Estes métodos já estavam corretos)

  Future<void> createUserProfile(String uid, String email, String nome) async {
    try {
      final novoUsuario = app.Usuario(
        id: uid,
        nome: nome,
        email: email,
        tipo: 'paciente',
      );
      await _usuariosRef.doc(uid).set(novoUsuario);
    } catch (e) {
      print('Erro ao criar perfil de usuário: $e');
    }
  }

  Future<app.Usuario?> getUserProfile(String uid) async {
    try {
      final docSnap = await _usuariosRef.doc(uid).get();
      return docSnap.data();
    } catch (e) {
      print('Erro ao buscar perfil de usuário: $e');
      return null;
    }
  }

  Future<void> setUserProfileType(String uid, String tipo) async {
    try {
      await _usuariosRef.doc(uid).update({'tipo': tipo});
    } catch (e) {
      print('Erro ao definir tipo de perfil: $e');
    }
  }

  Future<void> updateUserProfile(String uid, String nome, String tipo) async {
    try {
      await _usuariosRef.doc(uid).update({'nome': nome, 'tipo': tipo});
    } catch (e) {
      print('Erro ao atualizar perfil do usuário: $e');
    }
  }

  Future<List<app.Usuario>> getTodosPacientes() async {
    try {
      final querySnapshot = await _usuariosRef
          .where('tipo', isEqualTo: 'paciente')
          .get();
      return querySnapshot.docs.map((doc) => doc.data()!).toList();
    } catch (e) {
      print('Erro ao buscar todos os pacientes: $e');
      return [];
    }
  }

  // --- MÉTODOS DE PRONTUÁRIO/TAREFA ---

  /// (READ) Busca um 'stream' de prontuários para um paciente específico
  Stream<List<Prontuario>> getProntuariosStream(String pacienteId) {
    // 1. Cria a consulta ao Firestore SEM o 'orderBy'
    return _prontuariosRef
        .where('pacienteId', isEqualTo: pacienteId)
        // .orderBy('dataConsulta', descending: true) // <-- ESTA LINHA CAUSAVA O ERRO
        .snapshots() // "Tira uma foto" toda vez que os dados mudam
        .map((snapshot) {
          // 2. Converte os documentos em uma lista de objetos Prontuario
          final lista = snapshot.docs.map((doc) => doc.data()).toList();

          // 3. AGORA nós ordenamos a lista, usando o Dart (não o Firebase)
          // b.compareTo(a) = ordem descendente (mais novos primeiro)
          lista.sort((a, b) => b.dataConsulta.compareTo(a.dataConsulta));

          // 4. Retorna a lista ordenada
          return lista;
        });
  }

  /// (CREATE) Salva um novo prontuário no banco de dados
  Future<void> salvarProntuario(Prontuario prontuario) async {
    try {
      await _prontuariosRef.add(prontuario);
    } catch (e) {
      print('Erro ao salvar prontuário: $e');
    }
  }

  /// (DELETE) Deleta um prontuário do banco de dados
  Future<void> deletarProntuario(String prontuarioId) async {
    try {
      await _prontuariosRef.doc(prontuarioId).delete();
    } catch (e) {
      print('Erro ao deletar prontuário: $e');
    }
  }

  /// (UPDATE) Atualiza o status 'concluida' de uma tarefa específica
  Future<void> atualizarStatusTarefa(
    String prontuarioId,
    String tarefaId,
    bool concluida,
  ) async {
    try {
      final docRef = _prontuariosRef.doc(prontuarioId);
      final docSnap = await docRef.get();
      final prontuario = docSnap.data();

      if (prontuario == null) return;

      final tarefaParaAtualizar = prontuario.tarefas.firstWhere(
        (t) => t.id == tarefaId,
      );

      tarefaParaAtualizar.concluida = concluida;

      final novaListaDeTarefasMap = prontuario.tarefas
          .map((t) => t.toMap())
          .toList();

      await docRef.update({'tarefas': novaListaDeTarefasMap});
    } catch (e) {
      print('Erro ao atualizar status da tarefa: $e');
    }
  }
}
