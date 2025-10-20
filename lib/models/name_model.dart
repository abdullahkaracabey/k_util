import 'package:k_util/models/base_model.dart';

class NameModel extends BaseModel {
  static const type = "NameModel";
  String name;

  @override
  NameModel.fromJson(super.data)
      : name = data['name'],
        super.fromJson();

  @override
  List<String> searchIndexes() {
    return [name];
  }

  @override
  String get modelType => type;
}
