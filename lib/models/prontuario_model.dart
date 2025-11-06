import 'tarefa_model.dart';

class Prontuario {
  final String id;
  final String pacienteId;
  final DateTime dataConsulta;
  final String notasMedico; // Anotações visíveis apenas para o médico
  final List<Tarefa> tarefas; // Tarefas para o paciente

  Prontuario({
    required this.id,
    required this.pacienteId,
    required this.dataConsulta,
    required this.notasMedico,
    required this.tarefas,
  });
}
