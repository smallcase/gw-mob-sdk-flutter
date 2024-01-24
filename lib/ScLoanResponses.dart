import 'dart:convert';

abstract class ScLoanResponse {
  bool get isSuccess;
  String? get data;
}

class ScLoanSuccess implements ScLoanResponse {
  @override
  bool get isSuccess => true;
  final String? data;
  ScLoanSuccess({
    this.data,
  });

  ScLoanSuccess copyWith({
    bool? isSuccess,
    String? data,
  }) {
    return ScLoanSuccess(
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isSuccess': isSuccess,
      'data': data,
    };
  }

  factory ScLoanSuccess.fromMap(Map<String, dynamic> map) {
    return ScLoanSuccess(
      data: map['data'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ScLoanSuccess.fromJson(String source) =>
      ScLoanSuccess.fromMap(json.decode(source));

  @override
  String toString() => 'ScLoanSuccess(isSuccess: $isSuccess, data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScLoanSuccess &&
        other.isSuccess == isSuccess &&
        other.data == data;
  }

  @override
  int get hashCode => isSuccess.hashCode ^ data.hashCode;
}

class ScLoanError implements ScLoanResponse, Exception {
  @override
  bool get isSuccess => false;
  final int code;
  final String message;
  final String? data;
  ScLoanError({
    required this.code,
    required this.message,
    this.data,
  });

  ScLoanError copyWith({
    bool? isSuccess,
    int? code,
    String? message,
    String? data,
  }) {
    return ScLoanError(
      code: code ?? this.code,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isSuccess': isSuccess,
      'code': code,
      'message': message,
      'data': data,
    };
  }

  factory ScLoanError.fromMap(Map<String, dynamic> map) {
    return ScLoanError(
      code: map['code']?.toInt() ?? -1,
      message: map['message'] ?? 'n/a',
      data: map['data'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ScLoanError.fromJson(String source) =>
      ScLoanError.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ScLoanError(isSuccess: $isSuccess, code: $code, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScLoanError &&
        other.isSuccess == isSuccess &&
        other.code == code &&
        other.message == message &&
        other.data == data;
  }

  @override
  int get hashCode {
    return isSuccess.hashCode ^
        code.hashCode ^
        message.hashCode ^
        data.hashCode;
  }
}
