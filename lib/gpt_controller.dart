import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// 전역변수로 위치 저장
LatLng globalCurrentLocation = LatLng(0.0, 0.0);  // 초기값으로 0.0, 0.0 설정

// 현재 위치를 추적하고 globalCurrentLocation 업데이트


Future<Position> getCurrentLocation() async {
  // 위치 권한 요청
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    // 위치 정보 얻기
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  } else {
    throw Exception('Location permission denied');
  }
}

// 현재 위치를 받아 ChatGPT에 요청
Future<String> generateResponse(String input, double latitude, double longitude) async {
  // 위치 정보를 포함한 프롬프트 생성
  String prompt = "$input\nYour location: latitude $latitude, longitude $longitude.";

  String token = "";

  var response = await http.post(
    Uri.parse("https://api.openai.com/v1/chat/completions"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": token,
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",  // 모델을 명시
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": prompt}  // 위치를 포함한 프롬프트
      ],
      "temperature": 0.5,
      "max_tokens": 400,
      "top_p": 1,
      "frequency_penalty": 0,
      "presence_penalty": 0
    }),
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    String text = data["choices"][0]["message"]["content"].toString().trim();
    return text;
  } else {
    throw Exception("Failed to generate response: ${response.statusCode}");
  }
}