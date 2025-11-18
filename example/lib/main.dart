import 'package:flutter/material.dart';
import 'package:ai_sdk_flutter/ai_sdk_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI SDK Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Chat _chat;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<UIMessage> _messages = [];
  ChatStatus _status = ChatStatus.ready;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  void _initChat() {
    // Initialize the chat with your API endpoint
    final transport = DefaultChatTransport(
      api: 'https://your-api-endpoint.com/api/chat', // Replace with your endpoint
    );

    final options = ChatOptions(
      id: IdGenerator.generateChatId(),
      onFinish: (message) {
        debugPrint('Message finished: ${message.id}');
      },
      onError: (error) {
        setState(() {
          _error = error.toString();
        });
      },
      onToolCall: (toolCall) {
        debugPrint('Tool called: ${toolCall['toolName']}');
      },
    );

    _chat = Chat(
      options: options,
      transport: transport,
    );

    // Listen to message updates
    _chat.messagesStream.listen((messages) {
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    });

    // Listen to status updates
    _chat.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });

    // Listen to errors
    _chat.errorStream.listen((error) {
      setState(() {
        _error = error.toString();
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    try {
      await _chat.sendMessage(text);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI SDK Flutter Example'),
        actions: [
          if (_status == ChatStatus.streaming)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () => _chat.stop(),
              tooltip: 'Stop streaming',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _error = null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('Start a conversation!'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          if (_status == ChatStatus.streaming)
            const LinearProgressIndicator(),
          _InputArea(
            controller: _controller,
            onSend: _sendMessage,
            enabled: _status != ChatStatus.streaming,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chat.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final UIMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: message.parts.map((part) => _buildPart(part)).toList(),
        ),
      ),
    );
  }

  Widget _buildPart(UIMessagePart part) {
    if (part is TextUIPart) {
      return Text(
        part.text,
        style: const TextStyle(fontSize: 16),
      );
    } else if (part is ToolUIPart) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔧 Tool: ${part.type}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (part.input != null) ...[
              const SizedBox(height: 4),
              Text('Input: ${part.input}'),
            ],
            if (part.output != null) ...[
              const SizedBox(height: 4),
              Text('Output: ${part.output}'),
            ],
            if (part.errorText != null) ...[
              const SizedBox(height: 4),
              Text(
                'Error: ${part.errorText}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      );
    } else if (part is ReasoningUIPart) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '💭 ${part.text}',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.purple.shade700,
          ),
        ),
      );
    } else if (part is FileUIPart) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.attach_file, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(part.filename ?? "file")),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  const _InputArea({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: enabled ? (_) => onSend() : null,
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.send),
            onPressed: enabled ? onSend : null,
          ),
        ],
      ),
    );
  }
}
