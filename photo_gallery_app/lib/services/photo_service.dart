import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/photo_model.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();
  static const String _photosFileName = 'photos.json';

  // Lấy thư mục lưu trữ ảnh
  Future<Directory> get _photoDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/photos');
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }
    return photoDir;
  }

  // Chụp ảnh từ camera
  Future<PhotoModel?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _savePhoto(image);
    } catch (e) {
      print('Lỗi khi chụp ảnh: $e');
      return null;
    }
  }

  // Chọn ảnh từ thư viện
  Future<PhotoModel?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _savePhoto(image);
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
      return null;
    }
  }

  // Lưu ảnh vào thư mục app
  Future<PhotoModel> _savePhoto(XFile image) async {
    final photoDir = await _photoDirectory;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = path.join(photoDir.path, fileName);

    await File(image.path).copy(savedPath);

    return PhotoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: savedPath,
      dateTaken: DateTime.now(),
    );
  }

  // Lưu danh sách ảnh vào file JSON
  Future<void> savePhotos(List<PhotoModel> photos) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_photosFileName');
      final jsonList = photos.map((p) => p.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Lỗi khi lưu danh sách ảnh: $e');
    }
  }

  // Đọc danh sách ảnh từ file JSON
  Future<List<PhotoModel>> loadPhotos() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_photosFileName');

      if (!await file.exists()) return [];

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => PhotoModel.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi đọc danh sách ảnh: $e');
      return [];
    }
  }

  // Xóa ảnh
  Future<void> deletePhoto(PhotoModel photo) async {
    try {
      final file = File(photo.path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Lỗi khi xóa ảnh: $e');
    }
  }
}