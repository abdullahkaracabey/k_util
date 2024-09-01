import 'package:flutter/foundation.dart';

enum ModelState { active, archived, deleted }

abstract class BaseModel extends ChangeNotifier {
  static String kId = "id";
  static String kCreatedAt = "createdAt";
  static String kUpdatedAt = "updatedAt";
  static String kModelState = "modelState";
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  ModelState? state;

  Map<String, dynamic> additionalParams = {};

  BaseModel({this.id, this.createdAt, this.updatedAt, this.state}){
    createdAt ??= DateTime.now();

    updatedAt ??= DateTime.now();
  }

  List<String> searchIndexes();

  

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

    final _state = data[kModelState];

    if (_state is String) {
      if (ModelState.values.contains(_state)) {
        state = ModelState.values.byName(_state);
      } else {
        state = ModelState.active;
      }
    }

    additionalParams = data;
  }

  bool isEqual(BaseModel model) {
    return id == model.id;
  }

  List<String>? _handleSearchIndexes() {
    var searchList = searchIndexes();
    var result = <String>[];
    if (searchList.isNotEmpty) {
      searchList.forEach((element) {
        final text = element.trim().toLowerCase();

        if (text.isNotEmpty) {
          text.split(" ").forEach((element) {
            if (element.isNotEmpty) {
              for (var i = 3; i <= element.length; i++) {
                result.add(element.substring(0, i));
              }
            }
          });
        }
      });
    }

    if (result.isNotEmpty) {
      return result;
    }

    return null;
  }

  Map<String, dynamic> toJson({bool ignoreDates = false}) {
    var result = <String, dynamic>{
      kModelState: state?.name ?? ModelState.active.name,
      ...additionalParams
    };

    if (id != null) result["id"] = id;

    if (!ignoreDates) {
      result["createdAt"] = createdAt ?? DateTime.now();
      result["updatedAt"] = DateTime.now();
    } else {
      result.remove("createdAt");
      result.remove("updatedAt");
    }

    final searchList = _handleSearchIndexes();

    if (searchList != null) {
      result["searchText"] = searchList;
    }

    return result;
  }
}
