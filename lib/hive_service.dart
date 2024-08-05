import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Box? _noteBox;

  static Future<void> init() async {
    // Initialize Hive for web
    await Hive.initFlutter(); // Init Hive for web (no directory needed)
    _noteBox = await Hive.openBox('notes');
  }

  static Box get noteBox {
    if (_noteBox == null) {
      throw Exception('HiveService is not initialized. Call init() first.');
    }
    return _noteBox!;
  }
}
