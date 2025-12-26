class GalleryPageResponse {
  bool? success;
  String? message;
  Gallery? data;

  GalleryPageResponse({this.success, this.message, this.data});

  GalleryPageResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Gallery.fromJson(json['data']) : null;
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
}

class Gallery {
  List<Items>? items;
  int? total;
  int? page;
  int? limit;
  int? pages;

  Gallery({this.items, this.total, this.page, this.limit, this.pages});

  Gallery.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    pages = json['pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['pages'] = this.pages;
    return data;
  }
}

class Items {
  String? sId;
  dynamic title;
  List<String>? images;
  String? createdAt;
  String? updatedAt;

  Items({this.sId, this.title, this.images, this.createdAt, this.updatedAt});

  Items.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    images = json['images'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['images'] = this.images;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
