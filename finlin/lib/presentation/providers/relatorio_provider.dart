import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transacao.dart';
import 'transacoes_provider_v2.dart';
import 'login_provider.dart';

/// Classe para armazenar dados de resumo do relatório
class ResumoRelatorio {
  final double totalEntrada;
  final double totalSaida;
  final List<Transacao> transacoes;

  ResumoRelatorio({
    required this.totalEntrada,
    required this.totalSaida,
    required this.transacoes,
  });

  double get saldo => totalEntrada - totalSaida;
}

/// Provider que calcula o resumo de um mês específico
/// Aceita (mes, ano) como parâmetros
final resumoMesProvider = FutureProvider.family<ResumoRelatorio, (int, int)>((
  ref,
  mesAno,
) async {
  final (mes, ano) = mesAno;

  // Observar estado de login
  final loginState = ref.watch(loginProvider);
  if (!loginState.isAuthenticated) {
    throw Exception('Usuário não autenticado');
  }

  // Obter todas as transações
  final transacoes = await ref.watch(transacoesProvider.future);

  // Filtrar transações do mês/ano
  final transacoesMes = transacoes.where((t) {
    return t.data.month == mes && t.data.year == ano;
  }).toList();

  // Calcular totais
  double totalEntrada = 0.0;
  double totalSaida = 0.0;

  for (final t in transacoesMes) {
    if (t.tipo == TipoTransacao.entrada) {
      totalEntrada += t.valor;
    } else {
      totalSaida += t.valor;
    }
  }

  return ResumoRelatorio(
    totalEntrada: totalEntrada,
    totalSaida: totalSaida,
    transacoes: transacoesMes,
  );
});

/// Provider que calcula o resumo de um mês específico para uma conta específica
final resumoMesContaProvider =
    FutureProvider.family<ResumoRelatorio, (int, int, String)>((
      ref,
      params,
    ) async {
      final (mes, ano, contaId) = params;

      // Observar estado de login
      final loginState = ref.watch(loginProvider);
      if (!loginState.isAuthenticated) {
        throw Exception('Usuário não autenticado');
      }

      // Obter todas as transações
      final transacoes = await ref.watch(transacoesProvider.future);

      // Filtrar transações do mês/ano/conta
      final transacoesMes = transacoes.where((t) {
        return t.contaId == contaId &&
            t.data.month == mes &&
            t.data.year == ano;
      }).toList();

      // Calcular totais
      double totalEntrada = 0.0;
      double totalSaida = 0.0;

      for (final t in transacoesMes) {
        if (t.tipo == TipoTransacao.entrada) {
          totalEntrada += t.valor;
        } else {
          totalSaida += t.valor;
        }
      }

      return ResumoRelatorio(
        totalEntrada: totalEntrada,
        totalSaida: totalSaida,
        transacoes: transacoesMes,
      );
    });
