import 'package:dio/dio.dart';
import 'package:k_util/models/app_error.dart';

mixin Api {
  String get baseUrl;

  Dio get dio;

  Future<dynamic> postRequest(String url,
      {Map<String, dynamic>? headers,
      Map<String, dynamic>? queryParameters,
      dynamic body}) async {
    try {
      var currentUrl = "";

      if (url.startsWith("http") || url.startsWith("www")) {
        currentUrl = url;
      } else {
        currentUrl = '$baseUrl/$url';
      }

      if (headers != null) {
        dio.options.headers.addAll(headers);
      }

      var response = await dio.post(currentUrl,
          data: body, queryParameters: queryParameters);

      return _handledResponse(response);
    } catch (e) {
      _throwError(e);
    }
  }

  Future<dynamic> getRequest(String url,
      {Map<String, dynamic>? headers,
      Map<String, dynamic>? queryParameters}) async {
    try {
      var currentUrl = "";

      if (url.startsWith("http") || url.startsWith("www")) {
        currentUrl = url;
      } else {
        currentUrl = '$baseUrl/$url';
      }

      if (headers != null) {
        dio.options.headers.addAll(headers);
      }

      var response =
          await dio.get(currentUrl, queryParameters: queryParameters);

      return _handledResponse(response);
    } catch (e) {
      _throwError(e);
    }
  }

  dynamic _handledResponse(Response response) {
    if (response.statusCode! ~/ 100 == 2) {
      return response.data;
    } else if (response.statusCode == 401) {
      if (response.data["message"] != null) {
        throw AppException(
            code: response.statusCode, message: response.data["message"]);
      }
      throw AppException.unAuthorized;
    } else if (response.statusCode == 500) {
      throw AppException.unknownError;
    } else if (response.statusCode != null &&
        response.data["message"] != null) {
      var code = response.statusCode;
      var message = response.data["message"];
      throw AppException(code: code, message: message);
    }

    throw AppException.unknownError;
  }

  download({required String url, required String savePath}) async {
    try {
      await dio.download(url, savePath);
    } catch (e) {
      _throwError(e);
    }
  }

  void _throwError(Object e) {
    if (e is DioException) {
      if (e.response != null) {
        _handledResponse(e.response!);
      } else {
        int errorCode;

        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            errorCode = AppException.kRemoteAddressNotReached;
            break;
          default:
            errorCode = AppException.kUnknownError;
        }

        throw AppException(message: e.toString(), code: errorCode);
      }
    } else {
      throw AppException(
          message: e.toString(), code: AppException.kUnknownError);
    }
  }
}
