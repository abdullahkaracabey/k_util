import 'package:flutter/foundation.dart';

enum ModelState { active, archived, deleted }

abstract class BaseModel extends ChangeNotifier {
  static String kId = "id";
  static String kCreatedAt = "createdAt";
  static String kUpdatedAt = "updatedAt";
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  ModelState? state;

  BaseModel({this.id, this.createdAt, this.updatedAt, this.state});

  BaseModel.fromJson(Map<String, dynamic> data) {
    var modelId = data[kId];

    if (modelId is int) {
      id = "$modelId";
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

    state = ModelState.values.byName(data["state"] ?? ModelState.active.name);
  }

  bool isEqual(BaseModel model) {
    return id == model.id;
  }

  Map<String, dynamic> toJson({bool ignoreDates = false}) {
    var result = <String, dynamic>{};

    if (id != null) result["id"] = id;

    if (!ignoreDates) {
      result["createdAt"] = createdAt ?? DateTime.now();
      result["updatedAt"] = DateTime.now();
    }

    return result;
  }
}
