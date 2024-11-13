// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rapid_pass.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RapidPassAdapter extends TypeAdapter<RapidPass> {
  @override
  final int typeId = 0;

  @override
  RapidPass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RapidPass(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RapidPass obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RapidPassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RapidPassDataAdapter extends TypeAdapter<RapidPassData> {
  @override
  final int typeId = 1;

  @override
  RapidPassData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RapidPassData(
      balance: (fields[0] as num).toInt(),
      lastUpdated: fields[1] as DateTime,
      isActive: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RapidPassData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.balance)
      ..writeByte(1)
      ..write(obj.lastUpdated)
      ..writeByte(2)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RapidPassDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
