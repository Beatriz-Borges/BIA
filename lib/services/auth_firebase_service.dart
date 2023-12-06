import 'dart:async';
import 'dart:convert';

import 'package:bia/model/models/bia_user.dart';
import 'package:bia/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

// this part of the code handles the acces to login/logout/signup from firebase

class AuthFirebaseService implements AuthService {
  static BIAUser? _currentUser;
  static final List<BIAUser> _usersList = [];

  static final _userStream = Stream<BIAUser?>.multi(
    (controller) async {
      final authChanges = FirebaseAuth.instance.authStateChanges();
      await for (final user in authChanges) {
        _currentUser = user == null ? null : toBIAUser(user);
        controller.add(_currentUser);
      }
    },
  );

  // gets the users saved in the database and copy them to be used in
  // the application
  Future<void> loadUsers() async {
    _usersList.clear();

    final response = await http.get(
      Uri.parse('${Constants.users}.json'),
    );

    final data = jsonDecode(response.body);

    if (data == null) return;

    data.forEach((userId, userData) {
      _usersList.add(
        BIAUser(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          tipo: userData['tipo'],
          tipoId: userData['tipoId'],
        ),
      );
    });
  }

  @override
  BIAUser? get currentUser => _currentUser;

  @override
  Stream<BIAUser?> get userChanges => _userStream;

  // handle the login of the user
  @override
  Future<void> login(String email, String password) async {
    // the logout here is to handle a problem created on customizing users
    await logout();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // handles the logout of the user
  @override
  Future<void> logout() async {
    try {
      FirebaseAuth.instance.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // handles the signup of users. it first checks if the email used in
  // the signup is already registered as a professor or aluno in the
  // app, in the case that it isn't the function will return a exception
  @override
  Future<void> signup(
    String name,
    String email,
    String password,
    String tipo,
  ) async {
    String id = '';
    if (tipo == 'Professor') {
      final response =
          await http.get(Uri.parse('${Constants.professores}.json'));

      final data = jsonDecode(response.body);
      if (data != null) {
        data.forEach((professorId, professorData) {
          if (professorData['email'] == email) {
            id = professorId;
          }
        });
      }
      if (id == '') return Future.error('Não existe um $tipo com esse email');
    } else if (tipo == 'Aluno') {
      final response = await http.get(Uri.parse('${Constants.alunos}.json'));

      final data = jsonDecode(response.body);
      if (data != null) {
        data.forEach((alunoId, alunoData) {
          if (alunoData['email'] == email) {
            id = alunoId;
          }
        });
      }
      if (id == '') return Future.error('Não existe um $tipo com esse email');
    }
    final auth = FirebaseAuth.instance;
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      return;
    }

    await credential.user!.updateDisplayName(name);

    await http.post(
      Uri.parse('${Constants.users}.json'),
      body: jsonEncode(
        {
          'id': credential.user!.uid,
          'name': name,
          'email': credential.user!.email!,
          'tipo': tipo,
          'tipoId': id,
        },
      ),
    );

    _usersList.add(BIAUser(
      id: credential.user!.uid,
      name: name,
      email: email,
      tipo: tipo,
      tipoId: id,
    ));

    await login(email, password);
  }

  static BIAUser? toBIAUser(User user) {
    BIAUser? biaUser;
    try {
      biaUser = _usersList.firstWhere((biaUser) => biaUser.id == user.uid);
    } catch (e) {
      return null;
    }

    return biaUser;
  }
}
