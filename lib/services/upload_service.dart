import 'dart:typed_data';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class UploadSizeException implements Exception {
  final int maxBytes;
  final int actualBytes;

  UploadSizeException(this.maxBytes, this.actualBytes);

  @override
  String toString() {
    final maxKb = (maxBytes / 1024).round();
    final actualKb = (actualBytes / 1024).round();
    return 'A imagem ficou muito grande para o armazenamento. Tamanho máximo permitido: ${maxKb} KB. Tamanho atual: ${actualKb} KB. Considere reduzir a resolução.';
  }
}

class UploadService {
  static const int firestoreMaxImageBytes = 950000;
  static const int firestoreDocumentReserveBytes = 25000;
  static const int firestoreMaxBase64Bytes = firestoreMaxImageBytes - firestoreDocumentReserveBytes;
  static const int firestoreMaxRawBytesForDirectBase64 = 500000;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> uploadPost({
    required XFile imageFile,
    required String titulo,
    required String descricao,
    required List<String> tags,
    required List<String> cores,
    String visibilidade = 'public',
    bool useFirestoreOnly = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        message: 'Usuário não autenticado.',
      );
    }

    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw Exception('Não foi possível processar a imagem selecionada.');
    }

    final largura = decodedImage.width;
    final altura = decodedImage.height;

    final postRef = _firestore.collection('posts').doc();
    final postId = postRef.id;
    if (!useFirestoreOnly) {
      final extension = imageFile.path.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
      final storagePath = 'posts/${user.uid}/$postId';
      final originalRef = _storage.ref('$storagePath/original.$extension');
      final thumbRef = _storage.ref('$storagePath/thumb.jpg');

      await originalRef.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      final thumbImage = img.copyResize(decodedImage, width: 600);
      final thumbBytes = Uint8List.fromList(img.encodeJpg(thumbImage, quality: 75));

      await thumbRef.putData(
        thumbBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final imageUrl = await originalRef.getDownloadURL();
      final thumbUrl = await thumbRef.getDownloadURL();

      final normalizedTags = tags
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList();

      List<String> normalizedColors = cores
          .map((color) => color.trim())
          .where((color) => color.isNotEmpty)
          .toSet()
          .toList();

      if (normalizedColors.isEmpty) {
        normalizedColors = await extractColors(bytes);
      }

      final postData = {
        'uid': user.uid,
        'authorUid': user.uid,
        'titulo': titulo,
        'descricao': descricao,
        'imagemUrl': imageUrl,
        'thumbnail': thumbUrl,
        'cores': normalizedColors,
        'resolucao': {
          'largura': largura,
          'altura': altura,
        },
        'tags': normalizedTags,
        'curtidas': 0,
        'comentarios': 0,
        'dataCriacao': FieldValue.serverTimestamp(),
        'dataAtualizacao': FieldValue.serverTimestamp(),
        'visibilidade': visibilidade,
      };

      await postRef.set(postData);
      return;
    }

    final thumbImage = img.copyResize(decodedImage, width: 600);
    final thumbBytes = Uint8List.fromList(img.encodeJpg(thumbImage, quality: 60));
    final base64Thumb = base64Encode(thumbBytes);

    Uint8List bytesForPost = bytes;
    String base64Image = base64Encode(bytesForPost);

    if (bytesForPost.length > firestoreMaxRawBytesForDirectBase64 ||
        base64Image.length + base64Thumb.length > firestoreMaxBase64Bytes) {
      final resized = img.copyResize(decodedImage, width: 1024);
      List<int> jpg = img.encodeJpg(resized, quality: 70);
      base64Image = base64Encode(Uint8List.fromList(jpg));

      if (base64Image.length + base64Thumb.length > firestoreMaxBase64Bytes) {
        final smaller = img.copyResize(resized, width: 800);
        jpg = img.encodeJpg(smaller, quality: 60);
        base64Image = base64Encode(Uint8List.fromList(jpg));
      }

      if (base64Image.length + base64Thumb.length > firestoreMaxBase64Bytes) {
        final compact = img.copyResize(decodedImage, width: 600);
        jpg = img.encodeJpg(compact, quality: 50);
        base64Image = base64Encode(Uint8List.fromList(jpg));
      }

      if (base64Image.length + base64Thumb.length > firestoreMaxBase64Bytes) {
        throw UploadSizeException(firestoreMaxImageBytes, bytes.length);
      }

      bytesForPost = Uint8List.fromList(jpg);
    }

    final normalizedTags = tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();

    List<String> normalizedColors = cores
        .map((color) => color.trim())
        .where((color) => color.isNotEmpty)
        .toSet()
        .toList();

    if (normalizedColors.isEmpty) {
      normalizedColors = await extractColors(bytesForPost);
    }

    final postData = {
      'uid': user.uid,
      'authorUid': user.uid,
      'titulo': titulo,
      'descricao': descricao,
      'imagemUrl': '',
      'thumbnail': '',
      'imagemBase64': base64Image,
      'thumbnailBase64': base64Thumb,
      'cores': normalizedColors,
      'resolucao': {
        'largura': largura,
        'altura': altura,
      },
      'tags': normalizedTags,
      'curtidas': 0,
      'comentarios': 0,
      'dataCriacao': FieldValue.serverTimestamp(),
      'dataAtualizacao': FieldValue.serverTimestamp(),
      'visibilidade': visibilidade,
    };

    await postRef.set(postData);
  }

  Future<List<String>> extractColors(Uint8List imageBytes) async {
    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(imageBytes),
      maximumColorCount: 5,
    );

    return palette.colors
        .map((color) => '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}')
        .toList();
  }
}
