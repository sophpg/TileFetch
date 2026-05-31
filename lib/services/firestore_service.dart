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

  Future<bool> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final likeRef = _firestore.collection('curtidas').doc('$postId-$userId');

      await _firestore.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) return;
        final post = Post.fromFirestore(postSnapshot);

        final likeSnapshot = await transaction.get(likeRef);

        if (likeSnapshot.exists) {
          transaction.update(postRef, {
            'curtidas': (post.curtidas - 1).clamp(0, 999999),
            'dataAtualizacao': FieldValue.serverTimestamp(),
          });
          transaction.delete(likeRef);
        } else {
          transaction.update(postRef, {
            'curtidas': post.curtidas + 1,
            'dataAtualizacao': FieldValue.serverTimestamp(),
          });
          transaction.set(likeRef, {
            'postId': postId,
            'usuarioId': userId,
            'dataCurtida': FieldValue.serverTimestamp(),
          });
        }
      });

      return true;
    } catch (e) {
      print('Erro ao curtir post: $e');
      return false;
    }
  }

  Future<bool> isPostLikedByUser(String postId, String userId) async {
    try {
      final doc = await _firestore.collection('curtidas').doc('$postId-$userId').get();
      return doc.exists;
    } catch (e) {
      print('Erro ao verificar curtida: $e');
      return false;
    }
  }

  Future<List<String>> getUserLikedPostIds(String userId) async {
    try {
      final snapshot = await _firestore.collection('curtidas').where('usuarioId', isEqualTo: userId).get();
      return snapshot.docs.map((d) => (d.data()['postId'] as String)).toList();
    } catch (e) {
      print('Erro ao buscar curtidas do usuário: $e');
      return [];
    }
  }

  Future<List<Post>> getUserLikedPosts(String userId) async {
    try {
      final likedIds = await getUserLikedPostIds(userId);
      if (likedIds.isEmpty) return [];

      // Firestore 'in' query is limited to 10-30 items depending on version.
      // For now, let's fetch them and filter if there are many, or just do multiple queries.
      // To keep it simple and handle more than 10, we can fetch all and filter or chunk.
      
      List<Post> likedPosts = [];
      
      // Chunking by 10
      for (var i = 0; i < likedIds.length; i += 10) {
        final chunk = likedIds.sublist(i, i + 10 > likedIds.length ? likedIds.length : i + 10);
        final snapshot = await _firestore
            .collection('posts')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        
        likedPosts.addAll(snapshot.docs.map((doc) => Post.fromFirestore(doc).copyWith(isLikedByMe: true)));
      }

      // Sort by creation date if needed
      likedPosts.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));

      return likedPosts;
    } catch (e) {
      print('Erro ao buscar posts curtidos: $e');
      return [];
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

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Erro ao buscar perfil do usuário: $e');
      return null;
    }
  }

  Future<void> saveSearchQuery(String userId, String query) async {
    try {
      final historyRef = _firestore.collection('users').doc(userId).collection('search_history');
      final q = query.trim();
      if (q.isEmpty) return;

      final existing = await historyRef.where('query', isEqualTo: q).get();
      for (var doc in existing.docs) {
        await doc.reference.delete();
      }

      await historyRef.add({
        'query': q,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final snapshot = await historyRef.orderBy('timestamp', descending: true).get();
      if (snapshot.docs.length > 5) {
        for (var i = 5; i < snapshot.docs.length; i++) {
          await snapshot.docs[i].reference.delete();
        }
      }
    } catch (e) {
      print('Erro ao salvar histórico: $e');
    }
  }

  Future<List<String>> getSearchHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_history')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()['query'] as String).toList();
    } catch (e) {
      print('Erro ao buscar histórico: $e');
      return [];
    }
  }

  Future<void> clearSearchHistory(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).collection('search_history').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Erro ao limpar histórico: $e');
    }
  }
}
