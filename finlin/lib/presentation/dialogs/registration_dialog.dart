import 'package:flutter/material.dart';
import '../../data/datasources/api_client_v2.dart';

/// Dialog para registrar novo usuário
class RegistrationDialog extends StatefulWidget {
  final VoidCallback onRegistrationSuccess;

  const RegistrationDialog({
    Key? key,
    required this.onRegistrationSuccess,
  }) : super(key: key);

  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog> {
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController senhaController;
  late TextEditingController confirmaSenhaController;
  
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController();
    emailController = TextEditingController();
    senhaController = TextEditingController();
    confirmaSenhaController = TextEditingController();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmaSenhaController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (nomeController.text.isEmpty) {
      setState(() => errorMessage = 'Nome é obrigatório');
      return false;
    }
    if (emailController.text.isEmpty) {
      setState(() => errorMessage = 'Email é obrigatório');
      return false;
    }
    if (!emailController.text.contains('@')) {
      setState(() => errorMessage = 'Email inválido');
      return false;
    }
    if (senhaController.text.isEmpty) {
      setState(() => errorMessage = 'Senha é obrigatória');
      return false;
    }
    if (senhaController.text.length < 6) {
      setState(() => errorMessage = 'Senha deve ter pelo menos 6 caracteres');
      return false;
    }
    if (senhaController.text != confirmaSenhaController.text) {
      setState(() => errorMessage = 'Senhas não coincidem');
      return false;
    }
    return true;
  }

  Future<void> _register() async {
    if (!_validateForm()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiClient = ApiClientV2();
      await apiClient.createUsuario(
        email: emailController.text.trim(),
        senha: senhaController.text,
        nome: nomeController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário criado com sucesso! Faça login com seus dados.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
        widget.onRegistrationSuccess();
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Conta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !isLoading,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !isLoading,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: senhaController,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !isLoading,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmaSenhaController,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabled: !isLoading,
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text('Registrar'),
        ),
      ],
    );
  }
}
