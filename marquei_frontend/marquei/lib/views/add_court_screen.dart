import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCourtScreen extends StatefulWidget {
  final int estabelecimentoId;

  const AddCourtScreen({super.key, required this.estabelecimentoId});

  @override
  _AddCourtScreenState createState() => _AddCourtScreenState();
}

class _AddCourtScreenState extends State<AddCourtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courtNameController = TextEditingController();

  // Função para salvar a quadra
  Future<void> _saveCourt() async {
    if (_formKey.currentState!.validate()) {
      if (widget.estabelecimentoId != null) {
        final supabase = Supabase.instance.client;

        final data = {
          'nome': _courtNameController.text,
          'id_estabelecimento': widget.estabelecimentoId,
        };

        try {
          final response = await supabase.from('quadra').insert(data);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quadra adicionada com sucesso!')),
          );

          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao adicionar a quadra: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _courtNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Quadra'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _courtNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Quadra',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da quadra';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCourt,
                child: const Text('Salvar Quadra'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
