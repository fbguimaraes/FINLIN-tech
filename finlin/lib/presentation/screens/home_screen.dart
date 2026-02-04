import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usuario_provider.dart';
import '../providers/contas_provider.dart';
import '../providers/transacoes_provider.dart';
import '../widgets/common_widgets.dart';

/// Tela inicial do aplicativo
///
/// Exibe lista de contas e resumo das transações recentes.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega dados ao entrar na tela
    Future.microtask(() {
      ref.read(contasProvider.notifier).loadContas();
      ref.read(transacoesProvider.notifier).loadTransacoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioProvider);
    final contas = ref.watch(contasProvider);
    final transacoes = ref.watch(transacoesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${usuario?.nome ?? 'Usuário'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(usuarioProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(contasProvider.notifier).loadContas();
          await ref.read(transacoesProvider.notifier).loadTransacoes();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção de Contas
                Text(
                  'Suas Contas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                contas.when(
                  loading: () =>
                      const LoadingWidget(mensagem: 'Carregando contas...'),
                  error: (err, stack) => ErroWidget(
                    mensagem: 'Erro ao carregar contas',
                    onRetry: () => ref.refresh(contasProvider),
                  ),
                  data: (contasList) {
                    if (contasList.isEmpty) {
                      return const Text('Nenhuma conta encontrada');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: contasList.length,
                      itemBuilder: (context, index) {
                        final conta = contasList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.account_balance),
                            title: Text(conta.nome),
                            trailing: MoedaWidget(
                              valor: conta.saldo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: conta.saldo >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/conta-detalhes',
                                arguments: conta.id,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Seção de Transações Recentes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transações Recentes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/transacoes');
                      },
                      child: const Text('Ver Todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                transacoes.when(
                  loading: () =>
                      const LoadingWidget(mensagem: 'Carregando transações...'),
                  error: (err, stack) => ErroWidget(
                    mensagem: 'Erro ao carregar transações',
                    onRetry: () => ref.refresh(transacoesProvider),
                  ),
                  data: (transacoesList) {
                    if (transacoesList.isEmpty) {
                      return const Text('Nenhuma transação encontrada');
                    }

                    // Mostra apenas as 5 transações mais recentes
                    final recentes = List<dynamic>.from(transacoesList);
                    recentes.sort((a, b) => b.data.compareTo(a.data));

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentes.length > 5 ? 5 : recentes.length,
                      itemBuilder: (context, index) {
                        final transacao = recentes[index];
                        return TransacaoItemWidget(
                          descricao: transacao.descricao,
                          valor: transacao.valor,
                          isEntrada: transacao.tipo.toString().endsWith(
                            'entrada',
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transações'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatório',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break; // Já está na Home
            case 1:
              Navigator.of(context).pushNamed('/transacoes');
              break;
            case 2:
              Navigator.of(context).pushNamed('/relatorio');
              break;
          }
        },
      ),
    );
  }
}
