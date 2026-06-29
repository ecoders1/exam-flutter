// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_model.dart';

class DepartmentModelAdapter extends TypeAdapter<DepartmentModel> {
  @override
  final int typeId = 1;

  @override
  DepartmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DepartmentModel(
      id: fields[0] as String,
      name: fields[1] as String,
      year: fields[2] as String,
      description: fields[3] as String?,
      iconUrl: fields[4] as String?,
      price: fields[5] as double,
      isDefault: fields[6] as bool,
      examCount: fields[7] as int,
      createdAt: fields[8] as DateTime,
      isActive: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DepartmentModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.year)
      ..writeByte(3)..write(obj.description)
      ..writeByte(4)..write(obj.iconUrl)
      ..writeByte(5)..write(obj.price)
      ..writeByte(6)..write(obj.isDefault)
      ..writeByte(7)..write(obj.examCount)
      ..writeByte(8)..write(obj.createdAt)
      ..writeByte(9)..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
