class BaseResponseModel {
  bool status;
  String message;
  dynamic data;

  BaseResponseModel({
    this.status = false,
    this.message = "",
    this.data,
  });

  factory BaseResponseModel.fromJson(Map<String, dynamic> json) {
    return BaseResponseModel(
      status: json['status'] is bool ? json['status'] : (json['success'] is bool ? json['success'] : false),
      message: json['message'] is String ? json['message'] : "",
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}

class ArgumentModel {
  String stringArgument;
  int intArgument;
  bool boolArgument;
  List listArgument;

  ArgumentModel({
    this.stringArgument = '',
    this.intArgument = -1,
    this.boolArgument = false,
    this.listArgument = const [],
  });
}