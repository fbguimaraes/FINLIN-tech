import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client.dart';
import '../../data/datasources/conta_remote_datasource.dart';
import '../../data/repositories/conta_repository_impl.dart';
import '../../domain/entities/conta.dart';
import '../../domain/repositories/conta_repository.dart';
import 'usuario_provider.dart';

// ====== DATASOURCES ======
final contaDataSourceProvider = Provider((ref) =>
    ContaRemoteDataSource(apiClient: ref.watch(apiClientProvider)));

// ====== REPOSITORIES ======
final contaRepositoryProvider = Provider<ContaRepository>(
  (ref) =>
      ContaRepositoryImpl(remoteDataSource: ref.watch(contaDataSourceProvider)),
);

// ====== STATE MANAGEMENT ======

/// Notificador que gerencia o estado das contas
///
/// Controla o carregamento e cache de contas do usuário.
class ContasNotifier extends StateNotifier<AsyncValue<List<Conta>>> {
  final ContaRepository repository;

  ContasNotifier({required this.repository})
    : super(const AsyncValue.loading());

  /// Carrega as contas do usuário
  Future<void> loadContas() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.getContas());
  }

  /// Atualiza o saldo de uma conta
  ///
  /// Útil quando uma transação é criada/deletada
  void updateSaldoConta(String contaId, double novoSaldo) {
    state.whenData((contas) {
      final updatedContas = contas
          .map(
            (conta) =>
                conta.id == contaId ? conta.copyWith(saldo: novoSaldo) : conta,
          )
          .toList();
      state = AsyncValue.data(updatedContas);
    });
  }
}

/// Provider do estado das contas
final contasProvider =
    StateNotifierProvider<ContasNotifier, AsyncValue<List<Conta>>>((ref) {
      final notifier = ContasNotifier(
        repository: ref.watch(contaRepositoryProvider),
      );
      // Carrega automaticamente quando o provider é acessado
      notifier.loadContas();
      return notifier;
    });

/// Provider para obter uma conta específica pelo ID
final contaByIdProvider = FutureProvider.family<Conta?, String>((
  ref,
  contaId,
) async {
  final repository = ref.watch(contaRepositoryProvider);
  return repository.getContaById(contaId);
});
