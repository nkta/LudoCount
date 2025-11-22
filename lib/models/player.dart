import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  Player({required this.id, required this.name});
}
