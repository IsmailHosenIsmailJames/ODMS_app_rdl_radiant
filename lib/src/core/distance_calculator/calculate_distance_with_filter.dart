import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class PositionCalculationResult {
  final Duration totalDuration;
  final double totalDistance; // in meters
  final double averageSpeed; // in meters per second
  final List<LatLng> filteredPath;

  PositionCalculationResult({
    required this.totalDuration,
    required this.totalDistance,
    required this.averageSpeed,
    required this.filteredPath,
  });
}

class PositionPointsCalculator {
  final List<Position> rawPositions;
  final ActivityType activityType;

  // --- Configuration Thresholds (Tune These!) ---
  final double accuracyThreshold; // Max acceptable accuracy in meters
  final double
      minTimeDeltaSeconds; // Minimum time difference between points to consider speed reliable
  final double
      minDistanceThreshold; // Min distance between points to consider movement (helps filter jitter)

  // Max speed thresholds (m/s) - Adjust based on realistic expectations
  final Map<ActivityType, double> maxSpeedThresholds = {
    ActivityType.walking: 3.0, // ~10.8 km/h
    ActivityType.running: 10.0, // ~36 km/h (covers sprinting)
    ActivityType.cycling: 25.0, // ~90 km/h (covers fast cycling)
  };
  // ----------------------------------------------

  PositionPointsCalculator({
    required this.rawPositions,
    this.activityType = ActivityType.cycling, // Default activity type
    this.accuracyThreshold = 35.0, // Default accuracy limit
    this.minTimeDeltaSeconds = 0.5, // Default min time delta
    this.minDistanceThreshold = 1.0, // Default min distance delta
  });

  PositionCalculationResult processData() {
    List<Position> acceptedPositions = [];
    double calculatedDistance = 0.0;

    if (rawPositions.isEmpty) {
      return PositionCalculationResult(
        totalDuration: Duration.zero,
        totalDistance: 0.0,
        averageSpeed: 0.0,
        filteredPath: [],
      );
    }

    Position? lastAcceptedPosition;

    for (final currentPosition in rawPositions) {
      // --- Filter 1: Basic Validity & Accuracy ---
      if (currentPosition.accuracy <= 0 || // Ignore invalid accuracy
          currentPosition.accuracy > accuracyThreshold) {
        // print("Rejected (Accuracy/Validity): ${currentPosition.accuracy}");
        continue; // Skip this point
      }

      // --- Handle the very first valid point ---
      if (lastAcceptedPosition == null) {
        // print("Accepted (First): Lat ${currentPosition.latitude}, Lon ${currentPosition.longitude}");
        acceptedPositions.add(currentPosition);
        lastAcceptedPosition = currentPosition;
        continue;
      }

      // --- Calculate Deltas (Distance & Time) ---
      final double distanceDelta = Geolocator.distanceBetween(
        lastAcceptedPosition.latitude,
        lastAcceptedPosition.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      // Ensure timestamp is valid and time moves forward
      if (currentPosition.timestamp.isBefore(lastAcceptedPosition.timestamp)) {
        // print("Rejected (Timestamp order)");
        continue; // Data out of order
      }
      final Duration timeDelta = currentPosition.timestamp.difference(
        lastAcceptedPosition.timestamp,
      );
      final double timeDeltaSeconds = timeDelta.inMilliseconds / 1000.0;

      // --- Filter 2: Minimum Movement (Anti-Jitter) ---
      // If the time delta is reasonable but distance is tiny, likely jitter
      if (timeDeltaSeconds > minTimeDeltaSeconds &&
          distanceDelta < minDistanceThreshold) {
        // print("Rejected (Jitter): Dist $distanceDelta < $minDistanceThreshold m");
        // Don't update lastAcceptedPosition, but don't reject future points based on this jittery one
        continue;
      }

      // --- Filter 3: Speed Threshold ---
      if (timeDeltaSeconds >= minTimeDeltaSeconds) {
        // Avoid division by zero/tiny time
        final double speed = distanceDelta / timeDeltaSeconds; // m/s
        final double maxSpeed = maxSpeedThresholds[activityType] ??
            maxSpeedThresholds[ActivityType.running]!; // Fallback to running

        if (speed > maxSpeed) {
          // print("Rejected (Speed): $speed m/s > $maxSpeed m/s");
          continue; // Unrealistic speed, likely a GPS jump
        }
      } else if (distanceDelta > 10) {
        // If time delta is very small but distance is significant, also likely a jump
        // print("Rejected (Jump): Dist $distanceDelta m in $timeDeltaSeconds s");
        continue;
      }

      // --- Point Accepted ---
      // print("Accepted: Lat ${currentPosition.latitude}, Lon ${currentPosition.longitude}, DistDelta $distanceDelta");
      calculatedDistance += distanceDelta;
      acceptedPositions.add(currentPosition);
      lastAcceptedPosition = currentPosition; // Update for the next iteration
    }

    // --- Calculate Final Results ---
    Duration calculatedDuration = Duration.zero;
    if (acceptedPositions.length >= 2) {
      // Use timestamps of the first and last *accepted* points
      calculatedDuration = acceptedPositions.last.timestamp.difference(
        acceptedPositions.first.timestamp,
      );
    } else if (acceptedPositions.length == 1 && rawPositions.isNotEmpty) {
      // If only one point accepted, try using raw start/end time if available?
      // Or just keep duration zero. Let's keep it zero for consistency as no movement *between* accepted points occurred.
    }
    // Alternative: Use stopwatch duration passed from outside if more reliable

    double averageSpeed = 0.0;
    if (calculatedDuration.inSeconds > 0 && calculatedDistance > 0) {
      averageSpeed = calculatedDistance / calculatedDuration.inSeconds;
    }

    // Create the filtered path for the map
    List<LatLng> filteredPath = acceptedPositions
        .map((pos) => LatLng(pos.latitude, pos.longitude))
        .toList();

    return PositionCalculationResult(
      totalDuration: calculatedDuration,
      totalDistance: calculatedDistance,
      averageSpeed: averageSpeed,
      filteredPath: filteredPath,
    );
  }
}

enum ActivityType {
  walking,
  running,
  cycling;

  @override
  String toString() {
    switch (this) {
      case ActivityType.walking:
        return 'walking';
      case ActivityType.running:
        return 'running';
      case ActivityType.cycling:
        return 'cycling';
    }
  }
}
