import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_link/services/image_upload_service.dart';

void main() {
  test('image validation rejects unsupported file types', () async {
    final file = XFile.fromData(
      Uint8List.fromList([1, 2, 3]),
      name: 'document.pdf',
    );

    await expectLater(
      ImageUploadService.instance.validate(file),
      throwsA(isA<ImageValidationException>()),
    );
  });

  test('image validation rejects files larger than 5 MB', () async {
    final file = XFile.fromData(
      Uint8List(ImageUploadService.maxBytes + 1),
      name: 'large.jpg',
    );

    await expectLater(
      ImageUploadService.instance.validate(file),
      throwsA(isA<ImageValidationException>()),
    );
  });
}
