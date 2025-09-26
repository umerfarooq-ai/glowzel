import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../config/environment.dart';

class DioClient extends DioForNative {
  Environment _environment;

  String? _authToken;
  String? get authToken => _authToken;

  void setToken(String token) {
    this._authToken = token;
    print("Token set: $_authToken");
  }

  DioClient({required Environment environment}) : _environment = environment {
    options = BaseOptions(
      baseUrl: _environment.baseUrl,
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        'Connection': 'keep-alive',
      },
    );
    interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
          print("Authorization header set: ${options.headers['Authorization']}");
        }else {
          print("No token set, Authorization header not included");
        }
        return handler.next(options);
      }),
    );
    interceptors.add(LogInterceptor(
      request: false,
      requestHeader: false,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
    ));
  }
}
