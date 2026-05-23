import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Post>> fetchPostsHome({
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .where('visibilidade', isEqualTo: 'public')
          .orderBy('dataCriacao', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar posts: $e');
      return [];
    }
  }

  Future<List<Post>> searchPosts(String query) async {
    try {
      if (query.isEmpty) {
        return fetchPostsHome();
      }

      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .where('visibilidade', isEqualTo: 'public')
          .orderBy('dataCriacao', descending: true)
          .get();

      final lowerQuery = query.toLowerCase();

      return snapshot.docs
          .map((doc) => Post.fromFirestore(doc))
          .where((post) =>
              post.titulo.toLowerCase().contains(lowerQuery) ||
              post.descricao.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      print('Erro ao buscar posts: $e');
      return [];
    }
  }

  Future<List<Post>> filterPostsByColor(
    String color, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .where('visibilidade', isEqualTo: 'public')
          .where('cores', arrayContains: color)
          .orderBy('dataCriacao', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao filtrar por cor: $e');
      return [];
    }
  }

  Future<List<Post>> filterPostsByResolution(
    int largura,
    int altura, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .where('visibilidade', isEqualTo: 'public')
          .orderBy('dataCriacao', descending: true)
          .get();

      final filtered = snapshot.docs
          .map((doc) => Post.fromFirestore(doc))
          .where((post) =>
              post.resolucao.largura == largura &&
              post.resolucao.altura == altura)
          .toList();

      if (lastDoc != null) {
        final lastIndex =
            filtered.indexWhere((post) => post.id == (lastDoc.id));
        if (lastIndex != -1 && lastIndex + limit < filtered.length) {
          return filtered.sublist(lastIndex + 1, lastIndex + 1 + limit);
        }
      }

      return filtered.take(limit).toList();
    } catch (e) {
      print('Erro ao filtrar por resolução: $e');
      return [];
    }
  }

  Future<List<Post>> filterPostsByTag(
    String tag, {
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .where('visibilidade', isEqualTo: 'public')
          .where('tags', arrayContains: tag)
          .orderBy('dataCriacao', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao filtrar por tag: $e');
      return [];
    }
  }

  Future<List<Post>> getPopularPosts({
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .where('visibilidade', isEqualTo: 'public')
          .orderBy('curtidas', descending: true)
          .orderBy('dataCriacao', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar posts populares: $e');
      return [];
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      DocumentReference postRef = _firestore.collection('posts').doc(postId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
        Post post = Post.fromFirestore(postSnapshot);

        int newLikes = post.curtidas;
        if (post.isLikedByMe) {
          newLikes--;
        } else {
          newLikes++;
        }

        transaction.update(postRef, {'curtidas': newLikes});

        await _firestore
            .collection('curtidas')
            .doc('$postId-$userId')
            .set({
          'postId': postId,
          'usuarioId': userId,
          'dataCurtida': FieldValue.serverTimestamp(),
        }).catchError((_) {
          transaction.delete(
              _firestore.collection('curtidas').doc('$postId-$userId'));
        });
      });
    } catch (e) {
      print('Erro ao curtir post: $e');
    }
  }

  Future<List<String>> getAllColors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .where('visibilidade', isEqualTo: 'public')
          .get();

      Set<String> colors = {};
      for (var doc in snapshot.docs) {
        final post = Post.fromFirestore(doc);
        colors.addAll(post.cores);
      }

      return colors.toList();
    } catch (e) {
      print('Erro ao buscar cores: $e');
      return [];
    }
  }

  Future<List<String>> getAllTags() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .where('visibilidade', isEqualTo: 'public')
          .get();

      Set<String> tags = {};
      for (var doc in snapshot.docs) {
        final post = Post.fromFirestore(doc);
        tags.addAll(post.tags);
      }

      return tags.toList();
    } catch (e) {
      print('Erro ao buscar tags: $e');
      return [];
    }
  }

  Future<List<Resolucao>> getAllResolutions() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .where('visibilidade', isEqualTo: 'public')
          .get();

      Set<String> resolutions = {};
      for (var doc in snapshot.docs) {
        final post = Post.fromFirestore(doc);
        resolutions.add(post.resolucao.label);
      }

      return resolutions
          .map((r) {
            final parts = r.split('x');
            return Resolucao(
              largura: int.parse(parts[0]),
              altura: int.parse(parts[1]),
            );
          })
          .toList()
        ..sort((a, b) => a.largura.compareTo(b.largura));
    } catch (e) {
      print('Erro ao buscar resoluções: $e');
      return [];
    }
  }
}
