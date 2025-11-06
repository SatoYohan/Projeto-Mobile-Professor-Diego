import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../repositories/app_repository.dart';
import 'tela_detalhes_paciente.dart';

class TelaListaPacientes extends StatefulWidget {
  final Usuario medico;
  const TelaListaPacientes({super.key, required this.medico});

  @override
  State<TelaListaPacientes> createState() => _TelaListaPacientesState();
}

class _TelaListaPacientesState extends State<TelaListaPacientes> {
  final AppRepository _repository = AppRepository();
  late Future<List<Usuario>> _futurePacientes;

  @override
  void initState() {
    super.initState();
    _futurePacientes = _repository.getPacientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meus Pacientes - ${widget.medico.nome}')),
      body: FutureBuilder<List<Usuario>>(
        future: _futurePacientes,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final pacientes = snapshot.data!;
          return ListView.builder(
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(paciente.nome),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TelaDetalhesPaciente(paciente: paciente),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
