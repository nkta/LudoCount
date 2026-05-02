import 'dart:convert';
import 'dart:io';
import '../models/game_preset.dart';

class PresetShareService {
  static String encodePreset(GamePreset preset) {
    final jsonString = jsonEncode(preset.toJson());
    final compressed = gzip.encode(utf8.encode(jsonString));
    return base64Encode(compressed);
  }

  static GamePreset decodePreset(String code) {
    try {
      final bytes = gzip.decode(base64Decode(code));
      return GamePreset.fromJson(jsonDecode(utf8.decode(bytes)));
    } catch (e) {
      throw const FormatException('Code preset invalide');
    }
  }
}
