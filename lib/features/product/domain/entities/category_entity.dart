import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String categoryId;
  final String name;
  final String? image;
  final String? description;

  const CategoryEntity({
    required this.categoryId,
    required this.name,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [categoryId, name, image, description];
}
