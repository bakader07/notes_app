import 'package:notes_app/services/auth/auth_user.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';

import 'package:test/test.dart';

void main() {
  group('Mock authentification', () {
    final provider = MockAuthProvider();
    test(
      'It should not be initialized',
      () {
        expect(provider.isInitialized, false);
      },
    );
    test(
      'Cannot log out if not be initialized',
      () {
        expect(
          provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()),
        );
      },
    );
    test(
      'Should be able to be initialized',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
    );
    test(
      'User should be null after intialization',
      () {
        expect(provider.currentUser, null);
      },
    );
    test(
      'Should be able to intialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test(
      'Create user should delegate to logIn function',
      () async {
        final badEmailUser = await provider.createUser(
          email: 'test@mail.com',
          password: 'foobar',
        );
        expect(
          badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()),
        );

        final badPasswordUser = await provider.createUser(
          email: 'foo@bar.com',
          password: 'password',
        );
        expect(
          badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()),
        );

        final user = await provider.createUser(
          email: 'foo@bar.com',
          password: 'foobar',
        );
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, false);
      },
    );
    test(
      'Logged in user should be able to get verified',
      () {
        provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      },
    );
    test(
      'Should be able to logout and login again',
      () async {
        await provider.logOut();
        await provider.logIn(email: 'foo@bar.com', password: 'foobar');
        final user = provider.currentUser;
        expect(user, isNotNull);
      },
    );
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();

    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();

    if (email == 'test@mail.com') throw UserNotFoundAuthException();
    if (password == 'password') throw WrongPasswordAuthException();

    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();

    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();

    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}

// TODO: fix this