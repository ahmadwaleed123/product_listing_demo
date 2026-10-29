enum ApiFailureType { network, timeout, unauthorized, server, cancelled, unknown }

typedef ResponseParser<T> = T Function(dynamic json);

class ApiResponse<T> {
  const ApiResponse._({required this.isSuccess, this.data, this.message, this.statusCode, this.failureType});

  final bool isSuccess;
  final T? data;
  final String? message;
  final int? statusCode;
  final ApiFailureType? failureType;

  factory ApiResponse.success(Map<String, dynamic> body, ResponseParser<T> parser, {int? statusCode}) {
    return ApiResponse._(isSuccess: true, data: parser(body), statusCode: statusCode);
  }

  factory ApiResponse.failure(String message, {int? statusCode, ApiFailureType failureType = ApiFailureType.unknown}) {
    return ApiResponse._(isSuccess: false, message: message, statusCode: statusCode, failureType: failureType);
  }

  (String?, T?) get result => (message, data);
}

extension ApiResponseResult<T> on Future<ApiResponse<T>> {
  Future<(String?, T?)> get result async => (await this).result;
}

Map<String, dynamic> asJsonMap(dynamic json) => json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};

List<Map<String, dynamic>> asJsonList(dynamic json) =>
    json is List ? json.whereType<Map>().map(Map<String, dynamic>.from).toList() : const [];
