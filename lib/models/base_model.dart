import 'package:flutter/foundation.dart';
import 'package:k_util/extensions/string.dart';

enum ModelState { active, needConfirmation, archived, deleted }

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

  bool get isDeleted => state == ModelState.deleted;
  bool get isArchived => state == ModelState.archived;
  bool get isActive => state == ModelState.active;
  bool get needConfirmation => state == ModelState.needConfirmation;

  Map<String, dynamic> get additionalParams => _additionalParams ?? {};

  List<String> searchIndexes();

  BaseModel(
      {this.id, this.createdAt, this.updatedAt, this.state = ModelState.active})
      : _additionalParams = null {
    createdAt ??= DateTime.now();

    updatedAt ??= DateTime.now();
  }

  BaseModel.fromJson(Map<String, dynamic> data)
      : id = data[kId]?.toString(),
        state = ModelState.values
                .where((element) => element.name == data[kModelState])
                .isNotEmpty
            ? ModelState.values.byName(data[kModelState])
            : ModelState.active,
        _additionalParams = data {
    var dateC = data[kCreatedAt];
    if (dateC != null) {
      if (dateC is DateTime) {
        createdAt = dateC;
      } else if (dateC is String) {
        createdAt = DateTime.tryParse(dateC);
      } else if (dateC is Map) {
        // Handle Firestore Timestamp from web (comes as Map with seconds and nanoseconds)
        try {
          final seconds = dateC['seconds'] as int?;
          final nanoseconds = dateC['nanoseconds'] as int?;
          if (seconds != null) {
            createdAt = DateTime.fromMillisecondsSinceEpoch(
              seconds * 1000 + (nanoseconds ?? 0) ~/ 1000000,
            );
          }
        } catch (e) {
          debugPrint("Error parsing timestamp map: $e");
        }
      } else {
        try {
          createdAt = dateC?.toDate();
        } catch (e) {
          debugPrint("Error calling toDate: $e");
        }
      }
    }

    var dateU = data[kUpdatedAt];

    if (dateU != null) {
      if (dateU is DateTime) {
        updatedAt = dateU;
      } else if (dateU is String) {
        updatedAt = DateTime.tryParse(dateU);
      } else if (dateU is Map) {
        // Handle Firestore Timestamp from web (comes as Map with seconds and nanoseconds)
        try {
          final seconds = dateU['seconds'] as int?;
          final nanoseconds = dateU['nanoseconds'] as int?;
          if (seconds != null) {
            updatedAt = DateTime.fromMillisecondsSinceEpoch(
              seconds * 1000 + (nanoseconds ?? 0) ~/ 1000000,
            );
          }
        } catch (e) {
          debugPrint("Error parsing timestamp map: $e");
        }
      } else {
        try {
          updatedAt = dateU?.toDate();
        } catch (e) {
          debugPrint("Error calling toDate: $e");
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
      for (var text in searchList) {
        final s = text.createSearchText();

        if (s.isNotEmpty) {
          result.addAll(s);
        }
      }
    }

    if (result.isNotEmpty) {
      return result;
    }

    return null;
  }

  /// Recursively sanitize values for JSON serialization
  /// Converts Timestamp and DateTime to ISO8601 strings
  dynamic _sanitizeForJson(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value.toIso8601String();
    }

    // Handle Firebase Timestamp without importing cloud_firestore
    if (value.runtimeType.toString() == 'Timestamp') {
      try {
        return (value.toDate() as DateTime).toIso8601String();
      } catch (e) {
        debugPrint("Error converting Timestamp: $e");
        return null;
      }
    }

    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _sanitizeForJson(v)));
    }

    if (value is List) {
      return value.map((v) => _sanitizeForJson(v)).toList();
    }

    return value;
  }

  Map<String, dynamic> toJson({bool ignoreDates = false}) {
    final params = _additionalParams ?? {};

    params.removeWhere((key, value) => value == null);
    params.removeWhere(
        (key, value) => key == kId || key == kModelState || key == kModelType);

    // Recursively sanitize all values for JSON serialization
    final sanitizedParams = <String, dynamic>{};
    for (final entry in params.entries) {
      sanitizedParams[entry.key] = _sanitizeForJson(entry.value);
    }

    var result = <String, dynamic>{
      kModelState: state?.name ?? ModelState.active.name,
      kModelType: modelType,
      ...sanitizedParams
    };

    if (id != null) result["id"] = id;

    if (!ignoreDates) {
      result["createdAt"] = (createdAt ?? DateTime.now()).toIso8601String();
      result["updatedAt"] = (updatedAt ?? DateTime.now()).toIso8601String();
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
