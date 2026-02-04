import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contas_provider.dart';
import '../providers/transacoes_provider.dart';
import '../widgets/common_widgets.dart';

/// Tela de detalhes da conta
///
/// Exibe informações da conta e transações específicas dela.
class ContaDetalhesScreen extends ConsumerStatefulWidget {
  final String contaId;

  const ContaDetalhesScreen({required this.contaId, Key? key})
    : super(key: key);

  @override
  ConsumerState<ContaDetalhesScreen> createState() =>
      _ContaDetalhesScreenState();
}

class _ContaDetalhesScreenState extends ConsumerState<ContaDetalhesScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega dados ao entrar na tela
    Future.microtask(() async {
      await ref.refresh(contaByIdProvider(widget.contaId).future);
      await ref.refresh(transacoesPorContaProvider(widget.contaId).future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final conta = ref.watch(contaByIdProvider(widget.contaId));
    final transacoes = ref.watch(transacoesPorContaProvider(widget.contaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Conta')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(contaByIdProvider(widget.contaId).future);
          await ref.refresh(transacoesPorContaProvider(widget.contaId).future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: conta.when(
              loading: () =>
                  const LoadingWidget(mensagem: 'Carregando conta...'),
              error: (err, stack) => ErroWidget(
                mensagem: 'Erro ao carregar conta',
                onRetry: () => ref.refresh(contaByIdProvider(widget.contaId)),
              ),
              data: (contaData) {
                if (contaData == null) {
                  return Center(
                    child: Text(
                      'Conta não encontrada',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header com saldo
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              contaData.nome,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Saldo Disponível',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            MoedaWidget(
                              valor: contaData.saldo,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: contaData.saldo >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Transações
                    Text(
                      'Transações',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    transacoes.when(
                      loading: () => const LoadingWidget(
                        mensagem: 'Carregando transações...',
                      ),
                      error: (err, stack) => ErroWidget(
                        mensagem: 'Erro ao carregar transações',
                        onRetry: () => ref.refresh(
                          transacoesPorContaProvider(widget.contaId),
                        ),
                      ),
                      data: (transacoesList) {
                        if (transacoesList.isEmpty) {
                          return Center(
                            child: Text(
                              'Nenhuma transação para esta conta',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }

                        // Ordena por data decrescente
                        transacoesList.sort((a, b) => b.data.compareTo(a.data));

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transacoesList.length,
                          itemBuilder: (context, index) {
                            final transacao = transacoesList[index];
                            final isEntrada = transacao.tipo
                                .toString()
                                .endsWith('entrada');

                            return TransacaoItemWidget(
                              descricao: transacao.descricao,
                              valor: transacao.valor,
                              isEntrada: isEntrada,
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
