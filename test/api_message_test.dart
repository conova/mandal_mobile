import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandal_capital/common/api_message.dart';

void main() {
  final req = RequestOptions(path: '/x');

  test('server message wins', () {
    final e = DioException(
      requestOptions: req,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: req, statusCode: 400,
          data: {'message': 'Буруу', 'messageen': 'Wrong'}),
    );
    expect(dioErrorMessage(e), anyOf('Буруу', 'Wrong'));
  });

  test('no internet types', () {
    for (final e in [
      DioException(requestOptions: req, type: DioExceptionType.connectionError,
          message: 'The connection errored: Failed host lookup'),
      DioException(requestOptions: req, type: DioExceptionType.unknown,
          error: 'SocketException: Network is unreachable'),
    ]) {
      expect(dioErrorMessage(e), noInternetMessage);
    }
  });

  test('timeout and 5xx are distinct, never raw dio text', () {
    final t = dioErrorMessage(DioException(requestOptions: req,
        type: DioExceptionType.receiveTimeout, message: 'took longer'));
    final s = dioErrorMessage(DioException(requestOptions: req,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: req, statusCode: 502, data: '<html>')));
    expect(t, isNot(contains('took longer')));
    expect(s, isNot(contains('html')));
    expect({t, s, noInternetMessage}.length, 3);
  });

  test('isNetworkError on raw strings', () {
    expect(isNetworkError('Exception: SocketException: Failed host lookup'), isTrue);
    expect(isNetworkError('Нууц үг буруу'), isFalse);
  });
}
