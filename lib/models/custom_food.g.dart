// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_food.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomFoodAdapter extends TypeAdapter<CustomFood> {
  @override
  final int typeId = 5;

  @override
  CustomFood read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomFood(
      name: fields[0] as String,
      calories: fields[1] as double,
      protein: fields[2] as double,
      fat: fields[3] as double,
      carbs: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CustomFood obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.protein)
      ..writeByte(3)
      ..write(obj.fat)
      ..writeByte(4)
      ..write(obj.carbs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomFoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
