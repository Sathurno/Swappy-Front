import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io'; // Para manejar archivos
import '../../../../constants.dart';
import '../../../models/chat_message.dart';

class Message extends StatelessWidget {
  final ChatMessage message;

  const Message({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    Widget messageContent(ChatMessage message) {
      switch (message.messageType) {
        case ChatMessageType.text:
          return Text(message.messageContent); // Muestra el texto
        case ChatMessageType.image:
          return Image.file(File(message.messageContent)); // Muestra la imagen
        case ChatMessageType.audio:
          return Text(
              "Audio: ${message.messageContent}"); // Muestra texto para el audio
        case ChatMessageType.video:
          return Text(
              "Video: ${message.messageContent}"); // Muestra texto para el video
        default:
          return const SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: Row(
        mainAxisAlignment:
            message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isSender)
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage("assets/images/user_2.png"),
            ),
          const SizedBox(width: kDefaultPadding / 2),
          messageContent(message),
          if (message.isSender) ...[
            const SizedBox(width: kDefaultPadding / 2),
            const Icon(Icons.done,
                color: kPrimaryColor), // Icono de mensaje enviado
          ],
        ],
      ),
    );
  }
}
