import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../service/auth_service.dart';
import '../../service/firestore_service.dart';

class TelaEditarPerfil extends StatefulWidget {
  final Usuario usuario;
  const TelaEditarPerfil({super.key, required this.usuario});

  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late String _tipoSelecionado;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Preenche os campos com os dados atuais do usuário
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _tipoSelecionado = widget.usuario.tipo;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvarPerfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      // Verifica se o tipo foi alterado
      final bool tipoMudou = widget.usuario.tipo != _tipoSelecionado;

      // 1. Salva os novos dados no Firestore
      await _firestoreService.updateUserProfile(
        widget.usuario.id,
        _nomeController.text.trim(),
        _tipoSelecionado,
      );

      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // 2. Se o tipo (Médico/Paciente) mudou, desloga o usuário.
        // Isso força o AuthGate a reavaliar a rota no próximo login.
        if (tipoMudou) {
          // Mostra um diálogo e depois desloga
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Tipo de Perfil Alterado'),
              content: const Text(
                'Você alterou seu tipo de perfil. Será necessário fazer login novamente.',
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
          // Desloga o usuário
          await _authService.signOut();
        } else {
          // Se o tipo não mudou, apenas volta para a tela anterior
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome é obrigatório.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Tipo de Perfil',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              // Radio buttons para selecionar o tipo
              RadioListTile<String>(
                title: const Text('Médico'),
                value: 'medico',
                groupValue: _tipoSelecionado,
                onChanged: (value) {
                  setState(() => _tipoSelecionado = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Paciente'),
                value: 'paciente',
                groupValue: _tipoSelecionado,
                onChanged: (value) {
                  setState(() => _tipoSelecionado = value!);
                },
              ),
              const SizedBox(height: 32),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar Alterações'),
                      onPressed: _salvarPerfil,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
