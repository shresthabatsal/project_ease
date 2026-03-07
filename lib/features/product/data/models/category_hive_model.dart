import 'package:hive/hive.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: 11)
class CategoryHiveModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? image;
  @HiveField(3)
  final String? description;

  CategoryHiveModel({
    required this.id,
    required this.name,
    this.image,
    this.description,
  });
}
