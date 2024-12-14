import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';

class ActivityRecognition extends StatefulWidget {
  const ActivityRecognition({super.key});

  @override
  State<StatefulWidget> createState() => _ActivityRecognitionState();
}

class _ActivityRecognitionState extends State<ActivityRecognition> {
  StreamSubscription<Activity>? _activitySubscription;

  bool? isPermissionGranted;

  List<ActivityWithTime> listOfActivityWithTime = [];

  Future<void> _requestPermission() async {
    ActivityPermission permission =
        await FlutterActivityRecognition.instance.checkPermission();
    if (permission == ActivityPermission.PERMANENTLY_DENIED) {
      setState(() {
        isPermissionGranted = false;
      });
    } else if (permission == ActivityPermission.DENIED) {
      permission =
          await FlutterActivityRecognition.instance.requestPermission();
      if (permission != ActivityPermission.GRANTED) {
        setState(() {
          isPermissionGranted = false;
        });
      } else {
        setState(() {
          isPermissionGranted = true;
        });
      }
    } else if (permission == ActivityPermission.GRANTED) {
      setState(() {
        isPermissionGranted = true;
      });
    }
  }

  void _startService() async {
    try {
      await _requestPermission();

      // subscribe activity stream
      _activitySubscription = FlutterActivityRecognition.instance.activityStream
          .handleError(_onError)
          .listen(
        (event) {
          if (event.type != ActivityType.UNKNOWN) {
            setState(() {
              listOfActivityWithTime.insert(
                  0, ActivityWithTime(event, DateTime.now()));
            });
          }
        },
      );
    } catch (error) {
      _onError(error);
    }
  }

  void _onError(dynamic error) {
    String errorMessage;
    if (error is PlatformException) {
      errorMessage = error.message ?? error.code;
    } else {
      errorMessage = error.toString();
    }

    dev.log('error >> $errorMessage');
  }

  @override
  void initState() {
    super.initState();
    _startService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Recognition'),
        centerTitle: true,
      ),
      body: isPermissionGranted == true
          ? listOfActivityWithTime.isEmpty
              ? Center(child: Text("Waiting for Activity Detected...."))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: listOfActivityWithTime.length,
                  itemBuilder: (context, index) {
                    final current = listOfActivityWithTime[index];
                    return Container(
                      height: 60,
                      margin: EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? current.activity.type == ActivityType.UNKNOWN
                                ? Colors.orange
                                : Colors.green
                            : current.activity.type == ActivityType.UNKNOWN
                                ? Colors.orange.shade200
                                : Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.only(left: 20),
                      child: Container(
                        alignment: Alignment.center,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(iconsOfActivity[current.activity.type]?.icon ??
                                Icons.device_unknown),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              iconsOfActivity[current.activity.type]
                                      ?.name
                                      .toUpperCase() ??
                                  "UNKNOWN",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Spacer(),
                            Text(
                              " Time:  ${current.time.hour % 12}:${current.time.minute}:${current.time.second} ${current.time.hour ~/ 12 > 0 ? "PM" : "AM"}",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
          : isPermissionGranted == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
              : Center(
                  child: Text("Permission is Not granted"),
                ),
    );
  }

  Map<ActivityType, ActivityIconWithName> iconsOfActivity = {
    ActivityType.IN_VEHICLE:
        ActivityIconWithName(Icons.directions_car, "In Vehicle"),
    ActivityType.ON_BICYCLE:
        ActivityIconWithName(Icons.directions_bike, "On Bicycle"),
    ActivityType.RUNNING: ActivityIconWithName(Icons.directions_run, "Running"),
    ActivityType.STILL: ActivityIconWithName(Icons.person, "Still"),
    ActivityType.WALKING:
        ActivityIconWithName(Icons.directions_walk, "Walking"),
    ActivityType.UNKNOWN: ActivityIconWithName(Icons.device_unknown, "Unknown"),
  };

  @override
  void dispose() {
    _activitySubscription?.cancel();
    super.dispose();
  }
}

class ActivityWithTime {
  final Activity activity;
  final DateTime time;

  ActivityWithTime(this.activity, this.time);
}

class ActivityIconWithName {
  final IconData icon;
  final String name;

  ActivityIconWithName(this.icon, this.name);
}
