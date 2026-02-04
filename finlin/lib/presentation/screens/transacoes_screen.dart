import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/conta.dart';
import '../../domain/entities/transacao.dart';
import '../providers/transacoes_por_conta_provider.dart';
import '../providers/categorias_provider_v2.dart';
import '../dialogs/crud_dialogs.dart';
import '../../data/datasources/api_client_v2.dart';

class TransacoesScreen extends ConsumerWidget {
  final Conta conta;

  const TransacoesScreen({
    Key? key,
    required this.conta,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transacoesAsync = ref.watch(transacoesPorContaProvider(conta.id));
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transações - ${conta.nome}'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          categoriasAsync.whenData((categorias) {
            showDialog(
              context: context,
              builder: (context) => TransacaoDialog(
                contaId: conta.id,
                categorias: categorias,
              ),
            ).then((result) {
              if (result == true) {
                ref.refresh(transacoesPorContaProvider(conta.id));
              }
            });
          });
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Transação',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: transacoesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar transações',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(transacoesPorContaProvider(conta.id));
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
        data: (transacoes) {
          if (transacoes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma transação encontrada',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(transacoesPorContaProvider(conta.id));
            },
            child: ListView.builder(
              itemCount: transacoes.length,
              itemBuilder: (context, index) {
                final transacao = transacoes[index];
                final isReceita = transacao.tipo == TipoTransacao.entrada;
                final cor = isReceita ? Colors.green : Colors.red;
                final icone = isReceita ? Icons.arrow_downward : Icons.arrow_upward;
                final sinal = isReceita ? '+' : '-';

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icone, color: cor),
                  ),
                  title: Text(transacao.descricao ?? 'Sem descrição'),
                  subtitle: Text(transacao.dataTransacao),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                        onTap: () {
                          categoriasAsync.whenData((categorias) {
                            showDialog(
                              context: context,
                              builder: (context) => TransacaoDialog(
                                transacaoId: transacao.id.toString(),
                                contaId: conta.id,
                                categorias: categorias,
                                descricaoPadrao: transacao.descricao,
                                valorPadrao: transacao.valor,
                                tipoPadrao: transacao.tipo == TipoTransacao.entrada
                                    ? 'receita'
                                    : 'despesa',
                              ),
                            ).then((result) {
                              if (result == true) {
                                ref.refresh(
                                    transacoesPorContaProvider(conta.id));
                              }
                            });
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Deletar'),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar Exclusão'),
                              content: const Text(
                                  'Tem certeza que deseja deletar esta transação?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final apiClient = ApiClientV2();
                                      await apiClient.deleteTransacao(
                                          transacao.id.toString());
                                      Navigator.pop(context);
                                      ref.refresh(transacoesPorContaProvider(
                                          conta.id));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Transação deletada com sucesso'),
                                        ),
                                      );
                                    } catch (e) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Erro: $e'),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Deletar',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    child: Text(
                      '$sinal R\$ ${transacao.valor.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: cor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
