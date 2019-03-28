library flutter_rollbar;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart';

import 'src/map_util.dart';
import 'src/request.dart';
import 'src/response.dart';
import 'src/version.dart';

export 'src/version.dart';

class Rollbar {
  Rollbar({
    @required this.accessToken,
    String environment,
    String platform,
    Map<String, dynamic> config,
  }) {
    _config = config ?? <String, dynamic>{};
    _config.addAll(<String, Object>{
      'environment': environment,
      'platform': platform,
      'framework': 'flutter',
      'language': 'dart',
      'notifier': {
        'name': 'flutter_rollbar',
        'version': sdkVersion,
      }
    });
  }

  final String accessToken;
  Map<String, dynamic> _config;

  Future<Response> trace(Object error, StackTrace stackTrace,
      {Map<String, Object> otherData}) async {
    final body = <String, dynamic>{
      'trace': {
        'frames': Trace.from(stackTrace).frames.map((frame) {
          return {
            'filename': Uri.parse(frame.uri.toString()).path,
            'lineno': frame.line,
            'method': frame.member,
            'colno': frame.column
          };
        }).toList(),
        'exception': {
          'class': error.runtimeType.toString(),
          'message': error.toString()
        }
      }
    };

    final data = _generatePayloadData(body, otherData);

    return await Request(accessToken, data).send();
  }

  Future<Response> message(String messageBody,
      {Map<String, Object> metadata, Map<String, Object> otherData}) async {
    final body = <String, dynamic>{
      'message': {'body': messageBody}
    };

    if (metadata != null) {
      body['message'] = metadata;
    }

    final Map<String, Object> data = _generatePayloadData(body, otherData);
    return await Request(accessToken, data).send();
  }

  Map<String, dynamic> _generatePayloadData(
    Map<String, dynamic> body,
    Map<String, dynamic> otherData,
  ) {
    var data = <String, dynamic>{
      'body': body,
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
      'language': 'dart'
    };

    if (otherData != null) {
      data = deepMerge(data, otherData);
    }

    return deepMerge(_config, data);
  }
}
