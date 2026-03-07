// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductHiveModelAdapter extends TypeAdapter<ProductHiveModel> {
  @override
  final int typeId = 10;

  @override
  ProductHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      price: fields[3] as double,
      productImage: fields[4] as String?,
      storeId: fields[5] as String?,
      storeName: fields[6] as String?,
      categoryId: fields[7] as String?,
      categoryName: fields[8] as String?,
      subcategoryId: fields[9] as String?,
      subcategoryName: fields[10] as String?,
      stock: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductHiveModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.productImage)
      ..writeByte(5)
      ..write(obj.storeId)
      ..writeByte(6)
      ..write(obj.storeName)
      ..writeByte(7)
      ..write(obj.categoryId)
      ..writeByte(8)
      ..write(obj.categoryName)
      ..writeByte(9)
      ..write(obj.subcategoryId)
      ..writeByte(10)
      ..write(obj.subcategoryName)
      ..writeByte(11)
      ..write(obj.stock);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
