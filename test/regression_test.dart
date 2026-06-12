import 'package:flutter_test/flutter_test.dart';
import 'package:tilefetch/models/post_model.dart';

/// TESTE DE REGRESSÃO
///
/// Bug encontrado: Resolucao.fromMap não tratava corretamente o caso em que
/// os campos 'largura' e 'altura' vinham como String (ex: vindos de uma
/// fonte de dados externa ou de um documento Firestore mal formatado),
/// fazendo com que o app quebrasse ao tentar usar o valor como int.
///
/// Estratégia de regressão:
/// 1. Escrever um teste que reproduza o cenário do bug.
/// 2. Garantir que o teste passe com a implementação corrigida.
/// 3. Se o bug voltar a ocorrer em alterações futuras, este teste falhará
///    imediatamente, alertando a equipe.
void main() {
  group('Regressão - Resolucao.fromMap', () {
    test('não deve lançar exceção quando o mapa contém apenas chaves parciais', () {
      // Cenário do bug: documento salvo sem o campo "altura"
      final mapaIncompleto = {'largura': 48};

      expect(() => Resolucao.fromMap(mapaIncompleto), returnsNormally);

      final resultado = Resolucao.fromMap(mapaIncompleto);
      expect(resultado.largura, 48);
      // 'altura' ausente deve usar o valor padrão (64), não null ou erro
      expect(resultado.altura, 64);
    });

    test('não deve lançar exceção quando o mapa é completamente nulo/vazio', () {
      expect(() => Resolucao.fromMap({}), returnsNormally);

      final resultado = Resolucao.fromMap({});
      expect(resultado.largura, 64);
      expect(resultado.altura, 64);
    });

    test('label não deve gerar formato inválido com valores padrão', () {
      final resultado = Resolucao.fromMap({});
      expect(resultado.label, '64x64');
      expect(resultado.label, isNot(contains('null')));
    });
  });

  group('Regressão - Post.toMap / copyWith', () {
    test('copyWith não deve sobrescrever campos com null ao não informá-los', () {
      final original = Post(
        id: '1',
        uid: 'user1',
        titulo: 'Original',
        descricao: 'Descrição original',
        imagemUrl: 'url',
        thumbnail: 'thumb',
        cores: ['#000000'],
        resolucao: Resolucao(largura: 16, altura: 16),
        tags: ['tag1'],
        curtidas: 3,
        comentarios: 1,
        dataCriacao: DateTime(2024, 1, 1),
        dataAtualizacao: DateTime(2024, 1, 1),
        visibilidade: 'public',
      );

      // Bug anterior: copyWith() sem argumentos zerava campos como
      // 'tags' e 'cores' por engano.
      final copia = original.copyWith();

      expect(copia.tags, original.tags);
      expect(copia.cores, original.cores);
      expect(copia.titulo, original.titulo);
    });
  });
}
