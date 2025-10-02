import 'package:flutter/material.dart';
import '../../models/tarefa_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/app_repository.dart';

class TelaListaTarefasPaciente extends StatefulWidget {
  final Usuario paciente;
  const TelaListaTarefasPaciente({super.key, required this.paciente});

  @override
  State<TelaListaTarefasPaciente> createState() => _TelaListaTarefasPacienteState();
}

class _TelaListaTarefasPacienteState extends State<TelaListaTarefasPaciente> {
  final AppRepository _repository = AppRepository();
  late Future<List<Tarefa>> _futureTarefas;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  void _carregarTarefas() {
    setState(() {
      _futureTarefas = _repository.getTarefasPorPaciente(widget.paciente.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Tarefas - ${widget.paciente.nome}'),
      ),
      body: FutureBuilder<List<Tarefa>>(
        future: _futureTarefas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa designada.'));
          }
          final tarefas = snapshot.data!;
          return ListView.builder(
            itemCount: tarefas.length,
            itemBuilder: (context, index) {
              final tarefa = tarefas[index];
              return Card(
                child: ListTile(
                  title: Text(tarefa.titulo),
                  subtitle: Text(tarefa.descricao),
                  leading: Checkbox(
                    value: tarefa.concluida,
                    onChanged: (value) {
                      setState(() {
                        tarefa.concluida = value!;
                      });
                      // A lógica para salvar o estado do checkbox precisaria ser mais robusta
                      // em um app real, ligando a tarefa ao seu prontuário.
                      // Por simplicidade, isso é apenas uma mudança visual.
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}