import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:delivery/src/apis/apis.dart';

Future<Response?> registrationAndGetJsonResponse(
  Map<String, dynamic> query,
) async {
  try {
    final response = await post(
      Uri.parse(base + registrationPath),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(query),
    );
    return response;
  } catch (e) {
    debugPrint(e.toString());
  }
  return null;
}
