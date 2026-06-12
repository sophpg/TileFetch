import 'package:flutter_test/flutter_test.dart';
import 'package:tilefetch/models/post_model.dart';

void main() {
  group('Resolucao', () {
    test('fromMap usa valores padrão quando o mapa está vazio', () {
      final r = Resolucao.fromMap({});
      expect(r.largura, 64);
      expect(r.altura, 64);
    });

    test('fromMap lê valores informados corretamente', () {
      final r = Resolucao.fromMap({'largura': 32, 'altura': 16});
      expect(r.largura, 32);
      expect(r.altura, 16);
    });

    test('toMap converte os valores corretamente', () {
      final r = Resolucao(largura: 16, altura: 16);
      expect(r.toMap(), {'largura': 16, 'altura': 16});
    });

    test('label retorna o formato "LxA"', () {
      final r = Resolucao(largura: 32, altura: 32);
      expect(r.label, '32x32');
    });

    test('toString retorna o mesmo valor de label', () {
      final r = Resolucao(largura: 64, altura: 128);
      expect(r.toString(), r.label);
      expect(r.toString(), '64x128');
    });
  });

  group('Post', () {
    Post buildPost({
      List<String>? tags,
      List<String>? cores,
      int curtidas = 0,
      String visibilidade = 'public',
    }) {
      final now = DateTime(2024, 1, 1);
      return Post(
        id: '1',
        uid: 'user1',
        titulo: 'Título de teste',
        descricao: 'Descrição de teste',
        imagemUrl: 'http://exemplo.com/img.png',
        thumbnail: 'http://exemplo.com/thumb.png',
        cores: cores ?? ['#FFFFFF'],
        resolucao: Resolucao(largura: 32, altura: 32),
        tags: tags ?? ['pixelart'],
        curtidas: curtidas,
        comentarios: 0,
        dataCriacao: now,
        dataAtualizacao: now,
        visibilidade: visibilidade,
      );
    }

    test('toMap inclui todos os campos esperados', () {
      final post = buildPost();
      final map = post.toMap();

      expect(map['uid'], 'user1');
      expect(map['titulo'], 'Título de teste');
      expect(map['descricao'], 'Descrição de teste');
      expect(map['cores'], ['#FFFFFF']);
      expect(map['tags'], ['pixelart']);
      expect(map['visibilidade'], 'public');
      expect(map['resolucao'], {'largura': 32, 'altura': 32});
    });

    test('copyWith mantém valores originais quando nada é alterado', () {
      final post = buildPost();
      final copia = post.copyWith();

      expect(copia.id, post.id);
      expect(copia.titulo, post.titulo);
      expect(copia.curtidas, post.curtidas);
      expect(copia.tags, post.tags);
    });

    test('copyWith altera apenas os campos especificados', () {
      final post = buildPost(curtidas: 5);
      final copia = post.copyWith(titulo: 'Novo título', curtidas: 10);

      expect(copia.titulo, 'Novo título');
      expect(copia.curtidas, 10);
      // Campos não alterados permanecem iguais
      expect(copia.descricao, post.descricao);
      expect(copia.uid, post.uid);
    });

    test('isLikedByMe tem valor padrão false', () {
      final post = buildPost();
      expect(post.isLikedByMe, false);
    });
  });
}
