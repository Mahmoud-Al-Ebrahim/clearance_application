import 'package:clearance/core/cache/cache.dart';
import 'package:clearance/core/constants/networkConstants.dart';
import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/network/dio_helper.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    saveRequestsData(
        response.requestOptions.path +
            '\n' +
            'User-Agent: ' 'device OS:' +
            (Platform.isAndroid ? 'Android' : 'IOS') +
            ' , application version: $appVersionName , language:' +
            getCachedLocal().toString(),
        response.data,
        response.headers.map ,
        response.statusCode,
        response.requestOptions.method,
        response.requestOptions.queryParameters,
        response.data);
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    saveRequestsData(
        err.requestOptions.path +
            '\n' +
            'User-Agent: ' 'device OS:' +
            (Platform.isAndroid ? 'Android' : 'IOS') +
            ' , application version: $appVersionName , language:' +
            getCachedLocal().toString(),
        err.response?.data ?? {},
        err.response?.headers.map ?? {},
        err.response?.statusCode,
        err.requestOptions.method,
        err.requestOptions.queryParameters,
        err.response?.data ?? {});
    if (lastEndPointUrl != storeErrorEP && err.toString()!='') {
      MainDioHelper.postData(url: storeErrorEP, token: getCachedToken(), data: {
        "error_description": 'User-Agent:' 'device OS:' +
            (Platform.isAndroid ? 'Android' : 'IOS') +
            ' , application version: $appVersionName , language:' +
            getCachedLocal().toString() +
            ' , back end version: $backEndVersion' +
            '\n' +
            'token: ' +
            getCachedToken().toString() +
            '\ndevice id: ' +
            deviceId.toString() +
            '\nlast_endpoint: ${err.requestOptions.path}\nlast_screen: $lastScreen\nlast_clicked_button: $lastClickedButton\n${err.toString()}\nscreen_trace: ${screenTrace.toString()}'
      });
    }
    handler.next(err);
  }
}
