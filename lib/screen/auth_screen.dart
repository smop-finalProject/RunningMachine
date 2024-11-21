import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 제목 부분
            Center(
              child: Text(
                '맨발의 기봉이', // 여기에 앱의 이름을 넣으세요
                style: TextStyle(
                  fontSize: 40, // 폰트 크기
                  fontWeight: FontWeight.w800, // 폰트 굵기
                  color: Colors.black, // 텍스트 색상
                  fontFamily: 'CustomFont', // 커스텀 폰트
                ),
              ),
            ),
            const SizedBox(height: 30.0),

            // 로고 이미지
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Image.asset('assets/img/logo1.png'),
              ),
            ),
            const SizedBox(height: 16.0),

            // 구글 로그인 버튼
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 55.0),
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
            const SizedBox(height: 1.0),

            // 카카오 로그인 버튼
            ElevatedButton(
              onPressed: () => onKakaoLoginPress(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Image.asset(
                'assets/img/kakao_login.png',
                width: 300,
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
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

    try {
      // 이전 로그인 상태 초기화
      await googleSignIn.signOut();

      GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google sign-in cancelled by user.');
      }

      final GoogleSignInAuthentication? googleAuth =
      await account.authentication;
      if (googleAuth == null) {
        throw Exception('Google authentication failed.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // 로그인 성공 시 HomeScreen으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (error) {
      // 로그인 실패 시 Snackbar로 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('구글 로그인 실패')),
      );
    }
  }

  // 카카오 로그인 함수
  void onKakaoLoginPress(BuildContext context) async {
    try {
      var provider = OAuthProvider("oidc.runningmachine");
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      var credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken
      );
      FirebaseAuth.instance.signInWithCredential(credential);
      bool loginSuccess = await signWithKakao();
      if (loginSuccess) {
        // 로그인 성공 시 HomeScreen으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        throw Exception('Kakao login failed.');
      }
    } catch (error) {
      // 로그인 실패 시 Snackbar로 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오 로그인 실패')),
      );
    }
  }

  // 카카오 로그인 구현
  Future<bool> signWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
          return true;
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');
          if (error is PlatformException && error.code == 'CANCELED') {
            return false;
          }
        }
      }

      // 카카오톡 설치 안 되어 있거나 실패 시 카카오 계정으로 로그인
      await UserApi.instance.loginWithKakaoAccount();
      print('카카오 계정으로 로그인 성공');
      return true;
    } catch (error) {
      print('카카오 계정으로 로그인 실패 $error');
      return false;
    }
  }
}