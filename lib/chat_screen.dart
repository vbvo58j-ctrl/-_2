import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final BluetoothChatService _chatService = BluetoothChatService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  
  String _connectionStatus = "غير متصل";
  final String _myUserId = "user_${DateTime.now().millisecondsSinceEpoch}";

  @override
  void initState() {
    super.initState();
    _chatService.onMessageReceived.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    String text = _controller.text;
    _chatService.sendMessage(_myUserId, text);
    
    setState(() {
      _messages.add(ChatMessage(
        senderId: _myUserId,
        text: text,
        timestamp: DateTime.now(),
      ));
    });
    
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54), // لون واتساب الرئيسي
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("واتساب بلوتوث", style: TextStyle(color: Colors.white)),
            Text(_connectionStatus, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_searching, color: Colors.white),
            onPressed: () => _chatService.scanAndConnect((status) {
              setState(() => _connectionStatus = status);
            }),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFECE5DD), // خلفية محادثات واتساب الشهيرة
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const SystemPadding(all: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  bool isMe = msg.senderId == _myUserId;
                  
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFFDCF8C6) : Colors.white, // ألوان فقاعات واتساب
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(msg.text, style: const TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "اكتب رسالة...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF075E54)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
