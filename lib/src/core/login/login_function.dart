import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:odms/src/apis/apis.dart';

Future<Response?> loginAndGetJsonResponse(Map<String, dynamic> queary) async {
  try {
    final response = await post(
      Uri.parse(base + loginPath),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(queary),
    );
    return response;
  } catch (e) {
    debugPrint(e.toString());
  }
  return null;
}
