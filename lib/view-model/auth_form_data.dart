enum AuthMode {
  signup,
  login,
}

// a class that helps handle the login/signup screen

class AuthFormData {
  String name = '';
  String email = '';
  String password = '';
  String tipo = '';
  AuthMode _mode = AuthMode.login;

  bool get isLogin => _mode == AuthMode.login;
  bool get isSignup => _mode == AuthMode.signup;

  void toggleAuthMode() {
    _mode = isLogin ? AuthMode.signup : AuthMode.login;
  }
}
