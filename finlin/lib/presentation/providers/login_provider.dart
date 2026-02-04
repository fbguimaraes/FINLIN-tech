import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/usuario.dart';
import '../../data/datasources/api_client_v2.dart';
import '../../data/models/usuario_model.dart';
import 'session_manager.dart';

// ============ INSTÂNCIA GLOBAL DO API CLIENT ============
// Singleton que é reutilizado em todos os providers
final apiClientProvider = Provider<ApiClientV2>((ref) {
  // Sempre retorna a mesma instância (singleton)
  return ApiClientV2();
});

// Estado do login
class LoginState {
  final bool isLoading;
  final Usuario? usuario;
  final String? error;

  LoginState({this.isLoading = false, this.usuario, this.error});

  LoginState copyWith({bool? isLoading, Usuario? usuario, String? error}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      usuario: usuario ?? this.usuario,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => usuario != null;
}

// Notificador de login
class LoginNotifier extends StateNotifier<LoginState> {
  final ApiClientV2 apiClient;

  LoginNotifier(this.apiClient) : super(LoginState());

  /// Realiza login
  Future<void> login(String email, String senha) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Fazer login e obter token
      await apiClient.login(email, senha);

      // 2. Salvar token na sessão
      if (apiClient.authToken != null) {
        final sessionManager = SessionManager();
        await sessionManager.initialize();
        await sessionManager.saveAuthToken(apiClient.authToken!);
      }

      // 3. Buscar dados do usuário
      final usuarioData = await apiClient.getUsuarioAtual();

      // 4. Converter para model
      final usuario = UsuarioModel.fromJson(usuarioData);

      // 5. Atualizar estado
      state = LoginState(usuario: usuario);
      print('✅ Login concluído com sucesso!');
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      print('❌ Erro no login: $errorMessage');
      state = LoginState(error: errorMessage);
    }
  }

  /// Faz logout
  void logout() {
    apiClient.logout();
    final sessionManager = SessionManager();
    // Não precisa de await aqui, mas idealmente seria async
    sessionManager.clearSession();
    state = LoginState();
    print('🚪 Logout realizado');
  }

  /// Limpa erro
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider de login
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(ref.watch(apiClientProvider)),
);
