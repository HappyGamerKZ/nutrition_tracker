// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutPlanEntryAdapter extends TypeAdapter<WorkoutPlanEntry> {
  @override
  final int typeId = 3;

  @override
  WorkoutPlanEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutPlanEntry(
      exercise: fields[0] as Exercise,
      date: fields[1] as DateTime,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutPlanEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.exercise)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutPlanEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
