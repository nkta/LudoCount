import 'dart:convert';
import 'dart:io';
import '../models/game_preset.dart';

class PresetShareService {
  static String encodePreset(GamePreset preset) {
    final jsonMap = preset.toJson();
    final jsonString = jsonEncode(jsonMap);
    final bytes = utf8.encode(jsonString);
    final compressed = gzip.encode(bytes);
    return base64Encode(compressed);
  }

  static GamePreset decodePreset(String code) {
    try {
      final compressed = base64Decode(code);
      final bytes = gzip.decode(compressed);
      final jsonString = utf8.decode(bytes);
      final jsonMap = jsonDecode(jsonString);
      return GamePreset.fromJson(jsonMap);
    } catch (e) {
      throw const FormatException('Code preset invalide');
    }
  }
}
