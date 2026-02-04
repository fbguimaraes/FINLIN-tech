import '../models/usuario_model.dart';
import 'api_client.dart';

/// DataSource remoto para Usuario
///
/// Faz chamadas HTTP para a API através do ApiClient.
class UsuarioRemoteDataSource {
  final ApiClient apiClient;

  UsuarioRemoteDataSource({required this.apiClient});

  /// Faz login na API
  Future<UsuarioModel> login(String email, String senha) async {
    try {
      // Faz login e obtém o token
      await apiClient.login(email: email, senha: senha);

      // Agora busca os dados do usuário autenticado usando o token armazenado
      final token = apiClient.currentToken;
      if (token == null) {
        throw Exception('Token não foi armazenado após login');
      }

      final usuarioData = await apiClient.getUsuarioAtual(token);
      return UsuarioModel.fromJson(usuarioData);
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Obtém usuário atual através do token
  Future<UsuarioModel> getUsuarioAtual(String token) async {
    try {
      final response = await apiClient.getUsuarioAtual(token);
      return UsuarioModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar usuário atual: $e');
    }
  }

  /// Faz logout (simples - apenas remove dados locais)
  Future<void> logout() async {
    // Logout é apenas local - remove o token armazenado
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
