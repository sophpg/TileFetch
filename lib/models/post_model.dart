import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid;
  final String? authorUid;
  final String titulo;
  final String descricao;
  final String imagemUrl;
  final String thumbnail;
  final String? imagemBase64;
  final String? thumbnailBase64;
  final List<String> cores;
  final Resolucao resolucao;
  final List<String> tags;
  final int curtidas;
  final int comentarios;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;
  final String visibilidade;
  final bool isLikedByMe;

  Post({
    required this.id,
    required this.uid,
    this.authorUid,
    required this.titulo,
    required this.descricao,
    required this.imagemUrl,
    required this.thumbnail,
    this.imagemBase64,
    this.thumbnailBase64,
    required this.cores,
    required this.resolucao,
    required this.tags,
    required this.curtidas,
    required this.comentarios,
    required this.dataCriacao,
    required this.dataAtualizacao,
    required this.visibilidade,
    this.isLikedByMe = false,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      uid: data['uid'] ?? '',
      titulo: data['titulo'] ?? 'Sem título',
      descricao: data['descricao'] ?? '',
      imagemUrl: data['imagemUrl'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      imagemBase64: data['imagemBase64'] as String?,
      thumbnailBase64: data['thumbnailBase64'] as String?,
      authorUid: data['authorUid'] as String?,
      cores: List<String>.from(data['cores'] ?? []),
      resolucao: Resolucao.fromMap(data['resolucao'] ?? {}),
      tags: List<String>.from(data['tags'] ?? []),
      curtidas: data['curtidas'] ?? 0,
      comentarios: data['comentarios'] ?? 0,
      dataCriacao: (data['dataCriacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataAtualizacao: (data['dataAtualizacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
      visibilidade: data['visibilidade'] ?? 'public',
      isLikedByMe: data['isLikedByMe'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'titulo': titulo,
      'descricao': descricao,
      'imagemUrl': imagemUrl,
      'thumbnail': thumbnail,
      'imagemBase64': imagemBase64,
      'thumbnailBase64': thumbnailBase64,
      'authorUid': authorUid,
      'cores': cores,
      'resolucao': resolucao.toMap(),
      'tags': tags,
      'curtidas': curtidas,
      'comentarios': comentarios,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'dataAtualizacao': Timestamp.fromDate(dataAtualizacao),
      'visibilidade': visibilidade,
    };
  }

  Post copyWith({
    String? id,
    String? uid,
    String? authorUid,
    String? titulo,
    String? descricao,
    String? imagemUrl,
    String? thumbnail,
    String? imagemBase64,
    String? thumbnailBase64,
    List<String>? cores,
    Resolucao? resolucao,
    List<String>? tags,
    int? curtidas,
    int? comentarios,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    String? visibilidade,
    bool? isLikedByMe,
  }) {
    return Post(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      authorUid: authorUid ?? this.authorUid,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      imagemBase64: imagemBase64 ?? this.imagemBase64,
      thumbnailBase64: thumbnailBase64 ?? this.thumbnailBase64,
      cores: cores ?? this.cores,
      resolucao: resolucao ?? this.resolucao,
      tags: tags ?? this.tags,
      curtidas: curtidas ?? this.curtidas,
      comentarios: comentarios ?? this.comentarios,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      visibilidade: visibilidade ?? this.visibilidade,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

class Resolucao {
  final int largura;
  final int altura;

  Resolucao({
    required this.largura,
    required this.altura,
  });

  factory Resolucao.fromMap(Map<String, dynamic> map) {
    return Resolucao(
      largura: map['largura'] ?? 64,
      altura: map['altura'] ?? 64,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'largura': largura,
      'altura': altura,
    };
  }

  String get label => '${largura}x$altura';

  @override
  String toString() => label;
}
