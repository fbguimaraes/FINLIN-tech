import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/categorias_provider_v2.dart';
import '../dialogs/crud_dialogs.dart';
import '../../data/datasources/api_client_v2.dart';

class CategoriasScreen extends ConsumerWidget {
  const CategoriasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorias'), elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CategoriaDialog(),
          ).then((result) {
            if (result == true) {
              ref.refresh(categoriasProvider);
            }
          });
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Categoria',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: categoriasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar categorias',
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
                  ref.refresh(categoriasProvider);
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
        data: (categorias) {
          if (categorias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma categoria encontrada',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(categoriasProvider);
            },
            child: ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                final isReceita = categoria.tipo.toString().contains('entrada');
                final cor = isReceita ? Colors.green : Colors.red;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isReceita ? Icons.arrow_downward : Icons.arrow_upward,
                      color: cor,
                    ),
                  ),
                  title: Text(categoria.nome ?? 'Sem nome'),
                  subtitle: Text(isReceita ? 'Receita' : 'Saída'),
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
                            builder: (context) => CategoriaDialog(
                              categoriaId: categoria.id?.toString(),
                              nomePadrao: categoria.nome,
                              tipoPadrao:
                                  categoria.tipo.toString().contains('entrada')
                                  ? 'receita'
                                  : 'despesa',
                            ),
                          ).then((result) {
                            if (result == true) {
                              ref.refresh(categoriasProvider);
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
                                'Tem certeza que deseja deletar a categoria "${categoria.nome}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final apiClient = ApiClientV2();
                                      await apiClient.deleteCategoria(
                                        categoria.id?.toString() ?? '',
                                      );
                                      Navigator.pop(context);
                                      ref.refresh(categoriasProvider);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Categoria deletada com sucesso',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Erro: $e')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                    'Deletar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
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
