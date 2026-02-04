import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// Cliente HTTP da API
///
/// Responsável por fazer chamadas HTTP para a API REST FastAPI.
class ApiClient {
  final String baseUrl = AppConstants.apiBaseUrl;
  String? currentToken;

  /// Construtor do ApiClient
  ApiClient();

  // ==== MÉTODOS PARA USUÁRIO ====

  /// Login na API
  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final url = Uri.parse('$baseUrl${AppConstants.loginEndpoint}');
      print('🔐 Tentando login em: $url');
      print('📧 Email: $email');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout na requisição - API não respondeu em 10 segundos');
        },
      );

      print('✅ Resposta recebida com status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        currentToken = data['access_token'];
        print('🎉 Token armazenado com sucesso');
        return data;
      } else {
        print('❌ Erro: ${response.body}');
        throw Exception('Falha no login: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      throw Exception('Erro de conexão: $e\n\nVerifique se a API está rodando em $baseUrl');
    } catch (e) {
      print('❌ Erro geral: $e');
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Obtém usuário atual
  Future<Map<String, dynamic>> getUsuarioAtual(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.usuariosEndpoint}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar usuário');
      }
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  // ==== MÉTODOS PARA CONTAS ====

  /// Obtém lista de contas
  Future<List<Map<String, dynamic>>> getContas(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.contasEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        return decoded.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao buscar contas');
      }
    } catch (e) {
      throw Exception('Erro ao buscar contas: $e');
    }
  }

  /// Obtém uma conta por ID
  Future<Map<String, dynamic>> getContaById(String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.contasEndpoint}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar conta');
      }
    } catch (e) {
      throw Exception('Erro ao buscar conta: $e');
    }
  }

  /// Cria uma nova conta
  Future<Map<String, dynamic>> criarConta({
    required Map<String, dynamic> dadosConta,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.contasEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dadosConta),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar conta');
      }
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  // ==== MÉTODOS PARA CATEGORIAS ====

  /// Obtém lista de categorias
  Future<List<Map<String, dynamic>>> getCategorias(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.categoriasEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        return decoded.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao buscar categorias');
      }
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }

  /// Cria uma nova categoria
  Future<Map<String, dynamic>> criarCategoria({
    required Map<String, dynamic> dadosCategoria,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.categoriasEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dadosCategoria),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar categoria');
      }
    } catch (e) {
      throw Exception('Erro ao criar categoria: $e');
    }
  }

  // ==== MÉTODOS PARA TRANSAÇÕES ====

  /// Obtém lista de transações
  Future<List<Map<String, dynamic>>> getTransacoes(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.transacoesEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        return decoded.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao buscar transações');
      }
    } catch (e) {
      throw Exception('Erro ao buscar transações: $e');
    }
  }

  /// Obtém transações de uma conta
  Future<List<Map<String, dynamic>>> getTransacoesConta(
    String contaId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.contasEndpoint}/$contaId${AppConstants.transacoesEndpoint}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        return decoded.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao buscar transações da conta');
      }
    } catch (e) {
      throw Exception('Erro ao buscar transações da conta: $e');
    }
  }

  /// Cria uma nova transação
  Future<Map<String, dynamic>> criarTransacao({
    required Map<String, dynamic> dadosTransacao,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.transacoesEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dadosTransacao),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar transação');
      }
    } catch (e) {
      throw Exception('Erro ao criar transação: $e');
    }
  }

  /// Seed da API - Popula dados de teste
  Future<Map<String, dynamic>> seedDatabase() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.seedEndpoint}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao executar seed');
      }
    } catch (e) {
      throw Exception('Erro ao executar seed: $e');
    }
  }
}
