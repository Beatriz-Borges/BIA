import 'package:bia/model/models/bia_user.dart';

import 'auth_firebase_service.dart';

abstract class AuthService {
  BIAUser? get currentUser;

  Stream<BIAUser?> get userChanges;

  Future<void> signup(
    String name,
    String email,
    String password,
    String tipo,
  );

  Future<void> login(
    String email,
    String password,
  );

  Future<void> logout();

  factory AuthService() {
    return AuthFirebaseService();
  }
}
