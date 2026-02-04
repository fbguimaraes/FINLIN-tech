import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/login_provider.dart';
import '../providers/contas_provider_v2.dart';
import '../providers/transacoes_provider_v2.dart';
import '../providers/categorias_provider_v2.dart';
import '../providers/session_manager.dart';
import '../widgets/common_widgets.dart';
import '../dialogs/crud_dialogs.dart';
import '../../data/datasources/api_client_v2.dart';
import '../../domain/entities/transacao.dart';
import 'transacoes_screen.dart';
import 'todas_transacoes_screen.dart';

/// Tela inicial do aplicativo
class HomeScreenV2 extends ConsumerStatefulWidget {
  const HomeScreenV2({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends ConsumerState<HomeScreenV2> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final contasAsync = ref.watch(contasProvider);
    final transacoesAsync = ref.watch(transacoesProvider);

    // 🔄 Observar invalidações de dados
    ref.watch(dataRefreshNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${loginState.usuario?.nome ?? 'Usuário'}'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 🔄 Invalidar dados antes de fazer logout
              await AutoRefreshHelper.afterLogout(ref);
              if (mounted) {
                ref.read(loginProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalida os providers para recarregar
          await ref.refresh(contasProvider.future);
          await ref.refresh(transacoesProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== SEÇÃO DE CONTAS ====================
                Text(
                  'Suas Contas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                contasAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    print('❌ Erro ao carregar contas: $error');
                    return Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Erro: ${error.toString().replaceAll('Exception:', '')}',
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              ref.refresh(contasProvider);
                            },
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  },
                  data: (contas) {
                    if (contas.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma conta encontrada'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: contas.length,
                      itemBuilder: (context, index) {
                        final conta = contas[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransacoesScreen(conta: conta),
                                    ),
                                  )
                                  .then((_) {
                                    setState(() => _selectedIndex = 0);
                                  });
                            },
                            leading: const Icon(Icons.account_balance_wallet),
                            title: Text(conta.nome),
                            subtitle: Text(conta.tipo),
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
                                    showDialog(
                                      context: context,
                                      builder: (context) => ContaDialog(
                                        contaId: conta.id?.toString(),
                                        nomePadrao: conta.nome,
                                        saldoPadrao: conta.saldo,
                                        tipoPadrao: conta.tipo,
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        ref.refresh(contasProvider);
                                      }
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
                                        content: Text(
                                          'Tem certeza que deseja deletar a conta "${conta.nome}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              try {
                                                final apiClient = ApiClientV2();
                                                await apiClient.deleteConta(
                                                  conta.id?.toString() ?? '',
                                                );
                                                Navigator.pop(context);
                                                ref.refresh(contasProvider);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Conta deletada com sucesso',
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Erro: $e'),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text(
                                              'Deletar',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                              child: Text(
                                'R\$ ${conta.saldo.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: conta.saldo >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),

                // ==================== SEÇÃO DE TRANSAÇÕES ====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transações Recentes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TodasTransacoesScreen(),
                          ),
                        );
                      },
                      child: const Text('Ver Todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                transacoesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    print('❌ Erro ao carregar transações: $error');
                    return Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Erro: ${error.toString().replaceAll('Exception:', '')}',
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              ref.refresh(transacoesProvider);
                            },
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    );
                  },
                  data: (transacoes) {
                    if (transacoes.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma transação encontrada'),
                      );
                    }

                    // Mostrar apenas as 5 mais recentes
                    final recentes = transacoes.take(5).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentes.length,
                      itemBuilder: (context, index) {
                        final transacao = recentes[index];
                        final isReceita =
                            transacao.tipo == TipoTransacao.entrada;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              isReceita
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isReceita ? Colors.green : Colors.red,
                            ),
                            title: Text(transacao.descricao),
                            subtitle: Text(transacao.dataTransacao),
                            trailing: Text(
                              'R\$ ${transacao.valor.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isReceita ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ContaDialog(),
          ).then((result) {
            if (result == true) {
              ref.refresh(contasProvider);
            }
          });
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Conta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatório',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            // Já está em Home
            return;
          } else if (index == 1) {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => const TodasTransacoesScreen(),
                  ),
                )
                .then((_) {
                  setState(() {
                    _selectedIndex = 0;
                  });
                });
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/categorias').then((_) {
              setState(() {
                _selectedIndex = 0;
              });
            });
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/relatorio').then((_) {
              setState(() {
                _selectedIndex = 0;
              });
            });
          }
        },
      ),
    );
  }
}
