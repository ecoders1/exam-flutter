// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_model.dart';

class ResultModelAdapter extends TypeAdapter<ResultModel> {
  @override
  final int typeId = 5;

  @override
  ResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResultModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      examId: fields[2] as String,
      totalQuestions: fields[3] as int,
      correctAnswers: fields[4] as int,
      wrongAnswers: fields[5] as int,
      scorePercent: fields[6] as double,
      passed: fields[7] as bool,
      timeUsedSeconds: fields[8] as int,
      completedAt: fields[9] as DateTime,
      answers: (fields[10] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ResultModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.examId)
      ..writeByte(3)..write(obj.totalQuestions)
      ..writeByte(4)..write(obj.correctAnswers)
      ..writeByte(5)..write(obj.wrongAnswers)
      ..writeByte(6)..write(obj.scorePercent)
      ..writeByte(7)..write(obj.passed)
      ..writeByte(8)..write(obj.timeUsedSeconds)
      ..writeByte(9)..write(obj.completedAt)
      ..writeByte(10)..write(obj.answers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
