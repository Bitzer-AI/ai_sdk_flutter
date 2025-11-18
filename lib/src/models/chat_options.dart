import 'ui_message.dart';
import 'ui_message_chunk.dart';

/// Callback invoked when a message is finished streaming.
typedef OnFinishCallback = void Function(UIMessage message);

/// Callback invoked when an error occurs.
typedef OnErrorCallback = void Function(Object error);

/// Callback invoked when a tool call is made.
typedef OnToolCallCallback = void Function(Map<String, dynamic> toolCall);

/// Callback invoked when data is received.
typedef OnDataCallback = void Function(UIMessageChunk chunk);

/// Configuration options for a Chat instance.
class ChatOptions {
  /// The unique identifier for the chat.
  final String id;

  /// Initial messages to populate the chat with.
  final List<UIMessage> initialMessages;

  /// Additional data to send with requests.
  final Map<String, dynamic>? body;

  /// Additional headers to send with requests.
  final Map<String, String>? headers;

  /// Callback invoked when a message is finished streaming.
  final OnFinishCallback? onFinish;

  /// Callback invoked when an error occurs.
  final OnErrorCallback? onError;

  /// Callback invoked when a tool call is made.
  final OnToolCallCallback? onToolCall;

  /// Callback invoked when data is received.
  final OnDataCallback? onData;

  /// Maximum number of automatic tool call roundtrips.
  final int maxToolRoundtrips;

  /// Maximum number of automatic retries on errors.
  final int maxRetries;

  /// Whether to send tool results automatically.
  final bool sendToolResults;

  const ChatOptions({
    required this.id,
    this.initialMessages = const [],
    this.body,
    this.headers,
    this.onFinish,
    this.onError,
    this.onToolCall,
    this.onData,
    this.maxToolRoundtrips = 0,
    this.maxRetries = 3,
    this.sendToolResults = true,
  });

  ChatOptions copyWith({
    String? id,
    List<UIMessage>? initialMessages,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    OnFinishCallback? onFinish,
    OnErrorCallback? onError,
    OnToolCallCallback? onToolCall,
    OnDataCallback? onData,
    int? maxToolRoundtrips,
    int? maxRetries,
    bool? sendToolResults,
  }) {
    return ChatOptions(
      id: id ?? this.id,
      initialMessages: initialMessages ?? this.initialMessages,
      body: body ?? this.body,
      headers: headers ?? this.headers,
      onFinish: onFinish ?? this.onFinish,
      onError: onError ?? this.onError,
      onToolCall: onToolCall ?? this.onToolCall,
      onData: onData ?? this.onData,
      maxToolRoundtrips: maxToolRoundtrips ?? this.maxToolRoundtrips,
      maxRetries: maxRetries ?? this.maxRetries,
      sendToolResults: sendToolResults ?? this.sendToolResults,
    );
  }
}
