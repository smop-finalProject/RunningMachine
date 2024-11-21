import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("홈 화면"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleFirebaseLogout(context), // Firebase 로그아웃 함수 호출
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "홈 화면",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),

              // Firebase 로그아웃 버튼
              ElevatedButton(
                onPressed: () => handleFirebaseLogout(context),
                child: const Text('파이어베이스 로그아웃'),
              ),

              const SizedBox(height: 20),

              // 카카오 로그아웃 버튼
              ElevatedButton(
                onPressed: () => handleKakaoLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700], // 카카오 스타일 색상
                  foregroundColor: Colors.black, // 텍스트 색상
                ),
                child: const Text('카카오 로그아웃'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Firebase 로그아웃 처리 함수
  Future<void> handleFirebaseLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase 로그아웃
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()), // AuthScreen으로 이동
            (route) => false,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase 로그아웃 실패')),
      );
    }
  }

  // Kakao 로그아웃 처리 함수
  Future<void> handleKakaoLogout(BuildContext context) async {
    try {
      await UserApi.instance.logout(); // Kakao 로그아웃
      print('로그아웃 성공, SDK에서 토큰 삭제');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()), // AuthScreen으로 이동
            (route) => false,
      );
    } catch (error) {
      print('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
  }
}