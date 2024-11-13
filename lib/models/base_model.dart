import 'package:flutter/foundation.dart';

enum ModelState { active, archived, deleted }

abstract class BaseModel extends ChangeNotifier {
  static String kId = "id";
  static String kCreatedAt = "createdAt";
  static String kUpdatedAt = "updatedAt";
  static String kModelState = "modelState";
  static String kModelType = "modelType";

  final String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  final ModelState? state;

  final Map<String, dynamic>? _additionalParams;

  String get modelType;
  Map<String, dynamic> get additionalParams => _additionalParams ?? {};

  List<String> searchIndexes();

  BaseModel({this.id, this.createdAt, this.updatedAt, this.state})
      : _additionalParams = null {
    createdAt ??= DateTime.now();

    updatedAt ??= DateTime.now();
  }

  BaseModel.fromJson(Map<String, dynamic> data)
      : id = data[kId]?.toString(),
        state = ModelState.values.where((element) => element.name == data[kModelState]).isNotEmpty
            ? ModelState.values.byName(data[kModelState])
            : ModelState.active,
        _additionalParams = data {
    var dateC = data[kCreatedAt];
    if (dateC != null) {
      if (dateC is DateTime) {
        createdAt = dateC;
      } else {
        try {
          createdAt = dateC?.toDate();
        } catch (e) {
          debugPrint("Error: $e");
        }
      }
    }

    var dateU = data[kUpdatedAt];

    if (dateU != null) {
      if (dateU is DateTime) {
        updatedAt = dateU;
      } else {
        try {
          updatedAt = dateU?.toDate();
        } catch (e) {
          debugPrint("Error: $e");
        }
      }
    }
  }

  bool isEqual(BaseModel model) {
    return id == model.id;
  }

  List<String>? handleSearchIndexes() {
    var searchList = searchIndexes();
    var result = <String>[];
    if (searchList.isNotEmpty) {
      for (var element in searchList) {
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
      }
    }

    if (result.isNotEmpty) {
      return result;
    }

    return null;
  }

  Map<String, dynamic> toJson({bool ignoreDates = false}) {
    final params = _additionalParams ?? {};

    params.removeWhere((key, value) => value == null);
    params.removeWhere(
        (key, value) => key == kId || key == kModelState || key == kModelType);
    var result = <String, dynamic>{
      kModelState: state?.name ?? ModelState.active.name,
      kModelType: modelType,
      ...params
    };

    if (id != null) result["id"] = id;

    if (!ignoreDates) {
      result["createdAt"] = createdAt ?? DateTime.now();
      result["updatedAt"] = DateTime.now();
    } else {
      result.remove("createdAt");
      result.remove("updatedAt");
    }

    final searchList = handleSearchIndexes();

    if (searchList != null) {
      result["searchText"] = searchList;
    }

    return result;
  }
}
