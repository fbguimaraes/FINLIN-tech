import '../../domain/entities/transacao.dart';
import '../../domain/repositories/transacao_repository.dart';
import '../datasources/transacao_remote_datasource.dart';

/// Implementação do TransacaoRepository
///
/// Faz a mediação entre o datasource e o domínio.
class TransacaoRepositoryImpl implements TransacaoRepository {
  final TransacaoRemoteDataSource remoteDataSource;

  TransacaoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Transacao>> getTransacoes() async {
    try {
      // TODO: Recuperar token armazenado localmente
      return await remoteDataSource.getTransacoes('dummy_token');
    } catch (e) {
      throw Exception('Erro ao buscar transações: $e');
    }
  }

  @override
  Future<List<Transacao>> getTransacoesPorConta(String contaId) async {
    try {
      return await remoteDataSource.getTransacoesPorConta(
        contaId,
        'dummy_token',
      );
    } catch (e) {
      throw Exception('Erro ao buscar transações da conta: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getRelatorioMensal(int mes, int ano) async {
    try {
      // TODO: Implementar endpoint de relatório na API
      return {'mes': mes, 'ano': ano, 'totalEntrada': 0.0, 'totalSaida': 0.0};
    } catch (e) {
      throw Exception('Erro ao buscar relatório: $e');
    }
  }

  @override
  Future<Transacao> criar(Transacao transacao) async {
    try {
      return await remoteDataSource.criar(
        descricao: transacao.descricao,
        valor: transacao.valor,
        tipo: transacao.tipo == transacao.tipo ? 'receita' : 'despesa',
        contaId: transacao.contaId,
        categoriaId: transacao.categoriaId,
        dataTransacao: transacao.data,
        token: 'dummy_token',
      );
    } catch (e) {
      throw Exception('Erro ao criar transação: $e');
    }
  }

  @override
  Future<void> deletar(String id) async {
    try {
      return await remoteDataSource.deletar(id, 'dummy_token');
    } catch (e) {
      throw Exception('Erro ao deletar transação: $e');
    }
  }
}
