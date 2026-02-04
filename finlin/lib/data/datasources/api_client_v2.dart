import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// Cliente HTTP da API - Versão 2 (REFATORADO)
/// 
/// Implementação simplificada e testada do cliente HTTP
class ApiClientV2 {
  static final ApiClientV2 _instance = ApiClientV2._internal();
  
  factory ApiClientV2() {
    return _instance;
  }
  
  ApiClientV2._internal();
  
  final String baseUrl = AppConstants.apiBaseUrl;
  String? authToken;

  static const int timeoutSeconds = 10;

  /// Realiza login
  /// Retorna: {"access_token": "...", "token_type": "bearer"}
  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      print('🔐 Iniciando login para: $email');
      print('📍 URL: $url');

      final body = jsonEncode({
        'email': email,
        'senha': senha,
      });

      print('📤 Enviando payload: $body');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: timeoutSeconds), onTimeout: () {
        throw Exception(
            'Timeout: API não respondeu em $timeoutSeconds segundos. Verifique se está rodando em $baseUrl');
      });

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        authToken = data['access_token'] as String?;

        if (authToken == null) {
          throw Exception('Token não retornado pela API');
        }

        print('✅ Login bem-sucedido! Token: ${authToken!.substring(0, 20)}...');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Email ou senha incorretos');
      } else {
        throw Exception(
            'Erro no servidor (${response.statusCode}): ${response.body}');
      }
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      throw Exception(
          'Erro de conexão: Não foi possível conectar a $baseUrl\n\nErro: $e');
    } on Exception catch (e) {
      print('❌ Exception: $e');
      rethrow;
    } catch (e) {
      print('❌ Erro desconhecido: $e');
      throw Exception('Erro desconhecido: $e');
    }
  }

  /// Obtém usuário autenticado
  /// Retorna: {"id_usuario": 1, "nome": "...", "email": "..."}
  Future<Map<String, dynamic>> getUsuarioAtual() async {
    if (authToken == null) {
      throw Exception('Usuário não autenticado (token ausente)');
    }

    try {
      final url = Uri.parse('$baseUrl/usuarios/me');
      print('👤 Buscando usuário autenticado');
      print('📍 URL: $url');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds), onTimeout: () {
        throw Exception('Timeout ao buscar dados do usuário');
      });

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Dados do usuário obtidos: ${data['email']}');
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Token inválido ou expirado');
      } else {
        throw Exception('Erro ao buscar dados (${response.statusCode})');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erro de conexão ao buscar usuário: $e');
    } catch (e) {
      rethrow;
    }
  }

  /// Busca todas as contas
  Future<List<Map<String, dynamic>>> getContas() async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/contas/');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token inválido ou expirado');
      } else {
        throw Exception('Erro ao buscar contas (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Busca todas as categorias
  Future<List<Map<String, dynamic>>> getCategorias() async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/categorias/');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token inválido ou expirado');
      } else {
        throw Exception('Erro ao buscar categorias (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Busca todas as transações
  Future<List<Map<String, dynamic>>> getTransacoes() async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/transacoes/');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token inválido ou expirado');
      } else {
        throw Exception('Erro ao buscar transações (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Busca transações de uma conta específica
  Future<List<Map<String, dynamic>>> getTransacoesPorConta(String idConta) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/transacoes/?id_conta=$idConta');

      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Token inválido ou expirado');
      } else {
        throw Exception('Erro ao buscar transações (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===================== CRUD CONTAS =====================

  /// Cria uma nova conta
  Future<Map<String, dynamic>> createConta(
    String nome,
    double saldo,
    String tipo, {
    String? idUsuario,
  }) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/contas/');
      final bodyMap = <String, dynamic>{
        'nome': nome,
        'saldo_inicial': saldo,
        'tipo': tipo,
      };
      if (idUsuario != null && idUsuario.isNotEmpty) {
        bodyMap['id_usuario'] = idUsuario;
      }
      final body = jsonEncode(bodyMap);

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro ao criar conta (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Atualiza uma conta existente
  Future<Map<String, dynamic>> updateConta(String idConta, {String? nome, double? saldo, String? tipo}) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/contas/$idConta');
      final updateData = <String, dynamic>{};
      if (nome != null) updateData['nome'] = nome;
      if (saldo != null) updateData['saldo'] = saldo;
      if (tipo != null) updateData['tipo'] = tipo;

      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(updateData),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro ao atualizar conta (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Deleta uma conta
  Future<Map<String, dynamic>> deleteConta(String idConta) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/contas/$idConta');

      final response = await http
          .delete(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro ao deletar conta (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===================== CRUD TRANSAÇÕES =====================

  /// Cria uma nova transação
  Future<Map<String, dynamic>> createTransacao(String idConta, String idCategoria, double valor, String tipo, String? descricao, String data) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/transacoes/');
      final body = jsonEncode({
        'id_conta': idConta,
        'id_categoria': idCategoria,
        'valor': valor,
        'tipo': tipo,
        'descricao': descricao,
        'data': data,
      });

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro ao criar transação (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Atualiza uma transação existente
  Future<Map<String, dynamic>> updateTransacao(String idTransacao, {double? valor, String? tipo, String? descricao, String? data}) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/transacoes/$idTransacao');
      final updateData = <String, dynamic>{};
      if (valor != null) updateData['valor'] = valor;
      if (tipo != null) updateData['tipo'] = tipo;
      if (descricao != null) updateData['descricao'] = descricao;
      if (data != null) updateData['data'] = data;

      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(updateData),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro ao atualizar transação (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Deleta uma transação
  Future<Map<String, dynamic>> deleteTransacao(String idTransacao) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/transacoes/$idTransacao');

      final response = await http
          .delete(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro ao deletar transação (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===================== CRUD CATEGORIAS =====================

  /// Cria uma nova categoria
  Future<Map<String, dynamic>> createCategoria(
    String nome,
    String tipo, {
    String? idUsuario,
  }) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/categorias/');
      final bodyMap = <String, dynamic>{
        'nome': nome,
        'tipo': tipo,
      };
      if (idUsuario != null && idUsuario.isNotEmpty) {
        bodyMap['id_usuario'] = idUsuario;
      }
      final body = jsonEncode(bodyMap);

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro ao criar categoria (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Atualiza uma categoria existente
  Future<Map<String, dynamic>> updateCategoria(String idCategoria, {String? nome, String? tipo}) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/categorias/$idCategoria');
      final updateData = <String, dynamic>{};
      if (nome != null) updateData['nome'] = nome;
      if (tipo != null) updateData['tipo'] = tipo;

      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(updateData),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro ao atualizar categoria (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Deleta uma categoria
  Future<Map<String, dynamic>> deleteCategoria(String idCategoria) async {
    if (authToken == null) throw Exception('Não autenticado');

    try {
      final url = Uri.parse('$baseUrl/categorias/$idCategoria');

      final response = await http
          .delete(
            url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Erro ao deletar categoria (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cria novo usuário
  Future<Map<String, dynamic>> createUsuario({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/');
      print('👤 Criando novo usuário: $email');
      print('📍 URL: $url');

      final body = jsonEncode({
        'email': email,
        'senha': senha,
        'nome': nome,
      });

      print('📤 Enviando payload: $body');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Usuário criado com sucesso!');
        return data;
      } else if (response.statusCode == 409) {
        throw Exception('Email já cadastrado');
      } else {
        throw Exception(
            'Erro ao criar usuário (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao criar usuário: $e');
      rethrow;
    }
  }

  /// Faz logout
  void logout() {
    authToken = null;
    print('🚪 Logout realizado');
  }

  /// Verifica se está autenticado
  bool get isAuthenticated => authToken != null;
}
