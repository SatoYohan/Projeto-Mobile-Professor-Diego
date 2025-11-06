import 'package:cloud_firestore/cloud_firestore.dart';

// O 'enum' antigo não é mais usado, pois o Firestore lida melhor com Strings
// enum TipoUsuario { medico, paciente }

class Usuario {
  final String id;
  String nome;
  final String email;
  String tipo; // Agora é uma String: "medico", "paciente" ou "indefinido"

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
  });

  // --- Conversores Firestore ---

  /// Converte um Documento do Firestore (um 'Map') para um objeto Usuario
  factory Usuario.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Usuario(
      id: snapshot.id, // Pega o ID do documento
      nome: data?['nome'] ?? '',
      email: data?['email'] ?? '',
      tipo: data?['tipo'] ?? 'indefinido',
    );
  }

  /// Converte um objeto Usuario para um 'Map' que o Firestore entende
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'email': email,
      'tipo': tipo,
      // O ID não é salvo dentro do documento, ele é o nome do documento
    };
  }
}
