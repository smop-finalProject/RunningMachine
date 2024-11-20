import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:lastsub/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lastsub/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 로고 이미지
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Image.asset(
                  'assets/img/logo1.png',
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // 구글 로그인 버튼
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 55.0),
              width: 40, // 원하는 너비 설정
              height: 30, // 원하는 높이 설정
              child: ElevatedButton(
                onPressed: () => onGoogleLoginPress(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/img/g-logo.png',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 8),
                    const Text('구글로 로그인'),
                  ],
                ),
              ),
            ),
            // 카카오 로그인 버튼
            ElevatedButton(
              onPressed: () => onKakaoLoginPress(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                elevation: 0,
                // 그림자 제거
                padding: const EdgeInsets.all(8),
                // 버튼 크기 조정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Image.asset(
                'assets/img/kakao_login.png', // 로고 이미지 경로
                width: 300, // 원하는 크기로 조정
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 구글 로그인 함수
  void onGoogleLoginPress(BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    try {
      GoogleSignInAccount? account = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await account
          ?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );

      print(account);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('구글 로그인 실패')),
      );
    }
  }

  // 카카오 로그인 함수
  void onKakaoLoginPress(BuildContext context) async {
    try {
      await signWithKakao();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오 로그인 실패')),
      );
    }
  }

  // 카카오 로그인 구현
  Future<void> signWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }
}