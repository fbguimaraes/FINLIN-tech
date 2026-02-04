import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notificador para controlar estado de carregamento global
class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void setLoading(bool value) {
    state = value;
  }
}

/// Provider de estado global de carregamento
final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>(
  (ref) => LoadingNotifier(),
);

/// Notificador para mensagens de erro
class ErrorNotifier extends StateNotifier<String?> {
  ErrorNotifier() : super(null);

  void setError(String? error) {
    state = error;
  }

  void clear() {
    state = null;
  }
}

/// Provider de estado global de erro
final errorProvider = StateNotifierProvider<ErrorNotifier, String?>(
  (ref) => ErrorNotifier(),
);
