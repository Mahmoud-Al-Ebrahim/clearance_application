import 'dart:io';

import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/network/log_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:clearance/core/cache/cache.dart';

import '../constants/networkConstants.dart';
import '../main_functions/main_funcs.dart';


class MainDioHelper {
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
          baseUrl: clearanceUrl,
          receiveDataWhenStatusError: true,
          connectTimeout: 30000, // 30 seconds
          receiveTimeout: 30000, //
    ));
    dio!.interceptors.add(LoggerInterceptor());
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String lang = 'en',
    String? token,
  }) async {
    String? cachedLocal = getCachedLocal();
    token=getCachedToken();
    if (cachedLocal == null) {
      lang = 'en';
    } else if (cachedLocal == 'ar') {
      lang = 'ae';
    } else {
      lang = 'en';
    }
    logRequestedUrl('get method');
    logRequestedUrl('url: ' + url + '\n');
    logRequestedUrl('queryParameters: ' + query.toString() + '\n');
    logRequestedUrl('token: ' + token.toString() + '\n');
    dio!.options.headers = {
      'lang': lang,
      'User-Agent':'device OS:'+(Platform.isAndroid ? 'Android' : 'IOS')+' , application version: $appVersionName , language:'+lang + ' , back end version: $backEndVersion , mobile_app_open_count: ${getEnterAppCount()}',
      'Authorization': token != null ? "Bearer " + token : null,
      'Accept': 'application/json',
    };
    lastEndPointUrl=url;

    return await dio!.get(
      url,
      queryParameters: query,);

  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? query,
    String lang = 'en',
    String? token,
  }) async {
    token=getCachedToken();
    logRequestedUrl('post method');
    logRequestedUrl('url: ' + url + '\n');
    logRequestedUrl('queryParameters: ' + query.toString() + '\n');
    logRequestedUrl('data: ' + data.toString() + '\n');
    logRequestedUrl('token: ' + token.toString() + '\n');
    dio!.options.headers = {
      'lang': lang,
      'User-Agent':'device OS:'+(Platform.isAndroid ? 'Android' : 'IOS')+' , application version: $appVersionName , language:'+lang + ' , back end version: $backEndVersion , mobile_app_open_count: ${getEnterAppCount()}',
      'Authorization': token != null ? "Bearer " + token : token,
      'Accept': 'application/json',
    };
    lastEndPointUrl=url;

    return await dio!.post(
      url,
      queryParameters: query,
      data: formData ?? data,
    );

  }

  static Future<Response> putData({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? query,
    String lang = 'en',
    String? token,
  }) async {
    token=getCachedToken();
    logRequestedUrl('putData method');
    logRequestedUrl('url: ' + url + '\n');
    logRequestedUrl('queryParameters: ' + query.toString() + '\n');
    logRequestedUrl('data: ' + data.toString() + '\n');
    lastEndPointUrl=url;

    dio!.options.headers = {
      'lang': lang,
      'User-Agent':'device OS:'+(Platform.isAndroid ? 'Android' : 'IOS')+' , application version: $appVersionName , language:'+lang + ' , back end version: $backEndVersion , mobile_app_open_count: ${getEnterAppCount()}',
      'Authorization': token ?? '',
      'Content-Type': 'application/json',
    };

    return await dio!.put(
      url,
      queryParameters: query,
      data: data,
    );

  }

  static Future<Response> postDataWithFormData({
    required String url,
    FormData? data,
    Map<String, dynamic>? query,
    String lang = 'en',
    String? token,
  }) async {
    token=getCachedToken();
    lastEndPointUrl=url;
    logRequestedUrl('postDataWithFormData method');
    logRequestedUrl('url: ' + url + '\n');
    logRequestedUrl('queryParameters: ' + query.toString() + '\n');
    logRequestedUrl('data: ' + data.toString() + '\n');
    // logRequestedUrl('token: '+token.toString()+'\n');
    dio!.options.headers = {
      'lang': lang,
      'User-Agent':'device OS:'+(Platform.isAndroid ? 'Android' : 'IOS')+' , application version: $appVersionName , language:'+lang + ' , back end version: $backEndVersion , mobile_app_open_count: ${getEnterAppCount()}',
      'Authorization': token != null ? "Bearer " + token : null,
      'Accept': 'application/json',
    };

    return await  dio!.post(
      url,
      queryParameters: query,
      data: data,
    );

  }
}
