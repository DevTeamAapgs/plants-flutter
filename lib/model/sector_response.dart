class SectorPageResponse {
  bool? success;
  String? message;
  Sector? sector;

  SectorPageResponse({this.success, this.message, this.sector});

  SectorPageResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    sector = json['data'] != null ? new Sector.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.sector != null) {
      data['data'] = this.sector!.toJson();
    }
    return data;
  }
}

class Sector {
  List<Items>? items;
  int? page;
  int? count;
  int? total;
  int? pages;
  bool? usedTextIndex;
  List<String>? searchedFields;

  Sector({
    this.items,
    this.page,
    this.count,
    this.total,
    this.pages,
    this.usedTextIndex,
    this.searchedFields,
  });

  Sector.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
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
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
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

class Items {
  String? sId;
  dynamic name; // can be String or Map<String, dynamic>
  String? image;
  dynamic shortDescription;
  dynamic description;
  String? createdAt;
  String? updatedAt;
  String? slug;

  Items({
    this.sId,
    this.name,
    this.image,
    this.shortDescription,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.slug,
  });

  Items.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
    shortDescription = json['short_description'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['short_description'] = this.shortDescription;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['slug'] = this.slug;
    return data;
  }
}
