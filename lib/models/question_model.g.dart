// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

class QuestionModelAdapter extends TypeAdapter<QuestionModel> {
  @override
  final int typeId = 3;

  @override
  QuestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionModel(
      id: fields[0] as String,
      examId: fields[1] as String,
      questionText: fields[2] as String,
      optionA: fields[3] as String,
      optionB: fields[4] as String,
      optionC: fields[5] as String,
      optionD: fields[6] as String,
      correctOption: fields[7] as String,
      explanation: fields[8] as String?,
      orderIndex: fields[9] as int,
      imageUrl: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.examId)
      ..writeByte(2)..write(obj.questionText)
      ..writeByte(3)..write(obj.optionA)
      ..writeByte(4)..write(obj.optionB)
      ..writeByte(5)..write(obj.optionC)
      ..writeByte(6)..write(obj.optionD)
      ..writeByte(7)..write(obj.correctOption)
      ..writeByte(8)..write(obj.explanation)
      ..writeByte(9)..write(obj.orderIndex)
      ..writeByte(10)..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
