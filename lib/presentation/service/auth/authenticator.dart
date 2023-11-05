import '../../../core/util/result.dart';
import '../../../domain/auth/auth_exception.dart';
import '../../../domain/auth/auth_state.dart';

abstract class Authenticator {
  Future<Result<String?, AuthException>> signIn(
      {String? email, String? password});
  Future<Result<void, AuthException>> signOut();

  Future<Result<String?, AuthException>> createNewAccount(
      String email, String password) async {
    return Result.err(_UnimplementedAuthException());
  }

  Future<Result<void, AuthException>> sendEmailVerification(
      AuthState? user) async {
    return Result.err(_UnimplementedAuthException());
  }

  Future<Result<void, AuthException>> resetPassword(String email) async {
    return Result.err(_UnimplementedAuthException());
  }
}

class _UnimplementedAuthException extends AuthException {
  @override
  Exception get causeException => Exception('UnimplementedMethod');

  @override
  String get code => 'unimplemented';

  @override
  AuthErrorType get errorType => AuthErrorType.unimplementedMethod;

  @override
  bool isUnknown() => true;

  @override
  StackTrace? get stackTrace => null;
}
