import 'package:k_util/models/base_model.dart';

abstract class BaseAuthApi<T extends BaseModel> {
  Future<void> logout();
  Future<T?> fetchUser();
}
