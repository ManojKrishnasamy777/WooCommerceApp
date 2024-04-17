import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_com/core/core.dart';
import 'package:e_com/feature/auth/controller/auth_ctrl.dart';
import 'package:e_com/feature/region_settings/controller/region_ctrl.dart';
import 'package:e_com/feature/region_settings/provider/region_provider.dart';
import 'package:e_com/locator.dart';
import 'package:e_com/models/settings/region_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

export 'package:dio/dio.dart' show DioException;

class DioClient {
  DioClient(this._ref) {
    _dio = Dio(_options);
    _dio.interceptors.add(_interceptorsWrapper());
    _dio.interceptors.add(talkerDioLogger);
  }

  late Dio _dio;

  final _options = BaseOptions(
    baseUrl: Endpoints.baseApiUrl,
    connectTimeout: Endpoints.connectionTimeout, 
    receiveTimeout: Endpoints.receiveTimeout,
    responseType: ResponseType.json,
    headers: {'Accept': 'application/json'},
  );

  final Ref _ref;

  static TalkerDioLogger get talkerDioLogger => TalkerDioLogger(
        talker: talk.talker,
        settings: TalkerDioLoggerSettings(
          printRequestData: false,
          responseFilter: (response) => response.statusCode != 200,
        ),
      );

  Future<Map<String, String?>> header() async {
    final region = await _ref.watch(regionCtrlProvider.future);
    final token = locate<SharedPreferences>().getString(PrefKeys.accessToken);

    final currencyUid = region.currencyUid;
    final langCode = region.langCode;

    return {
      'api-lang': langCode,
      'currency-uid': currencyUid,
      'Authorization': 'Bearer $token',
    };
  }

  // Get:-----------------------------------------------------------------------
  Future<Response> get(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  // Post:----------------------------------------------------------------------
Future<Response> post(
  String url, {
  Map<String, dynamic>? data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onSendProgress,
  ProgressCallback? onReceiveProgress,
  String? username = 'ck_55cd072699e8a4c18dbe467cd9064dad694dbc5a',
  String? password = 'cs_f1b54e3d129e9f9fb830022caa5339c7be1934eb',
}) async {
  try {
    final formData = data == null ? null : FormData.fromMap(data);

    final auth = username != null && password != null
        ? 'Basic ${base64Encode(utf8.encode('$username:$password'))}'
        : null;

    final headers = <String, dynamic>{};
    if (auth != null) {
      headers['Authorization'] = auth;
    }

    if (options != null && options.headers != null) {
      headers.addAll(options.headers!);
    }

    final Dio dio = Dio();
    final Response response = await dio.post(
      url,
      data: formData,
      queryParameters: queryParameters,
      options: Options(headers: headers),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  // ignore: deprecated_member_use
  } on DioError {
    // Handle Dio errors
    rethrow;
  }
}

  Future<Response> download(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        url,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          headers: {},
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return (status ?? 0) < 500;
          },
        ),
      );
      Logger(response.data, 'download');
      return response;
    } on DioException {
      rethrow;
    }
  }

  // Interceptors :----------------------------------------------------------------------
  _interceptorsWrapper() => InterceptorsWrapper(
        onRequest: (options, handler) async {
          final headers = await header();
          options.headers.addAll(headers);
          return handler.next(options);
        },
        onResponse: (res, handler) {
          _ref
              .read(localeCurrencyStateProvider.notifier)
              .update((state) => LocalCurrency.fromMap(res.data));

          final statusCtrl = _ref.read(serverStatusProvider.notifier);
          final Map<String, dynamic> response = res.data ?? {};

          final code = response['code'];

          statusCtrl.update(code);
          return handler.next(res);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            _ref.read(authCtrlProvider.notifier).logOut();
          }
          final statusCtrl = _ref.read(serverStatusProvider.notifier);
          final data = error.response?.data;

          if (data is Map?) {
            final response = data ?? {};
            final code = response['code'];
            statusCtrl.update(code);
          }
          return handler.next(error);
        },
      );
}


