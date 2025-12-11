import 'package:k_scaffold/models/base_model.dart';

abstract class BaseAuthApi<T extends BaseModel> {
  Future<void> logout();
  Future<T?> fetchUser();
  Future<T> updateUser(T user);
}
