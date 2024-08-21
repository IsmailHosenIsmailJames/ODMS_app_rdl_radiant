import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:rdl_radiant/src/apis/apis.dart';

Future<Response?> registationAndGetJsonResponse(
  Map<String, dynamic> queary,
) async {
  try {
    final response = await post(
      Uri.parse(base + registationPath),
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
