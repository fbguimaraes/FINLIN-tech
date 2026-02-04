import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client.dart';
import '../../data/datasources/categoria_remote_datasource.dart';
import '../../data/repositories/categoria_repository_impl.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/repositories/categoria_repository.dart';
import 'usuario_provider.dart';

// ====== DATASOURCES ======
final categoriaDataSourceProvider = Provider(
  (ref) => CategoriaRemoteDataSource(apiClient: ref.watch(apiClientProvider)),
);

// ====== REPOSITORIES ======
final categoriaRepositoryProvider = Provider<CategoriaRepository>(
  (ref) => CategoriaRepositoryImpl(
    remoteDataSource: ref.watch(categoriaDataSourceProvider),
  ),
);

// ====== STATE MANAGEMENT ======

/// Notificador que gerencia o estado das categorias
class CategoriasNotifier extends StateNotifier<AsyncValue<List<Categoria>>> {
  final CategoriaRepository repository;

  CategoriasNotifier({required this.repository})
    : super(const AsyncValue.loading());

  /// Carrega todas as categorias
  Future<void> loadCategorias() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getCategorias());
  }
}

/// Provider do estado das categorias
final categoriasProvider =
    StateNotifierProvider<CategoriasNotifier, AsyncValue<List<Categoria>>>((
      ref,
    ) {
      final notifier = CategoriasNotifier(
        repository: ref.watch(categoriaRepositoryProvider),
      );
      // Carrega automaticamente
      notifier.loadCategorias();
      return notifier;
    });

/// Provider para categorias filtradas por tipo
final categoriasPorTipoProvider =
    FutureProvider.family<List<Categoria>, String>((ref, tipo) async {
      final repository = ref.watch(categoriaRepositoryProvider);
      return repository.getCategoriasPorTipo(tipo);
    });

/// Provider que filtra categorias do estado por tipo
/// Usa as categorias já carregadas em categoriasProvider
final categoriasFiltroProvider =
    Provider.family<AsyncValue<List<Categoria>>, String>((ref, tipo) {
      return ref
          .watch(categoriasProvider)
          .whenData(
            (categorias) => categorias
                .where((cat) => cat.tipo.toString().split('.').last == tipo)
                .toList(),
          );
    });
