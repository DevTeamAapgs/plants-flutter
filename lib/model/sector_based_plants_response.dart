class SectorBasedPlantsResponse {
  bool? success;
  String? message;
  List<Data>? data;

  SectorBasedPlantsResponse({this.success, this.message, this.data});

  SectorBasedPlantsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  Name? name;
  String? slug;
  List<Plants>? plants;

  Data({this.sId, this.name, this.slug, this.plants});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'] != null ? new Name.fromJson(json['name']) : null;
    slug = json['slug'];
    if (json['plants'] != null) {
      plants = <Plants>[];
      json['plants'].forEach((v) {
        plants!.add(new Plants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.name != null) {
      data['name'] = this.name!.toJson();
    }
    data['slug'] = this.slug;
    if (this.plants != null) {
      data['plants'] = this.plants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Name {
  String? en;
  String? ta;

  Name({this.en, this.ta});

  Name.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ta = json['ta'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['en'] = this.en;
    data['ta'] = this.ta;
    return data;
  }
}

class Plants {
  String? sId;
  String? botanicalName;
  String? fkFamilyId;
  String? fkHabitId;
  List<String>? fkSectorId;
  List<Languages>? languages;
  bool? isEndangeredSpecies;
  bool? isDeleted;
  List<String>? images;
  String? createdAt;
  String? updatedAt;
  String? slug;
  String? familyName;
  Name? habitName;

  Plants({
    this.sId,
    this.botanicalName,
    this.fkFamilyId,
    this.fkHabitId,
    this.fkSectorId,
    this.languages,
    this.isEndangeredSpecies,
    this.isDeleted,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.slug,
    this.familyName,
    this.habitName,
  });

  Plants.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    botanicalName = json['botanical_name'];
    fkFamilyId = json['fk_family_id'];
    fkHabitId = json['fk_habit_id'];
    fkSectorId = json['fk_sector_id'].cast<String>();
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
    familyName = json['familyName'];
    habitName = json['habitName'] != null
        ? new Name.fromJson(json['habitName'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['botanical_name'] = this.botanicalName;
    data['fk_family_id'] = this.fkFamilyId;
    data['fk_habit_id'] = this.fkHabitId;
    data['fk_sector_id'] = this.fkSectorId;
    if (this.languages != null) {
      data['languages'] = this.languages!.map((v) => v.toJson()).toList();
    }
    data['is_endangered_species'] = this.isEndangeredSpecies;
    data['isDeleted'] = this.isDeleted;
    data['images'] = this.images;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['slug'] = this.slug;
    data['familyName'] = this.familyName;
    if (this.habitName != null) {
      data['habitName'] = this.habitName!.toJson();
    }
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
