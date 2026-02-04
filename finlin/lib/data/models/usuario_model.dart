import '../../domain/entities/usuario.dart';

/// Model de Usuario para mapeamento de dados
///
/// Responsável por converter dados JSON da API em Entidades de Domínio.
class UsuarioModel extends Usuario {
  UsuarioModel({
    required String id,
    required String nome,
    required String email,
  }) : super(id: id, nome: nome, email: email);

  /// Factory para criar UsuarioModel a partir de JSON da API
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id_usuario']?.toString() ?? json['id'].toString() ?? '',
      nome: json['nome'] as String? ?? 'Usuário',
      email: json['email'] as String? ?? '',
    );
  }

  /// Converte o Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'id_usuario': id,
      'nome': nome,
      'email': email,
    };
  }

  /// Cria uma cópia do UsuarioModel com valores opcionais substituídos
  @override
  UsuarioModel copyWith({String? id, String? nome, String? email}) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
    );
  }
}
