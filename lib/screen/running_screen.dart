import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RunningScreen extends StatefulWidget {
  final Function(bool) onRunningStateChange;

  const RunningScreen({Key? key, required this.onRunningStateChange})
      : super(key: key);

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  static const LatLng initialLatLng = LatLng(36.8336, 127.1792);
  GoogleMapController? mapController;
  List<LatLng> routePoints = [];
  late StreamSubscription<Position> positionStream;

  bool isRunning = false;
  double totalDistance = 0.0;
  late LatLng lastPosition;

  double currentSpeed = 0.0;
  DateTime? lastUpdateTime;

  Timer? timer;
  int elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      print('위치 서비스를 활성화해주세요.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('위치 권한을 허가해주세요.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('앱의 위치 권한을 설정에서 허가해주세요.');
      return;
    }

    startLocationTracking();
  }

  void startLocationTracking() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      if (routePoints.isNotEmpty) {
        double distance = Geolocator.distanceBetween(
          lastPosition.latitude,
          lastPosition.longitude,
          currentLatLng.latitude,
          currentLatLng.longitude,
        );

        final DateTime currentTime = DateTime.now();
        if (lastUpdateTime != null) {
          final elapsed = currentTime.difference(lastUpdateTime!).inSeconds;
          if (elapsed > 0) {
            // 기존 속도 계산에서 km/h에서 m/s로 변환
            double speed = distance / elapsed; // m/s 단위로 계산
            setState(() {
              currentSpeed = speed;
            });
          }
        }

        setState(() {
          totalDistance += distance / 1000; // km 단위로 거리 계산
        });
      }

      setState(() {
        lastPosition = currentLatLng;
        routePoints.add(currentLatLng);
        lastUpdateTime = DateTime.now();
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLatLng),
        );
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void toggleRun() {
    setState(() {
      isRunning = !isRunning;
    });
    widget.onRunningStateChange(isRunning);
    if (isRunning) {
      startTimer();
      startLocationTracking();
    } else {
      stopTimer();
      positionStream.pause();
    }
  }

  Future<void> stopRun() async {
    stopTimer(); // 타이머 멈추기
    positionStream.cancel(); // 위치 추적 멈추기

    // 현재 기록을 Firebase에 저장
    await saveRunToFirebase();

    // 현재 기록을 보여줌
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300, // 지도 높이 설정
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: routePoints.isNotEmpty ? routePoints.first : initialLatLng,
                    zoom: 16,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: routePoints,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                  markers: {
                    if (routePoints.isNotEmpty)
                      Marker(
                        markerId: const MarkerId('start'),
                        position: routePoints.first,
                        infoWindow: const InfoWindow(title: '출발 지점'),
                      ),
                    if (routePoints.length > 1)
                      Marker(
                        markerId: const MarkerId('end'),
                        position: routePoints.last,
                        infoWindow: const InfoWindow(title: '종료 지점'),
                      ),
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총 거리: ${totalDistance.toStringAsFixed(2)} km'),
                    Text('평균 속도: ${(totalDistance / (elapsedSeconds / 1000)).toStringAsFixed(2)} m/s'),
                    Text('총 운동 시간: ${Duration(seconds: elapsedSeconds).inMinutes}분 ${elapsedSeconds % 60}초'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
    );

    // 기록 초기화
    setState(() {
      isRunning = false; // 상태 업데이트
      widget.onRunningStateChange(isRunning);
      currentSpeed = 0.0; // 속도 초기화
      elapsedSeconds = 0; // 시간 초기화
      totalDistance = 0.0; // 거리 초기화
      routePoints.clear(); // 경로 초기화
    });
  }

  Future<void> saveRunToFirebase() async {
    final userId = FirebaseAuth.instance.currentUser!.uid; //UID(user id)를 가져와 Firestore 저장할 때 사용하기
    // 경로 데이터를 저장 가능한 형태로 변환
    final List<Map<String, double>> routeData = routePoints
        .map((point) => {'latitude': point.latitude, 'longitude': point.longitude})
        .toList();

    final runRecord = {
      'distance': totalDistance.toStringAsFixed(2),
      'time': elapsedSeconds,
      'speed': currentSpeed,
      'timestamp': Timestamp.now(),
      'route': routeData, // 경로 데이터 추가
    };

    // Firestore에 저장
    await FirebaseFirestore.instance
        .collection('users') //컬렉션 1번
        .doc(userId) //유저아이디를 가져와서 유저 구분해서 저장하기
        .collection('runs') // 컬렉션 2번(users안에있는 컬랙션)
        .add(runRecord) // 달리기 기록 저장하기
        ;
    print('운동 기록 및 경로가 Firebase에 저장되었습니다.');
  }

  @override
  void dispose() {
    positionStream.cancel();
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: initialLatLng,
              zoom: 16,
            ),
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: routePoints,
                color: Colors.blue,
                width: 5,
              ),
            },
            onMapCreated: (controller) {
              mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text('이동 거리: ${totalDistance.toStringAsFixed(2)} km'),
                    Text('현재 속도: ${currentSpeed.toStringAsFixed(2)} m/s'), // m/s로 변경
                    Text('운동 시간: ${elapsedSeconds}s'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: toggleRun,
                          child: Text(isRunning ? '일시정지' : '시작'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: stopRun,
                          child: const Text('종료'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}