import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/network/api_base_helper.dart';
import 'package:arumbu/network/request_type.dart';
part 'sync_plants_response.g.dart';

class SyncPlantsResponse {
  bool? success;
  String? message;
  Data? data;

  SyncPlantsResponse({this.success, this.message, this.data});

  SyncPlantsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }

  static Future<SyncPlantsResponse> getSyncPlants(
    BuildContext ctx, {
    dynamic body,
  }) async {
    try {
      if (kDebugMode) {
        print(body);
      }
      ApiBaseHelper helper = ApiBaseHelper(ctx);
      final responseData = await helper.callAPI(
        URLs.syncPlants,
        RequestType.GET,
      );

      return SyncPlantsResponse.fromJson(responseData);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }
}

@HiveType(typeId: 0)
class Data {
  @HiveField(0)
  String? cursor;
  @HiveField(1)
  List<Changes>? changes;

  Data({this.cursor, this.changes});

  Data.fromJson(Map<String, dynamic> json) {
    cursor = json['cursor'];
    if (json['changes'] != null) {
      changes = <Changes>[];
      json['changes'].forEach((v) {
        changes!.add(new Changes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cursor'] = this.cursor;
    if (this.changes != null) {
      data['changes'] = this.changes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@HiveType(typeId: 1)
class Changes {
  @HiveField(0)
  String? sId;
  @HiveField(1)
  String? speciesType;
  @HiveField(2)
  String? botanicalName;
  @HiveField(3)
  String? fkFamilyId;
  @HiveField(4)
  String? fkHabitId;
  @HiveField(5)
  List<Languages>? languages;
  @HiveField(6)
  bool? isEndangeredSpecies;
  @HiveField(7)
  bool? isDeleted;
  @HiveField(8)
  List<String>? images;
  @HiveField(9)
  String? createdAt;
  @HiveField(10)
  String? updatedAt;
  @HiveField(11)
  List<String>? cachedImages;
  @HiveField(12)
  String? familyName;
  @HiveField(13)
  dynamic habitName;
  @HiveField(14)
  List<String>? fkSectorId;
  @HiveField(15)
  List<String>? sectorNames;
  @HiveField(16)
  String? slug;

  Changes({
    this.sId,
    this.speciesType,
    this.botanicalName,
    this.fkFamilyId,
    this.fkHabitId,
    this.languages,
    this.isEndangeredSpecies,
    this.isDeleted,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.familyName,
    this.habitName,
    this.fkSectorId,
    this.sectorNames,
    this.cachedImages,
    this.slug,
  });

  Changes.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    speciesType = json['species_type'];
    botanicalName = json['botanical_name'];
    fkFamilyId = json['fk_family_id'];
    fkHabitId = json['fk_habit_id'];
    familyName = json['familyName'];
    habitName = json['habitName'];
    if (json['fk_sector_id'] != null) {
      fkSectorId = (json['fk_sector_id'] as List)
          .map((e) => e.toString())
          .toList();
    }
    if (json['sectorNames'] != null) {
      sectorNames = (json['sectorNames'] as List)
          .map((e) => e.toString())
          .toList();
    }
    createdAt = json['createdAt'];
    if (json['languages'] != null) {
      languages = <Languages>[];
      json['languages'].forEach((v) {
        languages!.add(new Languages.fromJson(v));
      });
    }
    isEndangeredSpecies = json['is_endangered_species'];
    isDeleted = json['isDeleted'];
    images = json['images'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    slug = json['slug'];
    if (json['cached_images'] != null) {
      cachedImages = (json['cached_images'] as List<dynamic>).cast<String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['species_type'] = this.speciesType;
    data['botanical_name'] = this.botanicalName;
    data['fk_family_id'] = this.fkFamilyId;
    data['fk_habit_id'] = this.fkHabitId;
    if (this.languages != null) {
      data['languages'] = this.languages!.map((v) => v.toJson()).toList();
    }
    data['is_endangered_species'] = this.isEndangeredSpecies;
    data['isDeleted'] = this.isDeleted;
    data['images'] = this.images;
    data['familyName'] = this.familyName;
    data['habitName'] = this.habitName;
    if (this.fkSectorId != null) {
      data['fk_sector_id'] = this.fkSectorId;
    }
    if (this.sectorNames != null) {
      data['sectorNames'] = this.sectorNames;
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['slug'] = this.slug;
    if (this.cachedImages != null) {
      data['cached_images'] = this.cachedImages;
    }
    return data;
  }

  List<String> get effectiveImages {
    if (cachedImages != null && cachedImages!.isNotEmpty) {
      return cachedImages!;
    }
    return images ?? const <String>[];
  }
}

@HiveType(typeId: 2)
class Languages {
  @HiveField(0)
  String? fkLanguageId;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? langCode;
  @HiveField(3)
  String? text;
  @HiveField(4)
  String? habitat;
  @HiveField(5)
  String? description;
  @HiveField(6)
  String? religiousSignificance;
  @HiveField(7)
  String? distribution;
  @HiveField(8)
  String? partUsed;
  @HiveField(9)
  String? medicinalUsed;
  @HiveField(10)
  String? otherUsed;
  @HiveField(11)
  String? culinaryPurpose;
  @HiveField(12)
  String? propagation;

  Languages({
    this.fkLanguageId,
    this.name,
    this.langCode,
    this.text,
    this.habitat,
    this.description,
    this.religiousSignificance,
    this.distribution,
    this.partUsed,
    this.medicinalUsed,
    this.otherUsed,
    this.culinaryPurpose,
    this.propagation,
  });

  Languages.fromJson(Map<String, dynamic> json) {
    fkLanguageId = json['fk_language_id'];
    name = json['name'];
    langCode = json['lang_code'];
    text = json['text'];
    habitat = json['habitat'];
    description = json['description'];
    religiousSignificance = json['religious_significance'];
    distribution = json['distribution'];
    partUsed = json['part_used'];
    medicinalUsed = json['medicinal_used'];
    otherUsed = json['other_used'];
    culinaryPurpose = json['culinary_purpose'];
    propagation = json['propagation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fk_language_id'] = this.fkLanguageId;
    data['name'] = this.name;
    data['lang_code'] = this.langCode;
    data['text'] = this.text;
    data['habitat'] = this.habitat;
    data['description'] = this.description;
    data['religious_significance'] = this.religiousSignificance;
    data['distribution'] = this.distribution;
    data['part_used'] = this.partUsed;
    data['medicinal_used'] = this.medicinalUsed;
    data['other_used'] = this.otherUsed;
    data['culinary_purpose'] = this.culinaryPurpose;
    data['propagation'] = this.propagation;
    return data;
  }
}
