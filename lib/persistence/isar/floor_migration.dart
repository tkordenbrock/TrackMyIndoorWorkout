import 'package:isar/isar.dart';

part 'floor_migration.g.dart';

@Collection(inheritance: false)
class FloorMigration {
  Id id;
  final String entityName;
  @Index(composite: [CompositeIndex('entityName')])
  final int floorId;
  final int isarId;

  FloorMigration({
    this.id = Isar.autoIncrement,
    required this.entityName,
    required this.floorId,
    required this.isarId,
  });
}
