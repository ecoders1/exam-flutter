// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

class ExamModelAdapter extends TypeAdapter<ExamModel> {
  @override
  final int typeId = 2;

  @override
  ExamModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamModel(
      id: fields[0] as String,
      title: fields[1] as String,
      departmentId: fields[2] as String,
      description: fields[3] as String?,
      questionCount: fields[4] as int,
      durationMinutes: fields[5] as int,
      createdAt: fields[6] as DateTime,
      sourceFileUrl: fields[7] as String?,
      sourceFileType: fields[8] as String?,
      isPublished: fields[9] as bool,
      passMarkPercent: fields[10] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ExamModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.departmentId)
      ..writeByte(3)..write(obj.description)
      ..writeByte(4)..write(obj.questionCount)
      ..writeByte(5)..write(obj.durationMinutes)
      ..writeByte(6)..write(obj.createdAt)
      ..writeByte(7)..write(obj.sourceFileUrl)
      ..writeByte(8)..write(obj.sourceFileType)
      ..writeByte(9)..write(obj.isPublished)
      ..writeByte(10)..write(obj.passMarkPercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
