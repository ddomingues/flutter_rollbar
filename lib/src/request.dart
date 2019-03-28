import 'dart:convert';

import 'package:http/http.dart' as http;

import 'response.dart';

class Request {
  Request(this._accessToken, this._data);

  String _accessToken;
  Map<String, dynamic> _data;

  Future<Response> send() async {
    final jsonMap = json.encode({'access_token': _accessToken, 'data': _data});

    try {
      final result = await http.post(
        'https://api.rollbar.com/api/1/item/',
        headers: {'Content-Type': 'application/json'},
        body: jsonMap,
      );

      final response = Response.fromJson(json.decode(result.body));

      if (result.statusCode != 200) {
        _logStatus(result, response);
      }

      return response;
    } catch (error) {
      _logError(error);
      return Response(err: 1, message: error.toString());
    }
  }

  void _logStatus(http.Response result, Response response) {
    switch (result.statusCode) {
      case 400:
        print(
            'Bad request. No JSON payload was found, or it could not be decoded.');
        break;
      case 403:
        print('Access denied. Check your access_token.');
        break;
      case 422:
        print('''
          Unprocessable payload. A syntactically valid JSON payload was found, but it had one or more semantic errors.
          The response will contain a 'message' key describing the errors.''');
        break;
      case 429:
        print('''
          Too Many Requests - If rate limiting is enabled for your access token,
          this return code signifies that the rate limit has been reached and the item was not processed.''');
        break;
      case 500:
        print('Internal server error. There was an error on Rollbar\'s end.');
        break;
    }

    print('Rollbar error message: ${response.message}');
  }

  void _logError(Object error) {
    print('Couldn\'t send the payload to Rollbar: ${error.toString()}');
  }
}
