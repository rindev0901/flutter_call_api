class Response<T> {
  bool success;
  String message;
  int statusCode;
  T? data;

  Response({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
  });

  factory Response.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return Response<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
