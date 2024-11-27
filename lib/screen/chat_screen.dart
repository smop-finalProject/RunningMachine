import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:smop_final/gpt_controller.dart'; // gpt_controller.dart를 import 합니다.

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool isLoading = false;

  // 메시지를 보내는 함수
  void _sendMessage(String text) async {
    setState(() {
      _messages.add("You: $text");
      isLoading = true;
    });

    try {
      // 위치 정보 받기
      Position position = await getCurrentLocation();
      double latitude = position.latitude;
      double longitude = position.longitude;

      // OpenAI API 호출
      String response = await generateResponse(text, latitude, longitude);

      setState(() {
        _messages.add("Bot: $response");
      });
    } catch (e) {
      setState(() {
        _messages.add("Bot: Error - ${e.toString()}");
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "메시지를 입력하세요!",
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    _sendMessage(_controller.text);
                  }
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}