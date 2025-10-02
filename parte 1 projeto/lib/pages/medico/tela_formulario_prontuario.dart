import 'package.flutter/material.dart';
import 'dart:math';
import '../../models/prontuario_model.dart';
import '../../models/tarefa_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/app_repository.dart';

class TelaFormularioProntuario extends StatefulWidget {
  final Usuario paciente;
  const TelaFormularioProntuario({super.key, required this.paciente});

  @override
  State<TelaFormularioProntuario> createState() =>
      _TelaFormularioProntuarioState();
}

class _TelaFormularioProntuarioState extends State<TelaFormularioProntuario> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AppRepository();
  final _notasController = TextEditingController();
  final List<TextEditingController> _tarefaTituloControllers = [];
  final List<TextEditingController> _tarefaDescricaoControllers = [];

  @override
  void initState() {
    super.initState();
    // Adiciona a primeira tarefa em branco
    _adicionarCampoTarefa();
  }
  
  @override
  void dispose() {
    _notasController.dispose();
    for (var controller in _tarefaTituloControllers) {
      controller.dispose();
    }
    for (var controller in _tarefaDescricaoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _adicionarCampoTarefa() {
    setState(() {
      _tarefaTituloControllers.add(TextEditingController());
      _tarefaDescricaoControllers.add(TextEditingController());
    });
  }
  
  void _removerCampoTarefa(int index) {
    setState(() {
      _tarefaTituloControllers[index].dispose();
      _tarefaDescricaoControllers[index].dispose();
      _tarefaTituloControllers.removeAt(index);
      _tarefaDescricaoControllers.removeAt(index);
    });
  }

  void _submeterFormulario() async {
    if (_formKey.currentState!.validate()) {
      final List<Tarefa> novasTarefas = [];
      for(int i = 0; i < _tarefaTituloControllers.length; i++) {
        final titulo = _tarefaTituloControllers[i].text;
        final descricao = _tarefaDescricaoControllers[i].text;
        if(titulo.isNotEmpty) {
           novasTarefas.add(Tarefa(
             id: 't${Random().nextInt(1000)}', // ID aleatório
             titulo: titulo,
             descricao: descricao,
           ));
        }
      }

      final novoProntuario = Prontuario(
        id: 'pront${Random().nextInt(1000)}', // ID aleatório
        pacienteId: widget.paciente.id,
        dataConsulta: DateTime.now(),
        notasMedico: _notasController.text,
        tarefas: novasTarefas,
      );

      await _repository.salvarProntuario(novoProntuario);

      if (mounted) {
        Navigator.pop(context, true); // Retorna 'true' para indicar sucesso
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Prontuário para ${widget.paciente.nome}'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notas da Consulta',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas e observações do médico...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira as notas.' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Tarefas para o Paciente',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ..._buildListaDeTarefas(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _adicionarCampoTarefa,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Tarefa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 40)
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submeterFormulario,
                child: const Text('Salvar Prontuário'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildListaDeTarefas() {
    return List.generate(_tarefaTituloControllers.length, (index) {
       return Card(
         margin: const EdgeInsets.only(bottom: 16),
         child: Padding(
           padding: const EdgeInsets.all(8.0),
           child: Column(
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text('Tarefa ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold),),
                   if (_tarefaTituloControllers.length > 1)
                     IconButton(
                       icon: const Icon(Icons.delete_outline, color: Colors.red),
                       onPressed: () => _removerCampoTarefa(index),
                     )
                 ],
               ),
               TextFormField(
                 controller: _tarefaTituloControllers[index],
                 decoration: const InputDecoration(labelText: 'Título da Tarefa'),
                 // Opcional: Adicionar validação se o título for obrigatório
               ),
               TextFormField(
                 controller: _tarefaDescricaoControllers[index],
                 decoration: const InputDecoration(labelText: 'Descrição'),
               ),
             ],
           ),
         ),
       );
    });
  }
}