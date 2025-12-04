import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart' as app;
import '../models/prontuario_model.dart';
import '../models/tarefa_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final CollectionReference<app.Usuario> _usuariosRef;
  late final CollectionReference<Prontuario> _prontuariosRef;

  FirestoreService() {
    _usuariosRef = _db.collection('usuarios').withConverter<app.Usuario>(
          fromFirestore: app.Usuario.fromFirestore,
          toFirestore: (app.Usuario usuario, _) => usuario.toFirestore(),
        );

    _prontuariosRef = _db.collection('prontuarios').withConverter<Prontuario>(
          fromFirestore: Prontuario.fromFirestore,
          toFirestore: (Prontuario prontuario, _) => prontuario.toFirestore(),
        );
  }

  // --- MÉTODOS DE USUÁRIO ---

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

  Future<void> updateUserProfile(
    String uid,
    String nome,
    String tipo, {
    required String cep,
    required String logradouro,
    required String complemento,
    required String bairro,
    required String localidade,
    required String uf,
    String? fotoBase64,
  }) async {
    try {
      final dataToUpdate = {
        'nome': nome,
        'tipo': tipo,
        'cep': cep,
        'logradouro': logradouro,
        'complemento': complemento,
        'bairro': bairro,
        'localidade': localidade,
        'uf': uf,
      };

      // Só adiciona a foto ao update se ela foi alterada (não é nula)
      if (fotoBase64 != null) {
        dataToUpdate['fotoBase64'] = fotoBase64;
      }

      await _usuariosRef.doc(uid).update(dataToUpdate);
    } catch (e) {
      print('Erro ao atualizar perfil do usuário: $e');
    }
  }

  // --- MÉTODOS DE PRONTUÁRIO ---
  Future<List<app.Usuario>> getTodosPacientes() async {
    try {
      final querySnapshot =
          await _usuariosRef.where('tipo', isEqualTo: 'paciente').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erro ao buscar todos os pacientes: $e');
      return [];
    }
  }

  Stream<List<Prontuario>> getProntuariosStream(String pacienteId) {
    return _prontuariosRef
        .where('pacienteId', isEqualTo: pacienteId)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) => doc.data()).toList();
      lista.sort((a, b) => b.dataConsulta.compareTo(a.dataConsulta));
      return lista;
    });
  }

  Future<void> salvarProntuario(Prontuario prontuario) async {
    try {
      await _prontuariosRef.add(prontuario);
    } catch (e) {
      print('Erro ao salvar prontuário: $e');
    }
  }

  Future<void> deletarProntuario(String prontuarioId) async {
    try {
      await _prontuariosRef.doc(prontuarioId).delete();
    } catch (e) {
      print('Erro ao deletar prontuário: $e');
    }
  }

  Future<void> atualizarStatusTarefa(
      String prontuarioId, String tarefaId, bool concluida) async {
    try {
      final docRef = _prontuariosRef.doc(prontuarioId);
      final docSnap = await docRef.get();
      final prontuario = docSnap.data();
      if (prontuario == null) return;

      final tarefaParaAtualizar =
          prontuario.tarefas.firstWhere((t) => t.id == tarefaId);
      tarefaParaAtualizar.concluida = concluida;

      final novaListaDeTarefasMap =
          prontuario.tarefas.map((t) => t.toMap()).toList();
      await docRef.update({'tarefas': novaListaDeTarefasMap});
    } catch (e) {
      print('Erro ao atualizar status da tarefa: $e');
    }
  }
}
