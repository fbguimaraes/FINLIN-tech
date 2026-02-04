import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client.dart';
import '../../data/datasources/usuario_remote_datasource.dart';
import '../../data/repositories/usuario_repository_impl.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

// ====== DATASOURCES ======
final apiClientProvider = Provider((ref) => ApiClient());

final usuarioDataSourceProvider = Provider((ref) =>
    UsuarioRemoteDataSource(apiClient: ref.watch(apiClientProvider)));

// ====== REPOSITORIES ======
final usuarioRepositoryProvider = Provider<UsuarioRepository>(
  (ref) => UsuarioRepositoryImpl(
    remoteDataSource: ref.watch(usuarioDataSourceProvider),
  ),
);

// ====== STATE MANAGEMENT ======

/// Notificador que gerencia o estado do usuário
///
/// Controla login, logout e dados do usuário autenticado.
/// Mantém o estado reativo durante toda a aplicação.
class UsuarioNotifier extends StateNotifier<Usuario?> {
  final UsuarioRepository repository;

  UsuarioNotifier({required this.repository}) : super(null);

  /// Realiza login do usuário
  ///
  /// Parâmetros:
  /// - [email]: Email do usuário
  /// - [senha]: Senha do usuário
  Future<void> login(String email, String senha) async {
    try {
      final usuario = await repository.login(email, senha);
      state = usuario;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtém dados do usuário autenticado
  Future<void> loadUsuarioAtual() async {
    try {
      final usuario = await repository.getUsuarioAtual();
      state = usuario;
    } catch (e) {
      rethrow;
    }
  }

  /// Realiza logout do usuário
  Future<void> logout() async {
    try {
      await repository.logout();
      state = null;
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica se há usuário autenticado
  bool get isAuthenticated => state != null;
}

/// Provider do estado do usuário
///
/// Pode ser acessado em qualquer lugar da aplicação.
final usuarioProvider = StateNotifierProvider<UsuarioNotifier, Usuario?>(
  (ref) => UsuarioNotifier(repository: ref.watch(usuarioRepositoryProvider)),
);
