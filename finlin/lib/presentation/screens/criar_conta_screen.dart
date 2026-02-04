import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../providers/login_provider.dart';
import '../../data/datasources/api_client_v2.dart';

/// Tela para criar uma nova conta
class CriarContaScreen extends ConsumerStatefulWidget {
  const CriarContaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CriarContaScreen> createState() => _CriarContaScreenState();
}

class _CriarContaScreenState extends ConsumerState<CriarContaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _saldoController;
  String _tipoSelecionado = 'corrente';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _tiposConta = [
    'corrente',
    'poupanca',
    'investimento',
    'digital',
    'carteira',
  ];

  final Map<String, String> _tiposDescricao = {
    'corrente': '🏦 Conta Corrente',
    'poupanca': '💰 Poupança',
    'investimento': '📈 Investimento',
    'digital': '📱 Carteira Digital',
    'carteira': '👛 Carteira Física',
  };

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _saldoController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ApiClientV2();
      
      // Verifica autenticação
      if (!apiClient.isAuthenticated) {
        throw Exception('Não autenticado. Faça login novamente.');
      }

      // Converte o saldo para double
      final saldo = double.parse(
        _saldoController.text.replaceAll('R\$ ', '').replaceAll(',', '.'),
      );

      // Chama o endpoint para criar conta
      await apiClient.createConta(
        _nomeController.text.trim(),
        saldo,
        _tipoSelecionado,
      );

      if (mounted) {
        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Conta "${_nomeController.text}" criada com sucesso!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Aguarda 2 segundos e volta para a tela anterior
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      }
    } catch (e) {
      print('❌ Erro ao criar conta: $e');
      setState(() {
        _errorMessage = _tratarErro(e.toString());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _tratarErro(String erro) {
    if (erro.contains('Já existe uma conta')) {
      return 'Já existe uma conta com este nome!';
    } else if (erro.contains('Tipo inválido')) {
      return 'Tipo de conta inválido!';
    } else if (erro.contains('Token')) {
      return 'Sessão expirada. Faça login novamente.';
    } else if (erro.contains('conexão')) {
      return 'Erro de conexão com o servidor. Verifique sua internet.';
    }
    return 'Erro ao criar conta: $erro';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova Conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mensagem de erro
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 20),

                // Campo: Nome da Conta
                Text(
                  'Nome da Conta',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nomeController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Ex: Conta Principal, Poupança, etc',
                    prefixIcon: const Icon(Icons.account_balance),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O nome da conta é obrigatório';
                    }
                    if (value.length < 3) {
                      return 'O nome deve ter pelo menos 3 caracteres';
                    }
                    if (value.length > 100) {
                      return 'O nome não pode ter mais de 100 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Campo: Tipo de Conta
                Text(
                  'Tipo de Conta',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _tipoSelecionado,
                    onChanged: _isLoading
                        ? null
                        : (String? newValue) {
                            setState(() {
                              _tipoSelecionado = newValue!;
                            });
                          },
                    isExpanded: true,
                    underline: const SizedBox(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: _tiposConta.map((String tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(_tiposDescricao[tipo]!),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Campo: Saldo Inicial
                Text(
                  'Saldo Inicial',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _saldoController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'R\$ 0,00',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    MaskTextInputFormatter(
                      mask: 'R\$ #,##0.00',
                      filter: {'#': RegExp(r'[0-9]')},
                      type: MaskAutoCompletionType.lazy,
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O saldo inicial é obrigatório';
                    }
                    try {
                      double.parse(
                        value.replaceAll('R\$ ', '').replaceAll(',', '.'),
                      );
                    } catch (e) {
                      return 'Digite um valor válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão de Criar Conta
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _criarConta,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                    _isLoading ? 'Criando Conta...' : 'Criar Conta',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botão de Cancelar
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
