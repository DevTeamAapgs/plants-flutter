// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_plants_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataAdapter extends TypeAdapter<Data> {
  @override
  final int typeId = 0;

  @override
  Data read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Data(
      cursor: fields[0] as String?,
      changes: (fields[1] as List?)?.cast<Changes>(),
    );
  }

  @override
  void write(BinaryWriter writer, Data obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cursor)
      ..writeByte(1)
      ..write(obj.changes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChangesAdapter extends TypeAdapter<Changes> {
  @override
  final int typeId = 1;

  @override
  Changes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Changes(
      sId: fields[0] as String?,
      speciesType: fields[1] as String?,
      botanicalName: fields[2] as String?,
      fkFamilyId: fields[3] as String?,
      fkHabitId: fields[4] as String?,
      languages: (fields[5] as List?)?.cast<Languages>(),
      isEndangeredSpecies: fields[6] as bool?,
      isDeleted: fields[7] as bool?,
      images: (fields[8] as List?)?.cast<String>(),
      createdAt: fields[9] as String?,
      updatedAt: fields[10] as String?,
      familyName: fields[12] as String?,
      habitName: fields[13] as dynamic,
      fkSectorId: (fields[14] as List?)?.cast<String>(),
      sectorNames: (fields[15] as List?)?.cast<String>(),
      cachedImages: (fields[11] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Changes obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.sId)
      ..writeByte(1)
      ..write(obj.speciesType)
      ..writeByte(2)
      ..write(obj.botanicalName)
      ..writeByte(3)
      ..write(obj.fkFamilyId)
      ..writeByte(4)
      ..write(obj.fkHabitId)
      ..writeByte(5)
      ..write(obj.languages)
      ..writeByte(6)
      ..write(obj.isEndangeredSpecies)
      ..writeByte(7)
      ..write(obj.isDeleted)
      ..writeByte(8)
      ..write(obj.images)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.cachedImages)
      ..writeByte(12)
      ..write(obj.familyName)
      ..writeByte(13)
      ..write(obj.habitName)
      ..writeByte(14)
      ..write(obj.fkSectorId)
      ..writeByte(15)
      ..write(obj.sectorNames);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LanguagesAdapter extends TypeAdapter<Languages> {
  @override
  final int typeId = 2;

  @override
  Languages read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Languages(
      fkLanguageId: fields[0] as String?,
      name: fields[1] as String?,
      langCode: fields[2] as String?,
      text: fields[3] as String?,
      habitat: fields[4] as String?,
      description: fields[5] as String?,
      religiousSignificance: fields[6] as String?,
      distribution: fields[7] as String?,
      partUsed: fields[8] as String?,
      medicinalUsed: fields[9] as String?,
      otherUsed: fields[10] as String?,
      culinaryPurpose: fields[11] as String?,
      propagation: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Languages obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.fkLanguageId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.langCode)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.habitat)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.religiousSignificance)
      ..writeByte(7)
      ..write(obj.distribution)
      ..writeByte(8)
      ..write(obj.partUsed)
      ..writeByte(9)
      ..write(obj.medicinalUsed)
      ..writeByte(10)
      ..write(obj.otherUsed)
      ..writeByte(11)
      ..write(obj.culinaryPurpose)
      ..writeByte(12)
      ..write(obj.propagation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
