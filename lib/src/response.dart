class Result {
  Result({this.uuid});

  factory Result.fromJson(Map<String, dynamic> json) {
    return json == null ? null : Result(uuid: json['uuid']);
  }

  final String uuid;
}

class Response {
  Response({this.err, this.message, this.result});

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      err: json['err'],
      message: json['message'],
      result: Result.fromJson(json['result']),
    );
  }

  final int err;
  final String message;
  final Result result;

  bool get isSuccessful => err == 0;
}
