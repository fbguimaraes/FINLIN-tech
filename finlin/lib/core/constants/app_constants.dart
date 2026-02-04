/// Constantes da aplicação
class AppConstants {
  // URLs da API
  // IMPORTANTE: 'dart:io' quebra o Flutter Web.
  // Para Android Emulator use: 'http://10.0.2.2:8000'
  // Para Web/iOS/Desktop use: 'http://127.0.0.1:8000'

  static String get apiBaseUrl {
    // Se quiser suporte automático a Android Emulator, precisa de conditional imports.
    // Por segurança e para funcionar na Web agora, vamos manter localhost.
    return 'http://127.0.0.1:8000';
  }

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String usuariosEndpoint = '/usuarios';
  static const String contasEndpoint = '/contas';
  static const String categoriasEndpoint = '/categorias';
  static const String transacoesEndpoint = '/transacoes';
  static const String seedEndpoint = '/seed';
  static const String limparDadosEndpoint = '/limpar-dados';

  // IDs de exemplo para dados mockados (ainda usados em fallback)
  static const String usuarioIdMock = 'user_001';
  static const String contaBancariaMockId = 'conta_001';
  static const String contaPoupancaMockId = 'conta_002';

  // Formatação de moeda
  static const String currencySymbol = 'R\$';
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}
