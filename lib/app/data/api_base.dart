import 'dart:developer';
import 'package:dio/dio.dart';

///

/// Delete enum add on 28 sept
enum RestApiMethod { get, put, post, delete }

class ApiBase {
  Dio dio = Dio();

  Future<Map<String, dynamic>?> _restApi<T>(
    String path, {
    String? baseUrl,
    required RestApiMethod apiMethod,
    Map<String, dynamic>? headers,
    dynamic body = const {},
    bool isBearerToken = false,

    ///[attachToken] is for defining whether to attach token in the header or not
    bool attachToken = true,
    bool showError = true,
  }) async {
    try {
      if (baseUrl != null) {
        ///if user chooses to send a different base url
        dio.options.baseUrl = baseUrl;
      }

      ///logging the POST endpoint and PAYLOAD
      log('${dio.options.baseUrl}$path', name: '$apiMethod');
      if (body is! FormData) log(body.toString(), name: "PAYLOAD");


      ///Hitting the POST request
      Response<T>? response;
      switch (apiMethod) {
        case RestApiMethod.post:
          response = await dio.post(
            path,
            data: body,
            options: Options(headers: headers),
            // options: attachToken
            //     ? Options(headers: header)
            //     : null,
          );
          break;
        default:
          break;
      }

      ///logging the RESPONSE details
      // log('${response?.data}', name: "RESPONSE");
      log('${response?.statusCode}', name: "RESPONSE STATUS CODE");

      ///if nor error then return response else return NUll
      if (response?.data is Map?) {
        Map<String, dynamic>? x = response?.data as Map<String, dynamic>?;
        if (x != null && (x['status'] != false)) {
          return x;
        } else {
          if (showError) {
            String errorMessage = '${x?['message'].toString()}';
            if (!errorMessage.contains('SocketException') &&
                !errorMessage.contains('HttpException')) {
              // showSnackBar(errorMessage, isError: true);
            } else {
              // showSnackBar('Something went wrong!', isError: true);
            }
          }
        }
      }
    } on DioError catch (e) {
      ///if exception show the error
      log('${e.response}', name: 'DIO EXCEPTION');
      if (showError) {
        if (!e.toString().contains('SocketException') &&
            !e.toString().contains('HttpException')) {
          // this.showError(e);
        } else {
          // showSnackBar('Something went wrong!', isError: true);
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> postApi<T>(
    String path, {
    String? baseUrl,
    required dynamic body,
    bool isBearerToken = false,
    bool attachToken = true,
    bool showError = true,
    Map<String, dynamic>? header,
  }) async {
    return await _restApi(
      path,
      baseUrl: baseUrl,
      body: body,
      attachToken: attachToken,
      isBearerToken: isBearerToken,
      apiMethod: RestApiMethod.post,
      showError: showError,
      headers: header,
    );
  }
}

///


