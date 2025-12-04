import 'package:cloud_firestore/cloud_firestore.dart';
import 'tarefa_model.dart';

class Prontuario {
  final String id;
  final String pacienteId;
  final DateTime dataConsulta;
  final String notasMedico;
  final List<Tarefa> tarefas;

  Prontuario({
    required this.id,
    required this.pacienteId,
    required this.dataConsulta,
    required this.notasMedico,
    required this.tarefas,
  });

  // como sua imagem do Firestore provou.
  Map<String, dynamic> toFirestore() {
    return {
      'pacienteId': pacienteId,
      'dataConsulta': Timestamp.fromDate(dataConsulta),
      'notasMedico': notasMedico,
      'tarefas': tarefas.map((tarefa) => tarefa.toMap()).toList(),
    };
  }

  // --- O MÉTODO DE 'LEITURA' (fromFirestore) ---
  factory Prontuario.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    // 1. Pega os dados do documento.
    final data = snapshot.data();

    // 2. Se os dados não existirem, lança um erro (é melhor que quebrar).
    if (data == null) {
      throw FirebaseException(
        plugin: 'Firestore',
        message: 'Documento ${snapshot.id} não encontrado ou está vazio.',
      );
    }

    // 3. Lê o campo 'tarefas' de forma segura
    final tarefasFromDb =
        data['tarefas'] as List<dynamic>? ?? []; // Lista vazia se for nulo
    final listaTarefas = tarefasFromDb
        .map((map) => Tarefa.fromMap(map as Map<String, dynamic>))
        .toList();

    // 4. Lê o campo 'dataConsulta' de forma segura
    final timestamp = data['dataConsulta'] as Timestamp?;
    // Se o carimbo de data não existir, usa a data de hoje como fallback
    final dataConsulta = timestamp?.toDate() ?? DateTime.now();

    // 5. Retorna o objeto Prontuario construído
    return Prontuario(
      id: snapshot.id,
      pacienteId: data['pacienteId'] ?? '',
      dataConsulta: dataConsulta,
      notasMedico: data['notasMedico'] ?? '',
      tarefas: listaTarefas,
    );
  }
}
