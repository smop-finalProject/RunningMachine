import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Firebase 초기화 라이브러리
import 'package:lastsub/screen/auth_screen.dart';  // AuthScreen 화면
import 'firebase_options.dart';  // firebase_options.dart 파일 임포트
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'ab81cdf2604dc76d44dd51e9d1d4467c',

  );

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // 현재 플랫폼에 맞는 Firebase 설정
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthScreen(),  // Firebase 초기화 후 AuthScreen을 시작 화면으로 설정
    ),
  );
}