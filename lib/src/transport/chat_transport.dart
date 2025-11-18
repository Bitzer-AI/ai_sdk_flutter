import '../models/ui_message.dart';
import '../models/ui_message_chunk.dart';

/// Transport interface for handling chat message communication and streaming.
///
/// Similar to AI SDK's ChatTransport interface, this provides control over
/// how messages are sent to API endpoints and how responses are processed.
abstract class ChatTransport {
  /// Sends messages to the chat API endpoint and returns a streaming response.
  ///
  /// [trigger] - Type of message submission ('submit-message' or 'regenerate-message')
  /// [chatId] - Unique identifier for the chat session
  /// [messageId] - ID of the message to regenerate (for regenerate-message trigger)
  /// [messages] - Array of UI messages representing the conversation history
  /// [headers] - Additional HTTP headers to include in the request
  /// [body] - Additional JSON properties to include in the request body
  /// [metadata] - Custom metadata to attach to the request
  ///
  /// Returns a Stream of UIMessageChunk objects representing the streaming response.
  Stream<UIMessageChunk> sendMessages({
    required String trigger,
    required String chatId,
    String? messageId,
    required List<UIMessage> messages,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? metadata,
  });

  /// Reconnects to an existing streaming response for the specified chat session.
  ///
  /// This method is used to resume streaming when a connection is interrupted
  /// or when resuming a chat session.
  ///
  /// [chatId] - Unique identifier for the chat session to reconnect to
  /// [headers] - Additional HTTP headers to include in the reconnection request
  /// [body] - Additional JSON properties to include in the request body
  /// [metadata] - Custom metadata to attach to the request
  ///
  /// Returns a Stream of UIMessageChunk objects if an active stream is found,
  /// or null if no active stream exists.
  Future<Stream<UIMessageChunk>?> reconnectToStream({
    required String chatId,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? metadata,
  });

  /// Closes any open connections and cleans up resources
  Future<void> close();
}
