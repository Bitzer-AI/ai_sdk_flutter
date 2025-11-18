import 'dart:math';

/// Generates unique IDs similar to AI SDK's generateId
class IdGenerator {
  static final _random = Random.secure();
  static const _chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  /// Generates a random ID with optional prefix and size
  static String generate({String prefix = '', int size = 16}) {
    final buffer = StringBuffer(prefix);
    for (var i = 0; i < size; i++) {
      buffer.write(_chars[_random.nextInt(_chars.length)]);
    }
    return buffer.toString();
  }

  /// Generates a message ID
  static String generateMessageId() => generate(prefix: 'msg_', size: 16);

  /// Generates a chat ID
  static String generateChatId() => generate(prefix: 'chat_', size: 16);

  /// Generates a tool call ID
  static String generateToolCallId() => generate(prefix: 'call_', size: 16);
}
