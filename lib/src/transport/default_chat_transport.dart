import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ui_message.dart';
import '../models/ui_message_chunk.dart';
import 'chat_transport.dart';

/// Default HTTP-based chat transport using the AI SDK data stream protocol.
/// 
/// This transport sends messages via HTTP POST and receives streaming
/// responses in Server-Sent Events (SSE) format with JSON chunks.
class DefaultChatTransport implements ChatTransport {
  final String api;
  final http.Client? httpClient;
  final Map<String, String>? defaultHeaders;
  final Map<String, dynamic>? defaultBody;
  
  /// Optional function to prepare the request before sending
  final Map<String, dynamic>? Function({
    required String id,
    required List<UIMessage> messages,
    required String trigger,
    String? messageId,
  })? prepareSendMessagesRequest;

  /// Optional function to prepare the reconnection request
  final Map<String, dynamic>? Function({
    required String chatId,
  })? prepareReconnectToStreamRequest;

  DefaultChatTransport({
    this.api = '/api/chat',
    this.httpClient,
    this.defaultHeaders,
    this.defaultBody,
    this.prepareSendMessagesRequest,
    this.prepareReconnectToStreamRequest,
  });

  @override
  Stream<UIMessageChunk> sendMessages({
    required String trigger,
    required String chatId,
    String? messageId,
    required List<UIMessage> messages,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? metadata,
  }) async* {
    final client = httpClient ?? http.Client();
    
    try {
      // Prepare request body
      Map<String, dynamic> requestBody;
      
      if (prepareSendMessagesRequest != null) {
        final customBody = prepareSendMessagesRequest!(
          id: chatId,
          messages: messages,
          trigger: trigger,
          messageId: messageId,
        );
        requestBody = customBody ?? {};
      } else {
        requestBody = {
          'id': chatId,
          'messages': messages.map((m) => m.toJson()).toList(),
          'trigger': trigger,
          if (messageId != null) 'messageId': messageId,
        };
      }

      // Merge with additional body data
      if (body != null) {
        requestBody.addAll(body);
      }
      if (defaultBody != null) {
        requestBody.addAll(defaultBody!);
      }
      if (metadata != null) {
        requestBody['metadata'] = metadata;
      }

      // Prepare headers
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        if (defaultHeaders != null) ...defaultHeaders!,
        if (headers != null) ...headers,
      };

      // Make request
      final request = http.Request('POST', Uri.parse(api))
        ..headers.addAll(requestHeaders)
        ..body = jsonEncode(requestBody);

      final response = await client.send(request);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase ?? errorBody}',
        );
      }

      // Parse SSE stream
      yield* _parseSSEStream(response.stream);
    } catch (e) {
      if (httpClient == null) {
        client.close();
      }
      rethrow;
    }
  }

  @override
  Future<Stream<UIMessageChunk>?> reconnectToStream({
    required String chatId,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? metadata,
  }) async {
    final client = httpClient ?? http.Client();
    
    try {
      // Prepare request body
      Map<String, dynamic> requestBody;
      
      if (prepareReconnectToStreamRequest != null) {
        final customBody = prepareReconnectToStreamRequest!(chatId: chatId);
        requestBody = customBody ?? {};
      } else {
        requestBody = {
          'id': chatId,
          'reconnect': true,
        };
      }

      // Merge with additional body data
      if (body != null) {
        requestBody.addAll(body);
      }
      if (defaultBody != null) {
        requestBody.addAll(defaultBody!);
      }
      if (metadata != null) {
        requestBody['metadata'] = metadata;
      }

      // Prepare headers
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        if (defaultHeaders != null) ...defaultHeaders!,
        if (headers != null) ...headers,
      };

      // Make request
      final request = http.Request('POST', Uri.parse(api))
        ..headers.addAll(requestHeaders)
        ..body = jsonEncode(requestBody);

      final response = await client.send(request);

      // Return null if no active stream (405 or 404)
      if (response.statusCode == 404 || response.statusCode == 405) {
        if (httpClient == null) {
          client.close();
        }
        return null;
      }

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        if (httpClient == null) {
          client.close();
        }
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase ?? errorBody}',
        );
      }

      // Parse SSE stream
      return _parseSSEStream(response.stream);
    } catch (e) {
      if (httpClient == null) {
        client.close();
      }
      rethrow;
    }
  }

  /// Parses Server-Sent Events stream and yields UIMessageChunk objects
  Stream<UIMessageChunk> _parseSSEStream(Stream<List<int>> byteStream) async* {
    final lines = byteStream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      // Skip empty lines and comments
      if (line.trim().isEmpty || line.startsWith(':')) {
        continue;
      }

      // Parse SSE format: "data: {json}"
      if (line.startsWith('data: ')) {
        final data = line.substring(6); // Remove "data: " prefix

        // Check for stream termination
        if (data == '[DONE]') {
          break;
        }

        try {
          // Parse JSON chunk
          final json = jsonDecode(data) as Map<String, dynamic>;
          final chunk = UIMessageChunk.fromJson(json);
          yield chunk;
        } catch (e) {
          // Skip malformed chunks
          continue;
        }
      }
    }
  }

  @override
  Future<void> close() async {
    // Client is closed by the caller if it was provided externally
    // Internal client is closed in the stream handler
  }
}
