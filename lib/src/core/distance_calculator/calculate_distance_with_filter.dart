import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:delivery/src/core/distance_calculator/custom_position_model.dart';

class PositionCalculationResult {
  final Duration totalDuration;
  final double totalDistance; // in meters
  final double averageSpeed; // in meters per second
  final List<LatLng> paths;

  PositionCalculationResult({
    required this.totalDuration,
    required this.totalDistance,
    required this.averageSpeed,
    required this.paths,
  });
}

class PositionPointsCalculator {
  final List<CustomPositionModel> rawPositions;
  PositionPointsCalculator({required this.rawPositions});

  double calculateDistance(CustomPositionModel start, CustomPositionModel end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  PositionCalculationResult processData() {
    if (rawPositions.length < 2) {
      return PositionCalculationResult(
        totalDuration: Duration.zero,
        totalDistance: 0.0,
        averageSpeed: 0.0,
        paths: [],
      );
    }

    Duration totalDuration =
        rawPositions.first.timestamp.difference(rawPositions.first.timestamp);
    double totalDistance = 0.0;
    for (int i = 1; i < rawPositions.length; i++) {
      totalDistance += calculateDistance(
        rawPositions[i - 1],
        rawPositions[i],
      );
    }

    double averageSpeed = totalDistance / totalDuration.inSeconds;

    return PositionCalculationResult(
      totalDuration: totalDuration,
      totalDistance: totalDistance,
      averageSpeed: averageSpeed,
      paths: rawPositions
          .map((position) => LatLng(position.latitude, position.longitude))
          .toList(),
    );
  }
}
