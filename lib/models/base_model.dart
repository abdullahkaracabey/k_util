import 'package:flutter/foundation.dart';

abstract class BaseModel extends ChangeNotifier {
  static String kId = "id";
  static String kCreatedAt = "createdAt";
  static String kUpdatedAt = "updatedAt";
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;

  BaseModel({this.id});

  BaseModel.fromJson(Map<String, dynamic> data) {
    var modelId = data[kId];

    if (modelId is int) {
      id = "${modelId}";
    } else {
      id = modelId;
    }

    var dateC = data[kCreatedAt];

    if (dateC != null) {
      if (dateC is DateTime) {
        createdAt = dateC;
      } else {
        createdAt = dateC?.toDate();
      }
    }

    var dateU = data[kUpdatedAt];

    if (dateU != null) {
      if (dateU is DateTime) {
        updatedAt = dateU;
      } else {
        updatedAt = dateU?.toDate();
      }
    }
  }

  bool isEqual(BaseModel model) {
    return id == model.id;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};

    if (id != null) result["id"] = id;

    result["createdAt"] = createdAt ?? DateTime.now();
    result["updatedAt"] = DateTime.now();

    return result;
  }
}
