class InvalidEmailAuthException implements Exception {}

class EmailInUseAuthException implements Exception {}

class WeakPasswordAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

class UserNotFoundAuthException implements Exception {}

// generic auth exceptions
class AuthException implements Exception {}
