import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/network/api_base_helper.dart';
import 'package:arumbu/network/request_type.dart';
import 'package:arumbu/model/sync_plants_response.dart' as sync;

class PlantsListResponse {
  bool? success;
  String? message;
  Data? data;

  PlantsListResponse({this.success, this.message, this.data});

  PlantsListResponse.fromJson(Map<String, dynamic> json) {
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

  static Future<Plant> getplantsData(BuildContext ctx, {dynamic body}) async {
    try {
      if (kDebugMode) {
        print(body);
      }
      ApiBaseHelper helper = ApiBaseHelper(ctx);
      final responseData = await helper.callAPI(
        "${URLs.getPlantsList}/$body",
        RequestType.GET,
      );

      return Plant.fromJson(responseData['data']);
    } on Exception catch (error) {
      return Future.error(error);
    }
  }
}

class Data {
  List<Plant>? plant;
  int? page;
  int? count;
  int? total;
  int? pages;
  bool? usedTextIndex;
  List<String>? searchedFields;

  Data({
    this.plant,
    this.page,
    this.count,
    this.total,
    this.pages,
    this.usedTextIndex,
    this.searchedFields,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      plant = <Plant>[];
      json['items'].forEach((v) {
        plant!.add(new Plant.fromJson(v));
      });
    }
    page = json['page'];
    count = json['count'];
    total = json['total'];
    pages = json['pages'];
    usedTextIndex = json['usedTextIndex'];
    searchedFields = json['searchedFields'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.plant != null) {
      data['items'] = this.plant!.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    data['count'] = this.count;
    data['total'] = this.total;
    data['pages'] = this.pages;
    data['usedTextIndex'] = this.usedTextIndex;
    data['searchedFields'] = this.searchedFields;
    return data;
  }
}

class Plant {
  String? sId;
  String? speciesType;
  String? botanicalName;
  String? fkFamilyId;
  String? fkHabitId;
  List<String>? fkSectorId;
  String? familyName;
  dynamic habitName;
  List<String>? sectorNames;
  List<Languages>? languages;
  bool? isEndangeredSpecies;
  bool? isDeleted;
  List<String>? images;
  String? createdAt;
  String? updatedAt;
  String? slug;

  Plant({
    this.sId,
    this.speciesType,
    this.botanicalName,
    this.fkFamilyId,
    this.fkHabitId,
    this.fkSectorId,
    this.languages,
    this.isEndangeredSpecies,
    this.isDeleted,
    this.images,
    this.familyName,
    this.habitName,
    this.sectorNames,
    this.createdAt,
    this.slug,
    this.updatedAt,
  });

  factory Plant.fromSyncChange(sync.Changes change) {
    return Plant(
      sId: change.sId,
      speciesType: change.speciesType,
      botanicalName: change.botanicalName,
      fkFamilyId: change.fkFamilyId,
      fkHabitId: change.fkHabitId,
      fkSectorId: change.fkSectorId != null
          ? List<String>.from(change.fkSectorId!)
          : null,
      languages: change.languages
          ?.map((lang) => Languages.fromSyncLanguage(lang))
          .toList(),
      isEndangeredSpecies: change.isEndangeredSpecies,
      isDeleted: change.isDeleted,
      images: List<String>.from(change.effectiveImages),
      familyName: change.familyName,
      habitName: change.habitName,
      sectorNames: change.sectorNames != null
          ? List<String>.from(change.sectorNames!)
          : null,
      createdAt: change.createdAt,
      updatedAt: change.updatedAt,
      slug: change.slug,
    );
  }

  Plant.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    speciesType = json['species_type'];
    botanicalName = json['botanical_name'];
    fkFamilyId = json['fk_family_id'];
    fkHabitId = json['fk_habit_id'];
    if (json['fk_sector_id'] != null) {
      fkSectorId = (json['fk_sector_id'] as List)
          .map((e) => e.toString())
          .toList();
    }
    familyName = json['familyName'];
    habitName = json['habitName'];
    if (json['sectorNames'] != null) {
      sectorNames = (json['sectorNames'] as List)
          .map((e) => e.toString())
          .toList();
    }
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['species_type'] = this.speciesType;
    data['botanical_name'] = this.botanicalName;
    data['fk_family_id'] = this.fkFamilyId;
    data['fk_habit_id'] = this.fkHabitId;
    if (this.fkSectorId != null) {
      data['fk_sector_id'] = this.fkSectorId;
    }
    if (this.languages != null) {
      data['languages'] = this.languages!.map((v) => v.toJson()).toList();
    }
    data['is_endangered_species'] = this.isEndangeredSpecies;
    data['isDeleted'] = this.isDeleted;
    data['images'] = this.images;
    data['familyName'] = this.familyName;
    data['habitName'] = this.habitName;
    if (this.sectorNames != null) {
      data['sectorNames'] = this.sectorNames;
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['slug'] = this.slug;
    return data;
  }
}

class Languages {
  String? fkLanguageId;
  String? langCode;
  String? name;
  String? text;
  String? habitat;
  String? description;
  String? religiousSignificance;
  String? distribution;
  String? partUsed;
  String? medicinalUsed;
  String? otherUsed;
  String? culinaryPurpose;
  String? propagation;

  Languages({
    this.fkLanguageId,
    this.langCode,
    this.name,
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

  factory Languages.fromSyncLanguage(sync.Languages source) {
    return Languages(
      fkLanguageId: source.fkLanguageId,
      langCode: source.langCode,
      name: source.name,
      text: source.text,
      habitat: source.habitat,
      description: source.description,
      religiousSignificance: source.religiousSignificance,
      distribution: source.distribution,
      partUsed: source.partUsed,
      medicinalUsed: source.medicinalUsed,
      otherUsed: source.otherUsed,
      culinaryPurpose: source.culinaryPurpose,
      propagation: source.propagation,
    );
  }

  Languages.fromJson(Map<String, dynamic> json) {
    fkLanguageId = json['fk_language_id'];
    langCode = json['lang_code'];
    name = json['name'];
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
    data['lang_code'] = this.langCode;
    data['name'] = this.name;
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
