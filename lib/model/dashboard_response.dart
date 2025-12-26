import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arumbu/constants/urls.dart';
import 'package:arumbu/network/api_base_helper.dart';
import 'package:arumbu/network/request_type.dart';

class DashboardResponsePage {
  bool? success;
  String? message;
  Data? data;

  DashboardResponsePage({this.success, this.message, this.data});

  DashboardResponsePage.fromJson(Map<String, dynamic> json) {
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

  static Future<DashboardResponsePage> getDashboardData(
    BuildContext ctx, {
    dynamic body,
  }) async {
    try {
      if (kDebugMode) {
        print(body);
      }
      ApiBaseHelper helper = ApiBaseHelper(ctx);
      final responseData = await helper.callAPI(
        URLs.dashboard,
        RequestType.GET,
      );

      return DashboardResponsePage.fromJson(responseData);
    } on Exception catch (error) {
      return Future.error(error);
    }
  }
}

class Data {
  List<Gallery>? gallery;
  List<Habit>? habit;
  List<Sector>? sector;
  List<Feedback>? feedback;
  List<ExtinctSpecies>? extinctSpecies;

  Data({
    this.gallery,
    this.habit,
    this.sector,
    this.feedback,
    this.extinctSpecies,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['gallery'] != null) {
      gallery = <Gallery>[];
      json['gallery'].forEach((v) {
        gallery!.add(new Gallery.fromJson(v));
      });
    }
    if (json['habit'] != null) {
      habit = <Habit>[];
      json['habit'].forEach((v) {
        habit!.add(new Habit.fromJson(v));
      });
    }
    if (json['sector'] != null) {
      sector = <Sector>[];
      json['sector'].forEach((v) {
        sector!.add(new Sector.fromJson(v));
      });
    }
    if (json['feedback'] != null) {
      feedback = <Feedback>[];
      json['feedback'].forEach((v) {
        feedback!.add(new Feedback.fromJson(v));
      });
    }
    if (json['extinct_species'] != null) {
      extinctSpecies = <ExtinctSpecies>[];
      json['extinct_species'].forEach((v) {
        extinctSpecies!.add(new ExtinctSpecies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.gallery != null) {
      data['gallery'] = this.gallery!.map((v) => v.toJson()).toList();
    }
    if (this.habit != null) {
      data['habit'] = this.habit!.map((v) => v.toJson()).toList();
    }
    if (this.sector != null) {
      data['sector'] = this.sector!.map((v) => v.toJson()).toList();
    }
    if (this.feedback != null) {
      data['feedback'] = this.feedback!.map((v) => v.toJson()).toList();
    }
    if (this.extinctSpecies != null) {
      data['extinct_species'] = this.extinctSpecies!
          .map((v) => v.toJson())
          .toList();
    }
    return data;
  }
}

class Gallery {
  String? galleryId;
  dynamic title;
  String? image;

  Gallery({this.galleryId, this.title, this.image});

  Gallery.fromJson(Map<String, dynamic> json) {
    galleryId = json['galleryId'];
    title = json['title'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['galleryId'] = this.galleryId;
    data['title'] = this.title;
    data['image'] = this.image;
    return data;
  }
}

class Habit {
  String? id;
  dynamic name;
  String? image;

  Habit({this.id, this.name, this.image});

  Habit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}

class Sector {
  String? id;
  String? slug;
  dynamic name; // can be String or Map<String, dynamic>
  dynamic image;
  dynamic shortDescription;

  Sector({this.id, this.name, this.image, this.shortDescription});

  Sector.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    image = json['image'];
    shortDescription = json['short_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['slug'] = this.slug;
    data['name'] = this.name;
    data['image'] = this.image;
    data['short_description'] = this.shortDescription;
    return data;
  }
}

class Feedback {
  String? id;
  String? name;
  String? comments;
  int? ratings;

  Feedback({this.id, this.name, this.comments, this.ratings});

  Feedback.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    comments = json['comments'];
    ratings = json['ratings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['comments'] = this.comments;
    data['ratings'] = this.ratings;
    return data;
  }
}

class ExtinctSpecies {
  String? sId;
  String? speciesType;
  String? botanicalName;
  String? fkFamilyId;
  String? fkHabitId;
  List<Languages>? languages;
  bool? isEndangeredSpecies;
  bool? isDeleted;
  List<String>? images;
  String? createdAt;
  String? updatedAt;
  String? slug;

  ExtinctSpecies({
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
    this.slug,
  });

  ExtinctSpecies.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    speciesType = json['species_type'];
    botanicalName = json['botanical_name'];
    fkFamilyId = json['fk_family_id'];
    fkHabitId = json['fk_habit_id'];
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
    if (this.languages != null) {
      data['languages'] = this.languages!.map((v) => v.toJson()).toList();
    }
    data['is_endangered_species'] = this.isEndangeredSpecies;
    data['isDeleted'] = this.isDeleted;
    data['images'] = this.images;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['slug'] = this.slug;
    return data;
  }
}

class Languages {
  String? fkLanguageId;
  String? name;
  String? langCode;
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
