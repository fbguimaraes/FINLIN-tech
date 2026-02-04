import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client_v2.dart';
import '../providers/login_provider.dart';
import '../providers/session_manager.dart';

/// Dialog para criar/editar uma conta
class ContaDialog extends ConsumerStatefulWidget {
  final String? contaId;
  final String? nomePadrao;
  final double? saldoPadrao;
  final String? tipoPadrao;

  const ContaDialog({
    Key? key,
    this.contaId,
    this.nomePadrao,
    this.saldoPadrao,
    this.tipoPadrao,
  }) : super(key: key);

  @override
  ConsumerState<ContaDialog> createState() => _ContaDialogState();
}

class _ContaDialogState extends ConsumerState<ContaDialog> {
  late TextEditingController nomeController;
  String? tipoSelecionado;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.nomePadrao ?? '');
    tipoSelecionado = widget.tipoPadrao ?? 'corrente';
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contaId == null ? 'Nova Conta' : 'Editar Conta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: tipoSelecionado,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: ['corrente', 'poupança', 'investimento']
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (valor) {
                setState(() {
                  tipoSelecionado = valor;
                });
              },
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
          onPressed: isLoading ? null : _salvar,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _salvar() async {
    if (nomeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nome é obrigatório')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final apiClient = ApiClientV2();

      final userId = ref.read(loginProvider).usuario?.id;
      if (widget.contaId == null) {
        await apiClient.createConta(
          nomeController.text,
          0.0,
          tipoSelecionado ?? 'corrente',
          idUsuario: userId,
        );
        // 🔄 Invalidar dados após criar conta
        await AutoRefreshHelper.afterContaCreated(ref);
      } else {
        await apiClient.updateConta(
          widget.contaId!,
          nome: nomeController.text,
          tipo: tipoSelecionado,
        );
        // 🔄 Invalidar dados após atualizar conta
        await AutoRefreshHelper.afterContaCreated(ref);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

/// Dialog para criar/editar uma transação
class TransacaoDialog extends ConsumerStatefulWidget {
  final String? transacaoId;
  final String contaId;
  final List<dynamic> categorias;
  final String? descricaoPadrao;
  final double? valorPadrao;
  final String? tipoPadrao;

  const TransacaoDialog({
    Key? key,
    this.transacaoId,
    required this.contaId,
    required this.categorias,
    this.descricaoPadrao,
    this.valorPadrao,
    this.tipoPadrao,
  }) : super(key: key);

  @override
  ConsumerState<TransacaoDialog> createState() => _TransacaoDialogState();
}

class _TransacaoDialogState extends ConsumerState<TransacaoDialog> {
  late TextEditingController descricaoController;
  late TextEditingController valorController;
  String? tipoSelecionado;
  dynamic categoriaSelecionada;
  bool isLoading = false;

  /// Filtra categorias baseado no tipo selecionado
  List<dynamic> _filtrarCategorias(String tipo) {
    return widget.categorias.where((cat) {
      final tipoCategoria = cat.tipo.toString();
      if (tipo == 'receita') {
        return tipoCategoria.contains('entrada');
      } else {
        return tipoCategoria.contains('saida');
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    descricaoController = TextEditingController(
      text: widget.descricaoPadrao ?? '',
    );
    valorController = TextEditingController(
      text: widget.valorPadrao?.toString() ?? '0.00',
    );
    if (widget.categorias.isNotEmpty) {
      categoriaSelecionada = widget.categorias.first;
      // 🔄 Sincronizar tipo com a categoria padrão
      if (categoriaSelecionada != null && categoriaSelecionada.tipo != null) {
        final tipoCategoria = categoriaSelecionada.tipo.toString();
        tipoSelecionado = tipoCategoria.contains('entrada')
            ? 'receita'
            : 'despesa';
      } else {
        tipoSelecionado = widget.tipoPadrao ?? 'despesa';
      }
    } else {
      tipoSelecionado = widget.tipoPadrao ?? 'despesa';
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.transacaoId == null ? 'Nova Transação' : 'Editar Transação',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: tipoSelecionado,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: ['receita', 'despesa']
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (valor) {
                setState(() {
                  tipoSelecionado = valor;
                  // 🔄 Filtrar categorias disponíveis para o novo tipo
                  final categoriasDoTipo = _filtrarCategorias(valor!);
                  if (categoriasDoTipo.isNotEmpty) {
                    categoriaSelecionada = categoriasDoTipo.first;
                  } else {
                    categoriaSelecionada = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<dynamic>(
              value: categoriaSelecionada,
              decoration: InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: _filtrarCategorias(tipoSelecionado!)
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat.nome ?? 'Sem nome'),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                setState(() {
                  categoriaSelecionada = valor;
                  // 🔄 Sincronizar tipo de transação com o tipo da categoria
                  if (valor != null && valor.tipo != null) {
                    final tipoCategoria = valor.tipo.toString();
                    tipoSelecionado = tipoCategoria.contains('entrada')
                        ? 'receita'
                        : 'despesa';
                  }
                });
              },
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
          onPressed: isLoading ? null : _salvar,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _salvar() async {
    if (descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Descrição é obrigatória')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final apiClient = ApiClientV2();
      final valor = double.parse(valorController.text);
      final idCategoria =
          categoriaSelecionada.id ?? categoriaSelecionada.id_categoria;

      if (widget.transacaoId == null) {
        await apiClient.createTransacao(
          widget.contaId,
          idCategoria.toString(),
          valor,
          tipoSelecionado ?? 'despesa',
          descricaoController.text,
          DateTime.now().toIso8601String().split('T')[0],
        );
        // 🔄 Invalidar dados após criar transação
        await AutoRefreshHelper.afterTransacaoCreated(ref);
      } else {
        await apiClient.updateTransacao(
          widget.transacaoId!,
          valor: valor,
          tipo: tipoSelecionado,
          descricao: descricaoController.text,
        );
        // 🔄 Invalidar dados após atualizar transação
        await AutoRefreshHelper.afterTransacaoCreated(ref);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

/// Dialog para criar/editar uma categoria
class CategoriaDialog extends ConsumerStatefulWidget {
  final String? categoriaId;
  final String? nomePadrao;
  final String? tipoPadrao;

  const CategoriaDialog({
    Key? key,
    this.categoriaId,
    this.nomePadrao,
    this.tipoPadrao,
  }) : super(key: key);

  @override
  ConsumerState<CategoriaDialog> createState() => _CategoriaDialogState();
}

class _CategoriaDialogState extends ConsumerState<CategoriaDialog> {
  late TextEditingController nomeController;
  String tipoSelecionado = 'receita';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.nomePadrao ?? '');
    tipoSelecionado = widget.tipoPadrao ?? 'receita';
  }

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.categoriaId == null ? 'Nova Categoria' : 'Editar Categoria',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome da Categoria',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: tipoSelecionado,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: ['receita', 'despesa']
                  .map(
                    (tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)),
                  )
                  .toList(),
              onChanged: (valor) {
                setState(() {
                  tipoSelecionado = valor ?? 'receita';
                });
              },
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
          onPressed: isLoading ? null : _salvar,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _salvar() async {
    if (nomeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nome é obrigatório')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final apiClient = ApiClientV2();

      final userId = ref.read(loginProvider).usuario?.id;
      if (widget.categoriaId == null) {
        await apiClient.createCategoria(
          nomeController.text,
          tipoSelecionado,
          idUsuario: userId,
        );
        // 🔄 Invalidar dados após criar categoria
        await AutoRefreshHelper.afterCategoriaCreated(ref);
      } else {
        await apiClient.updateCategoria(
          widget.categoriaId!,
          nome: nomeController.text,
          tipo: tipoSelecionado,
        );
        // 🔄 Invalidar dados após atualizar categoria
        await AutoRefreshHelper.afterCategoriaCreated(ref);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
