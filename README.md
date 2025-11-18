# AI SDK Flutter

A Flutter package that consumes Vercel AI SDK v5 streams, providing chat functionality, tool calling, and streaming capabilities for AI-powered applications.

## Features

- 🎯 **Type-Safe Message Handling**: Strongly-typed UIMessage and UIMessagePart models
- 🌊 **Streaming Support**: Full SSE (Server-Sent Events) streaming with data stream protocol
- 🔧 **Tool Calling**: Complete tool execution framework with state management
- 🔄 **Stream Resumption**: Resume interrupted streams automatically
- 📦 **Transport Layer**: Flexible HTTP transport with customization options
- 🎨 **Framework Agnostic**: Works with any Flutter state management solution

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ai_sdk_flutter: ^0.1.0
```

## Quick Start

```dart
import 'package:ai_sdk_flutter/ai_sdk_flutter.dart';

// Create a chat instance
final chat = Chat(
  chatId: 'my-chat-id',
  transport: DefaultChatTransport(
    api: 'https://your-api.com/api/chat',
  ),
);

// Listen to messages
chat.messagesStream.listen((messages) {
  print('Messages updated: ${messages.length}');
});

// Send a message
await chat.sendMessage(
  UIMessage.user(
    id: IdGenerator.generateMessageId(),
    text: 'Hello, AI!',
  ),
);
```

## Architecture

This package mirrors the Vercel AI SDK v5 architecture:

- **UIMessage**: Represents messages with support for text, tools, files, and custom data
- **ChatTransport**: Interface for sending messages and receiving streams
- **DefaultChatTransport**: HTTP-based transport with SSE support
- **Chat**: Main client for managing conversations and state

## Status

⚠️ **Work in Progress** - This package is currently under active development.

## Compatibility

- Dart SDK: >=3.0.0 <4.0.0
- Flutter: >=3.10.0

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## Related

- [Vercel AI SDK](https://sdk.vercel.ai/) - The original TypeScript implementation
- [AI SDK Documentation](https://sdk.vercel.ai/docs)


## Current Status

✅ **Completed Features:**
- Core data models (UIMessage, UIMessagePart, UIMessageChunk)
- Transport layer with HTTP/SSE support
- Chat client with streaming and state management
- Tool execution framework
- Example application
- Full test coverage with all tests passing

