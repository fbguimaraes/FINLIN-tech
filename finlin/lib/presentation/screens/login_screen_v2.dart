import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/login_provider.dart';
import '../dialogs/registration_dialog.dart';

/// Tela de Login SIMPLES E CLARA
class LoginScreenV2 extends ConsumerStatefulWidget {
  const LoginScreenV2({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends ConsumerState<LoginScreenV2> {
  late TextEditingController _emailController;
  late TextEditingController _senhaController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _preencherDadosDeTeste() {
    _emailController.text = 'joao@example.com';
    _senhaController.text = 'senha123';
  }

  void _fazerLogin() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Email e senha são obrigatórios')),
      );
      return;
    }

    // Fazer login
    await ref.read(loginProvider.notifier).login(email, senha);
  }

  void _abrirRegistro() {
    showDialog(
      context: context,
      builder: (context) => RegistrationDialog(
        onRegistrationSuccess: () {
          // Limpar campos após sucesso
          _emailController.clear();
          _senhaController.clear();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final isLoading = loginState.isLoading;
    final error = loginState.error;
    final isAuthenticated = loginState.isAuthenticated;

    // Se autenticado, mostrar tela de sucesso
    if (isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              Text(
                'Login Bem-Sucedido!',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              Text(
                'Bem-vindo, ${loginState.usuario?.nome}!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  ref.read(loginProvider.notifier).logout();
                },
                child: const Text('Fazer Logout'),
              ),
            ],
          ),
        ),
      );
    }

    // Tela de login
    return Scaffold(
      appBar: AppBar(
        title: const Text('FINLIN - Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo/Título
              Text(
                'FINLIN',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Controle Financeiro Pessoal',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 50),

              // Campo Email
              TextField(
                controller: _emailController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'seu@email.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: error != null ? 'Erro: $error' : null,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Campo Senha
              TextField(
                controller: _senhaController,
                enabled: !isLoading,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Dados de Teste
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _preencherDadosDeTeste,
                  child: const Text('🧪 Preencher Dados de Teste'),
                ),
              ),
              const SizedBox(height: 12),

              // Botão Login
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _fazerLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 24),
              // Botão Criar Conta
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _abrirRegistro,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Criar Nova Conta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Mensagem de Erro (se houver)
              if (error != null && !isLoading)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Erro ao Fazer Login:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),

              // Caixa de informações
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '📚 Dados de Teste:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const SelectableText(
                      'Email: joao@example.com\nSenha: senha123',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
