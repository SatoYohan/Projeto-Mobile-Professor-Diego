import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/prontuario_model.dart';
import '../../models/usuario_model.dart';
import '../../service/firestore_service.dart';
import 'tela_formulario_prontuario.dart';

class TelaDetalhesPaciente extends StatefulWidget {
  final Usuario paciente;
  const TelaDetalhesPaciente({super.key, required this.paciente});

  @override
  State<TelaDetalhesPaciente> createState() => _TelaDetalhesPacienteState();
}

class _TelaDetalhesPacienteState extends State<TelaDetalhesPaciente> {
  // Trocamos o repositório falso pelo serviço real do Firestore
  final FirestoreService _firestoreService = FirestoreService();
  // Não precisamos mais de _futureProntuarios ou _carregarProntuarios

  void _navegarParaFormulario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TelaFormularioProntuario(paciente: widget.paciente),
      ),
    );
  }

  // --- MÉTODO PARA DELETAR ---
  void _deletarProntuario(String prontuarioId) async {
    // Confirmação
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja deletar este prontuário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmou ?? false) {
      await _firestoreService.deletarProntuario(prontuarioId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prontuários de ${widget.paciente.nome}')),
      // --- FutureBuilder -> StreamBuilder ---
      body: StreamBuilder<List<Prontuario>>(
        // O Stream "escuta" o Firestore em tempo real
        stream: _firestoreService.getProntuariosStream(widget.paciente.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar prontuários.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum prontuário encontrado.'));
          }

          final prontuarios = snapshot.data!;

          return ListView.builder(
            itemCount: prontuarios.length,
            itemBuilder: (context, index) {
              final prontuario = prontuarios[index];

              // --- (D)ELETE ---
              // Permite arrastar o card para deletar
              return Dismissible(
                key: Key(prontuario.id), // Chave única para cada item
                direction: DismissDirection.endToStart, // Arrastar da direita
                onDismissed: (direction) {
                  _deletarProntuario(prontuario.id);
                  // Mostra um feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Prontuário deletado'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                // Fundo vermelho que aparece ao arrastar
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                // O Card do prontuário
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    leading: const Icon(Icons.folder_copy),
                    title: Text(
                      'Consulta - ${DateFormat('dd/MM/yyyy').format(prontuario.dataConsulta)}',
                    ),
                    subtitle: Text(
                      '${prontuario.tarefas.length} tarefa(s) designada(s)',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notas do Médico:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(prontuario.notasMedico),
                            const Divider(height: 20),
                            Text(
                              'Tarefas para o Paciente:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (prontuario.tarefas.isEmpty)
                              const Text('Nenhuma tarefa designada.'),
                            // Lista as tarefas
                            for (var tarefa in prontuario.tarefas)
                              ListTile(
                                leading: Icon(
                                  tarefa.concluida
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                ),
                                title: Text(tarefa.titulo),
                                subtitle: Text(tarefa.descricao),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarParaFormulario,
        child: const Icon(Icons.add),
        tooltip: 'Novo Prontuário',
      ),
    );
  }
}
