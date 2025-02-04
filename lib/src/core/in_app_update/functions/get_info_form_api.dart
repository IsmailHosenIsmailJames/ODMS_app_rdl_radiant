import 'dart:convert';

import 'package:http/http.dart';

import '../../../apis/apis.dart';
import '../model/latest_app_info.dart';

Future<LatestAppInfoAPIModel> getInfoFormAPI() async {
  final response = await get(Uri.parse(base + getAppInfoAPI));
  if (response.statusCode == 200) {
    try {
      Map<String, dynamic> data = Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
      return LatestAppInfoAPIModel.fromMap(data['result']);
    } catch (e) {
      throw Exception('Failed to get latest app info');
    }
  } else {
    throw Exception('Failed to get latest app info');
  }
}
