import 'package:flutter/material.dart';

class ChatMessageWidget extends StatelessWidget {
  final String userMessage;
  final String botMessage;
  final MessageType messageType;

  const ChatMessageWidget({
    required this.userMessage,
    required this.botMessage,
    required this.messageType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      color: messageType == MessageType.user
          ? const Color(0xff343541)
          : const Color(0xff444654),
      child: Row(
        children: [
          messageType == MessageType.user
              ? Container(
            margin: const EdgeInsets.only(right: 16),
            child: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          )
              : const CircleAvatar(
            backgroundColor: Color.fromRGBO(16, 163, 127, 1),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: messageType == MessageType.user
                      ? Text(
                    userMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                  )
                      : Text(
                    botMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

enum MessageType { user, bot }