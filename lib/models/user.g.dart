// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      name: fields[0] as String,
      age: fields[1] as int,
      gender: fields[2] as String,
      height: fields[3] as double,
      currentWeight: fields[4] as double,
      goalWeight: fields[5] as double,
      goal: fields[6] as String,
      activityLevel: fields[7] as String,
      dailyCalories: fields[8] as double,
      dailyProtein: fields[9] as double,
      dailyFat: fields[10] as double,
      dailyCarbs: fields[11] as double,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.currentWeight)
      ..writeByte(5)
      ..write(obj.goalWeight)
      ..writeByte(6)
      ..write(obj.goal)
      ..writeByte(7)
      ..write(obj.activityLevel)
      ..writeByte(8)
      ..write(obj.dailyCalories)
      ..writeByte(9)
      ..write(obj.dailyProtein)
      ..writeByte(10)
      ..write(obj.dailyFat)
      ..writeByte(11)
      ..write(obj.dailyCarbs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
