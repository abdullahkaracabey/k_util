
import 'package:k_util/models/base_model.dart';

class NameModel extends BaseModel {
  String name;

  NameModel.fromJson(Map<String, dynamic> data)
      : name =  data["name"],
        super.fromJson(data);
}
