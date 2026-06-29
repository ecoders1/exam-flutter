// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 4;

  @override
  PaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      departmentId: fields[2] as String,
      amount: fields[3] as double,
      method: fields[4] as String,
      screenshotUrl: fields[5] as String?,
      statusString: fields[6] as String,
      createdAt: fields[7] as DateTime,
      approvedAt: fields[8] as DateTime?,
      adminNote: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.departmentId)
      ..writeByte(3)..write(obj.amount)
      ..writeByte(4)..write(obj.method)
      ..writeByte(5)..write(obj.screenshotUrl)
      ..writeByte(6)..write(obj.statusString)
      ..writeByte(7)..write(obj.createdAt)
      ..writeByte(8)..write(obj.approvedAt)
      ..writeByte(9)..write(obj.adminNote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
