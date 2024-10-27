import 'package:k_util/models/base_model.dart';

class NameModel extends BaseModel {
  static const type = "NameModel";
  String name;

  NameModel.fromJson(Map<String, dynamic> data)
      : name = data["name"],
        super.fromJson(data);

  @override
  List<String> searchIndexes() {
    return [name];
  }

  @override
  String get modelType => type;
}
