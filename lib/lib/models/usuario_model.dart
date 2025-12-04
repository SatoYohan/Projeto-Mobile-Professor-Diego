import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  String nome;
  final String email;
  String tipo;
  // --- CAMPOS DE ENDEREÇO ---
  String cep;
  String logradouro;
  String complemento;
  String bairro;
  String localidade;
  String uf;
  // --- CAMPO PARA A FOTO ---
  String fotoBase64;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    this.cep = '',
    this.logradouro = '',
    this.complemento = '',
    this.bairro = '',
    this.localidade = '',
    this.uf = '',
    this.fotoBase64 = '',
  });

  // --- Conversores Firestore ---

  factory Usuario.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Usuario(
      id: snapshot.id,
      nome: data?['nome'] ?? '',
      email: data?['email'] ?? '',
      tipo: data?['tipo'] ?? 'indefinido',
      cep: data?['cep'] ?? '',
      logradouro: data?['logradouro'] ?? '',
      complemento: data?['complemento'] ?? '',
      bairro: data?['bairro'] ?? '',
      localidade: data?['localidade'] ?? '',
      uf: data?['uf'] ?? '',
      fotoBase64: data?['fotoBase64'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'cep': cep,
      'logradouro': logradouro,
      'complemento': complemento,
      'bairro': bairro,
      'localidade': localidade,
      'uf': uf,
      'fotoBase64': fotoBase64,
    };
  }
}
