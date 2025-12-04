import 'dart:io';
import 'dart:convert'; // Necessário para Base64
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/usuario_model.dart';
import '../../service/auth_service.dart';
import '../../service/firestore_service.dart';
import '../../service/api_service.dart';

class TelaEditarPerfil extends StatefulWidget {
  final Usuario usuario;
  const TelaEditarPerfil({super.key, required this.usuario});

  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nomeController;
  late String _tipoSelecionado;

  late TextEditingController _cepController;
  late TextEditingController _logradouroController;
  late TextEditingController _complementoController;
  late TextEditingController _bairroController;
  late TextEditingController _localidadeController;
  late TextEditingController _ufController;

  bool _loading = false;
  bool _buscandoCep = false;

  // Variáveis para a imagem
  File? _imagemSelecionada; // Imagem nova (da câmera)
  String? _imagemBase64Atual; // Imagem que veio do banco (string)

  @override
  void initState() {
    super.initState();
    // Preenche os dados básicos
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _tipoSelecionado = widget.usuario.tipo;

    // Preenche os dados de endereço vindos do Banco
    _cepController = TextEditingController(text: widget.usuario.cep);
    _logradouroController =
        TextEditingController(text: widget.usuario.logradouro);
    _complementoController =
        TextEditingController(text: widget.usuario.complemento);
    _bairroController = TextEditingController(text: widget.usuario.bairro);
    _localidadeController =
        TextEditingController(text: widget.usuario.localidade);
    _ufController = TextEditingController(text: widget.usuario.uf);

    // Carrega a imagem do banco, se existir
    if (widget.usuario.fotoBase64.isNotEmpty) {
      _imagemBase64Atual = widget.usuario.fotoBase64;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _localidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  // --- LÓGICA DA CÂMERA ---
  Future<void> _tirarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality:
            30, // Qualidade baixa para a string base64 não ficar gigante
        maxWidth: 600, // Limita o tamanho
      );

      if (foto != null) {
        setState(() {
          _imagemSelecionada = File(foto.path);
        });
      }
    } catch (e) {
      print('Erro ao tirar foto: $e');
    }
  }

  // --- LÓGICA DA API DE CEP ---
  Future<void> _buscarEnderecoPorCep() async {
    final cep = _cepController.text;
    if (cep.length != 8) return;

    setState(() {
      _buscandoCep = true;
      _logradouroController.text = 'Buscando...';
    });

    final endereco = await _apiService.buscarEnderecoPorCep(cep);

    if (mounted) {
      setState(() {
        _buscandoCep = false;
        if (endereco != null) {
          _logradouroController.text = endereco['logradouro'] ?? '';
          _complementoController.text = endereco['complemento'] ?? '';
          _bairroController.text = endereco['bairro'] ?? '';
          _localidadeController.text = endereco['localidade'] ?? '';
          _ufController.text = endereco['uf'] ?? '';

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Endereço encontrado!'),
                backgroundColor: Colors.blue),
          );
        } else {
          _logradouroController.text = '';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('CEP não encontrado.'),
                backgroundColor: Colors.orange),
          );
        }
      });
    }
  }

  Future<void> _salvarPerfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final bool tipoMudou = widget.usuario.tipo != _tipoSelecionado;
      String? novaFotoBase64;

      // Se o usuário tirou uma foto nova, converte para Base64
      if (_imagemSelecionada != null) {
        final bytes = await _imagemSelecionada!.readAsBytes();
        novaFotoBase64 = base64Encode(bytes);
      }

      await _firestoreService.updateUserProfile(
        widget.usuario.id,
        _nomeController.text.trim(),
        _tipoSelecionado,
        cep: _cepController.text.trim(),
        logradouro: _logradouroController.text.trim(),
        complemento: _complementoController.text.trim(),
        bairro: _bairroController.text.trim(),
        localidade: _localidadeController.text.trim(),
        uf: _ufController.text.trim(),
        fotoBase64: novaFotoBase64, // Passa a nova foto (se houver)
      );

      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Perfil salvo com sucesso!'),
              backgroundColor: Colors.green),
        );

        if (tipoMudou) {
          await _authService.signOut();
          if (mounted) Navigator.pop(context);
        } else {
          Navigator.of(context).pop();
        }
      }
    }
  }

  // Widget auxiliar para mostrar a imagem correta (Arquivo ou Base64 ou Ícone)
  ImageProvider? _getImagemPerfil() {
    if (_imagemSelecionada != null) {
      return FileImage(_imagemSelecionada!); // Foto nova da câmera
    } else if (_imagemBase64Atual != null && _imagemBase64Atual!.isNotEmpty) {
      return MemoryImage(
          base64Decode(_imagemBase64Atual!)); // Foto salva do banco
    }
    return null; // Nenhuma foto
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
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      // Usa a função auxiliar para decidir qual imagem mostrar
                      backgroundImage: _getImagemPerfil(),
                      child: (_imagemSelecionada == null &&
                              (_imagemBase64Atual == null ||
                                  _imagemBase64Atual!.isEmpty))
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                          onPressed: _tirarFoto,
                          tooltip: 'Tirar Foto',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Dados Básicos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'O nome é obrigatório.' : null,
              ),
              const SizedBox(height: 24),
              const Text('Tipo de Perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                  title: const Text('Médico'),
                  value: 'medico',
                  groupValue: _tipoSelecionado,
                  onChanged: (v) => setState(() => _tipoSelecionado = v!)),
              RadioListTile<String>(
                  title: const Text('Paciente'),
                  value: 'paciente',
                  groupValue: _tipoSelecionado,
                  onChanged: (v) => setState(() => _tipoSelecionado = v!)),
              const SizedBox(height: 24),
              const Text('Endereço (ViaCEP)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cepController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      decoration: const InputDecoration(
                          labelText: 'CEP',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          counterText: ''),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _buscandoCep ? null : _buscarEnderecoPorCep,
                      child: _buscandoCep
                          ? const CircularProgressIndicator()
                          : const Text('Buscar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _logradouroController,
                  decoration: const InputDecoration(
                      labelText: 'Rua', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(
                      labelText: 'Bairro', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          controller: _localidadeController,
                          decoration: const InputDecoration(
                              labelText: 'Cidade',
                              border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextFormField(
                          controller: _ufController,
                          decoration: const InputDecoration(
                              labelText: 'UF', border: OutlineInputBorder()))),
                ],
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
                          textStyle: const TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
