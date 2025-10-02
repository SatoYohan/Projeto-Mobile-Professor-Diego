import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Adicione a dependência 'intl' no seu pubspec.yaml
import '../../models/prontuario_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/app_repository.dart';

class TelaDetalhesPaciente extends StatefulWidget {
  final Usuario paciente;
  const TelaDetalhesPaciente({super.key, required this.paciente});

  @override
  State<TelaDetalhesPaciente> createState() => _TelaDetalhesPacienteState();
}

class _TelaDetalhesPacienteState extends State<TelaDetalhesPaciente> {
  final AppRepository _repository = AppRepository();
  late Future<List<Prontuario>> _futureProntuarios;

  @override
  void initState() {
    super.initState();
    _carregarProntuarios();
  }
  
  void _carregarProntuarios(){
      setState(() {
         _futureProntuarios = _repository.getProntuariosPorPaciente(widget.paciente.id);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prontuários de ${widget.paciente.nome}'),
      ),
      body: FutureBuilder<List<Prontuario>>(
        future: _futureProntuarios,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final prontuarios = snapshot.data!;
          if (prontuarios.isEmpty) {
            return const Center(child: Text('Nenhum prontuário encontrado.'));
          }
          return ListView.builder(
            itemCount: prontuarios.length,
            itemBuilder: (context, index) {
              final prontuario = prontuarios[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: const Icon(Icons.folder_copy),
                  title: Text('Consulta - ${DateFormat('dd/MM/yyyy').format(prontuario.dataConsulta)}'),
                  subtitle: Text('${prontuario.tarefas.length} tarefa(s) designada(s)'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notas do Médico:', style: Theme.of(context).textTheme.titleSmall),
                          Text(prontuario.notasMedico),
                          const Divider(height: 20),
                          Text('Tarefas para o Paciente:', style: Theme.of(context).textTheme.titleSmall),
                          // Lista as tarefas dentro do prontuário
                          for (var tarefa in prontuario.tarefas)
                            ListTile(
                              leading: Icon(tarefa.concluida ? Icons.check_box : Icons.check_box_outline_blank),
                              title: Text(tarefa.titulo),
                            )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para o formulário de novo prontuário (a ser criado)
        },
        child: const Icon(Icons.add),
        tooltip: 'Novo Prontuário',
      ),
    );
  }
}