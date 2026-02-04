import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client.dart';
import '../../data/datasources/transacao_remote_datasource.dart';
import '../../data/repositories/transacao_repository_impl.dart';
import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transacao_repository.dart';
import 'usuario_provider.dart';

// ====== DATASOURCES ======
final transacaoDataSourceProvider = Provider(
  (ref) => TransacaoRemoteDataSource(apiClient: ref.watch(apiClientProvider)),
);

// ====== REPOSITORIES ======
final transacaoRepositoryProvider = Provider<TransacaoRepository>(
  (ref) => TransacaoRepositoryImpl(
    remoteDataSource: ref.watch(transacaoDataSourceProvider),
  ),
);

// ====== STATE MANAGEMENT ======

/// Notificador que gerencia o estado das transações
class TransacoesNotifier extends StateNotifier<AsyncValue<List<Transacao>>> {
  final TransacaoRepository repository;

  TransacoesNotifier({required this.repository})
    : super(const AsyncValue.loading());

  /// Carrega todas as transações
  Future<void> loadTransacoes() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getTransacoes());
  }

  /// Cria uma nova transação
  Future<Transacao> criarTransacao(Transacao transacao) async {
    try {
      final novaTransacao = await repository.criar(transacao);

      // Atualiza o estado adicionando a nova transação
      state.whenData((transacoes) {
        final updated = [...transacoes, novaTransacao];
        state = AsyncValue.data(updated);
      });

      return novaTransacao;
    } catch (e) {
      rethrow;
    }
  }

  /// Deleta uma transação
  Future<void> deletarTransacao(String id) async {
    try {
      await repository.deletar(id);

      // Remove do estado
      state.whenData((transacoes) {
        final updated = transacoes.where((t) => t.id != id).toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider do estado das transações
final transacoesProvider =
    StateNotifierProvider<TransacoesNotifier, AsyncValue<List<Transacao>>>((
      ref,
    ) {
      final notifier = TransacoesNotifier(
        repository: ref.watch(transacaoRepositoryProvider),
      );
      // Carrega automaticamente
      notifier.loadTransacoes();
      return notifier;
    });

/// Provider para transações de uma conta específica
final transacoesPorContaProvider =
    FutureProvider.family<List<Transacao>, String>((ref, contaId) async {
      final repository = ref.watch(transacaoRepositoryProvider);
      return repository.getTransacoesPorConta(contaId);
    });

/// Provider que filtra transações do estado por conta
final transacaosFiltroProvider =
    Provider.family<AsyncValue<List<Transacao>>, String>((ref, contaId) {
      return ref
          .watch(transacoesProvider)
          .whenData(
            (transacoes) =>
                transacoes.where((t) => t.contaId == contaId).toList(),
          );
    });

/// Provider para relatório mensal
final relatorioMensalProvider =
    FutureProvider.family<Map<String, dynamic>, (int, int)>((
      ref,
      params,
    ) async {
      final (mes, ano) = params;
      final repository = ref.watch(transacaoRepositoryProvider);
      return repository.getRelatorioMensal(mes, ano);
    });
