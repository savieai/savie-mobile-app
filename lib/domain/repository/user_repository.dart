import '../model/savie_user/savie_user.dart';

abstract class UserRepository {
  Future<SavieUser?> fetchUser();
  Stream<SavieUser?> watchUser();
  SavieUser? getUser();
}
