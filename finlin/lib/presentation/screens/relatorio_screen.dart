import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contas_provider_v2.dart';
import '../providers/transacoes_provider_v2.dart';
import '../widgets/common_widgets.dart';
import '../../domain/entities/transacao.dart';

/// Tela de relatÃ³rio mensal
///
/// Exibe resumo de entradas, saÃ­das e saldo do mÃªs selecionado
/// com filtros por conta.
class RelatorioScreen extends ConsumerStatefulWidget {
  const RelatorioScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends ConsumerState<RelatorioScreen> {
  late int _mesAtual;
  late int _anoAtual;
  String? _contaSelecionadaId;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _mesAtual = agora.month;
    _anoAtual = agora.year;
  }

  /// AvanÃ§a para o prÃ³ximo mÃªs
  void _proximoMes() {
    setState(() {
      if (_mesAtual == 12) {
        _mesAtual = 1;
        _anoAtual++;
      } else {
        _mesAtual++;
      }
    });
  }

  /// Volta para o mÃªs anterior
  void _mesPrevio() {
    setState(() {
      if (_mesAtual == 1) {
        _mesAtual = 12;
        _anoAtual--;
      } else {
        _mesAtual--;
      }
    });
  }

  /// Retorna o nome do mÃªs
  String _getNomeMes(int mes) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'MarÃ§o',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return meses[mes - 1];
  }

  @override
  Widget build(BuildContext context) {
    final contasAsync = ref.watch(contasProvider);
    final transacoesAsync = ref.watch(transacoesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('RelatÃ³rio Mensal')),
      body: Column(
        children: [
          // Seletor de mÃªs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _mesPrevio,
                    ),
                    Text(
                      '${_getNomeMes(_mesAtual)} $_anoAtual',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _proximoMes,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ConteÃºdo do relatÃ³rio
          Expanded(
            child: contasAsync.when(
              loading: () =>
                  const LoadingWidget(mensagem: 'Carregando contas...'),
              error: (err, stack) => ErroWidget(
                mensagem: 'Erro ao carregar contas',
                onRetry: () => ref.refresh(contasProvider),
              ),
              data: (contas) {
                if (contas.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma conta encontrada'),
                  );
                }

                _contaSelecionadaId ??= contas.first.id;

                return transacoesAsync.when(
                  loading: () => const LoadingWidget(
                    mensagem: 'Carregando transaÃ§Ãµes...',
                  ),
                  error: (err, stack) => ErroWidget(
                    mensagem: 'Erro ao carregar transaÃ§Ãµes',
                    onRetry: () => ref.refresh(transacoesProvider),
                  ),
                  data: (transacoes) {
                    final contaId = _contaSelecionadaId!;
                    final transacoesMes = transacoes.where((t) {
                      return t.contaId == contaId &&
                          t.data.month == _mesAtual &&
                          t.data.year == _anoAtual;
                    }).toList();

                    double totalEntrada = 0.0;
                    double totalSaida = 0.0;

                    for (final t in transacoesMes) {
                      if (t.tipo == TipoTransacao.entrada) {
                        totalEntrada += t.valor;
                      } else {
                        totalSaida += t.valor;
                      }
                    }

                    final saldo = totalEntrada - totalSaida;

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Seletor de conta
                            Row(
                              children: [
                                const Icon(Icons.account_balance_wallet),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _contaSelecionadaId,
                                    decoration: const InputDecoration(
                                      labelText: 'Conta',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: contas
                                        .map(
                                          (conta) => DropdownMenuItem(
                                            value: conta.id,
                                            child: Text(conta.nome),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (valor) {
                                      setState(() {
                                        _contaSelecionadaId = valor;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Cards de resumo
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Card de Entradas
                                Expanded(
                                  child: Card(
                                    color: Colors.green.shade50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.arrow_downward,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Entradas',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          const SizedBox(height: 8),
                                          MoedaWidget(
                                            valor: totalEntrada,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Card de SaÃ­das
                                Expanded(
                                  child: Card(
                                    color: Colors.red.shade50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.arrow_upward,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'SaÃ­das',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          const SizedBox(height: 8),
                                          MoedaWidget(
                                            valor: totalSaida,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Card de Saldo
                            SaldoWidget(valor: saldo),
                            const SizedBox(height: 24),

                            // GrÃ¡fico simples
                            _ResumoBarChart(
                              totalEntrada: totalEntrada,
                              totalSaida: totalSaida,
                            ),
                            const SizedBox(height: 32),

                            // TransaÃ§Ãµes do mÃªs
                            if (transacoesMes.isNotEmpty) ...[
                              Text(
                                'TransaÃ§Ãµes do mÃªs',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: transacoesMes.length,
                                itemBuilder: (context, index) {
                                  final transacao = transacoesMes[index];
                                  final isEntrada =
                                      transacao.tipo == TipoTransacao.entrada;

                                  return TransacaoItemWidget(
                                    descricao: transacao.descricao,
                                    valor: transacao.valor,
                                    isEntrada: isEntrada,
                                  );
                                },
                              ),
                            ] else
                              Text(
                                'Nenhuma transaÃ§Ã£o neste mÃªs',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumoBarChart extends StatelessWidget {
  final double totalEntrada;
  final double totalSaida;

  const _ResumoBarChart({
    required this.totalEntrada,
    required this.totalSaida,
  });

  @override
  Widget build(BuildContext context) {
    final maxValor = (totalEntrada > totalSaida) ? totalEntrada : totalSaida;
    final safeMax = maxValor <= 0 ? 1.0 : maxValor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entradas x SaÃ­das',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _Bar(
                      label: 'Entradas',
                      value: totalEntrada,
                      maxValue: safeMax,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Bar(
                      label: 'SaÃ­das',
                      value: totalSaida,
                      maxValue: safeMax,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const _Bar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final heightFactor = (value / maxValue).clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
