import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:odms/src/apis/apis.dart';

Future<Response?> loginAndGetJsonResponse(Map<String, dynamic> query) async {
  try {
    log("Sending to login api for login :  \n${jsonEncode(query)}");
    log(base + loginPath);
    final response = await post(
      Uri.parse(base + loginPath),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(query),
    );
    log(response.statusCode.toString());
    log(response.body);
    return response;
  } catch (e) {
    debugPrint(e.toString());
  }
  return null;
}
