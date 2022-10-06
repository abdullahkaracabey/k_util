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
    createdAt = dateC?.toDate();

    var dateU = data[kUpdatedAt];
    updatedAt = dateU?.toDate() ?? DateTime.now();
  }

  bool isEqual(BaseModel model) {
    return id == model.id;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};

    if (id != null) result["id"] = id;

    return result;
  }
}
