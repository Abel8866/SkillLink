import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageValidationException implements Exception {
  const ImageValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ImageUploadService {
  ImageUploadService._();

  static final instance = ImageUploadService._();
  static const maxBytes = 5 * 1024 * 1024;

  final _picker = ImagePicker();
  FirebaseStorage get _storage => FirebaseStorage.instance;

  Future<XFile?> pickImage(ImageSource source) {
    return _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 88,
    );
  }

  Future<Uint8List> validate(XFile file) async {
    final extension = file.name.toLowerCase().split('.').last;
    if (!{'jpg', 'jpeg', 'png'}.contains(extension)) {
      throw const ImageValidationException(
        'Please choose a JPEG or PNG image.',
      );
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) {
      throw const ImageValidationException(
        'That image is larger than 5 MB. Please choose a smaller image.',
      );
    }
    if (bytes.isEmpty) {
      throw const ImageValidationException('The selected image is empty.');
    }
    return bytes;
  }

  Future<String> upload({
    required XFile file,
    required String path,
    void Function(double progress)? onProgress,
  }) async {
    final bytes = await validate(file);
    final extension = file.name.toLowerCase().split('.').last;
    final contentType = extension == 'png' ? 'image/png' : 'image/jpeg';
    final reference = _storage.ref(path);
    final task = reference.putData(
      bytes,
      SettableMetadata(
        contentType: contentType,
        cacheControl: 'public,max-age=3600',
      ),
    );
    task.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });
    await task;
    return reference.getDownloadURL();
  }

  Future<void> deleteIfPresent(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }
}
