import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/api_client_v2.dart';
import 'contas_provider_v2.dart';
import 'transacoes_provider_v2.dart';
import 'categorias_provider_v2.dart';

/// Gerencia a sessão do usuário e sincronização de dados em tempo real
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Salva o token de autenticação
  Future<void> saveAuthToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  /// Recupera o token de autenticação
  String? getAuthToken() {
    return _prefs?.getString('auth_token');
  }

  /// Limpa a sessão
  Future<void> clearSession() async {
    await _prefs?.clear();
  }

  /// Verifica se há uma sessão ativa
  bool hasActiveSession() {
    return getAuthToken() != null;
  }
}

/// Provider do SessionManager
final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager();
});

/// Provider que gerencia invalidação de dados
/// Pode ser usado para invalidar providers quando dados mudam
final dataRefreshNotifierProvider =
    StateNotifierProvider<DataRefreshNotifier, int>((ref) {
      return DataRefreshNotifier();
    });

/// Notificador que controla quando os dados precisam ser recarregados
class DataRefreshNotifier extends StateNotifier<int> {
  DataRefreshNotifier() : super(0);

  /// Dispara uma invalidação de dados (incrementa contador)
  void refresh() {
    state = state + 1;
  }

  /// Invalida contas especificamente
  void invalidateContas(WidgetRef ref) {
    ref.invalidate(contasProvider);
  }

  /// Invalida transações especificamente
  void invalidateTransacoes(WidgetRef ref) {
    ref.invalidate(transacoesProvider);
  }

  /// Invalida categorias especificamente
  void invalidateCategorias(WidgetRef ref) {
    ref.invalidate(categoriasProvider);
  }

  /// Invalida tudo ao mesmo tempo (nuclear option)
  void invalidateAll(WidgetRef ref) {
    ref.invalidate(contasProvider);
    ref.invalidate(transacoesProvider);
    ref.invalidate(categoriasProvider);
  }
}

/// Hook para facilitar refresh automático após ações
class AutoRefreshHelper {
  /// Invalida providers após criar uma transação
  static Future<void> afterTransacaoCreated(WidgetRef ref) async {
    // Pequeno delay para garantir que a API processou
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(dataRefreshNotifierProvider.notifier).invalidateTransacoes(ref);
    ref.read(dataRefreshNotifierProvider.notifier).invalidateContas(ref);
  }

  /// Invalida providers após criar uma categoria
  static Future<void> afterCategoriaCreated(WidgetRef ref) async {
    await Future.delayed(const Duration(milliseconds: 300));
    ref.read(dataRefreshNotifierProvider.notifier).invalidateCategorias(ref);
  }

  /// Invalida providers após criar uma conta
  static Future<void> afterContaCreated(WidgetRef ref) async {
    await Future.delayed(const Duration(milliseconds: 300));
    ref.read(dataRefreshNotifierProvider.notifier).invalidateContas(ref);
  }

  /// Invalida tudo após logout
  static Future<void> afterLogout(WidgetRef ref) async {
    ref.read(dataRefreshNotifierProvider.notifier).invalidateAll(ref);
  }
}
