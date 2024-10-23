// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:odms/src/apis/sockets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketManager {
  factory SocketManager() => _instance;
  SocketManager._internal() {
    _initializeSocket();
  }
  // Singleton pattern
  static final SocketManager _instance = SocketManager._internal();

  socket_io.Socket? _socket;
  VoidCallback? _onConnectCallback;

  void _initializeSocket() {
    try {
      // Setup socket options
      _socket = socket_io.io(
        baseSocketURL,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect() // for Flutter or Dart VM
            .build(),
      );

      // Initialize socket connection
      _setupSocketListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing socket: $e');
      }
    }
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      sendSocketInfoFromPrefs();
      _onConnectCallback?.call();
    });

    _socket?.onDisconnect((_) {
      if (kDebugMode) {
        print('Disconnected');
      }
    });

    _socket?.onConnectError((data) {
      if (kDebugMode) {
        print('Connection error: $data');
      }
    });
  }

  void setOnConnectCallback(VoidCallback callback) {
    _onConnectCallback = callback;
  }

  void connect() {
    _socket?.connect();
  }

  void disconnect() {
    _socket?.disconnect();
  }

  bool isConnected() {
    return _socket?.connected ?? false;
  }

  Future<void> sendSocketInfoFromPrefs() async {
    final socketId = _socket?.id;
    final instance = await SharedPreferences.getInstance();
    final decodeData = Map<String, dynamic>.from(
      jsonDecode(instance.getString('userData') ?? '{}') as Map,
    );
    final dataToSend = <String, dynamic>{
      'socket_id': socketId,
      'user_id': decodeData['result']['sap_id'] ?? '',
    };

    _socket?.emit('send_socket_info', dataToSend);
  }

  Future<void> sendLocationViaSocket({
    required double latitude,
    required double longitude,
    required double altitude,
    required double accuracy,
    required double bearing,
    required double speed,
    String? activity,
  }) async {
    final instance = await SharedPreferences.getInstance();
    var decodeData = Map<String, dynamic>.from(
      jsonDecode(instance.getString('userData') ?? '{}') as Map,
    );
    decodeData = Map<String, dynamic>.from(decodeData['result'] as Map);
    final jsonLocation = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'bearing': bearing,
      'speed': speed,
      'activity': activity,
    };

    final jsonUserDetails = <String, dynamic>{
      'sap_id': decodeData['sap_id'] ?? '',
      'full_name': decodeData['full_name'] ?? '',
      'user_type': decodeData['user_type'] ?? '',
      'mobile_number': decodeData['mobile_number'] ?? '',
    };

    _socket?.emit('coordinates_android', {
      'location': jsonLocation,
      'user_details': jsonUserDetails,
    });
  }

  void sendMessage(String message) {
    _socket?.emit('message', message);
  }
}
