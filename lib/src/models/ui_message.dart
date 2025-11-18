import 'package:equatable/equatable.dart';
import 'ui_message_part.dart';

/// Represents a message in the chat UI, similar to Vercel AI SDK's UIMessage.
/// 
/// A message can be from the system, user, or assistant and contains
/// an array of parts representing different types of content.
class UIMessage extends Equatable {
  /// Unique identifier for the message
  final String id;

  /// Role of the message sender
  final MessageRole role;

  /// Array of message parts (text, tools, files, etc.)
  final List<UIMessagePart> parts;

  /// Optional metadata attached to the message
  final Map<String, dynamic>? metadata;

  const UIMessage({
    required this.id,
    required this.role,
    required this.parts,
    this.metadata,
  });

  /// Creates a user message with text content
  factory UIMessage.user({
    required String id,
    required String text,
    Map<String, dynamic>? metadata,
  }) {
    return UIMessage(
      id: id,
      role: MessageRole.user,
      parts: [TextUIPart(text: text)],
      metadata: metadata,
    );
  }

  /// Creates an assistant message with text content
  factory UIMessage.assistant({
    required String id,
    required String text,
    Map<String, dynamic>? metadata,
  }) {
    return UIMessage(
      id: id,
      role: MessageRole.assistant,
      parts: [TextUIPart(text: text, state: TextState.done)],
      metadata: metadata,
    );
  }

  /// Creates a system message with text content
  factory UIMessage.system({
    required String id,
    required String text,
    Map<String, dynamic>? metadata,
  }) {
    return UIMessage(
      id: id,
      role: MessageRole.system,
      parts: [TextUIPart(text: text)],
      metadata: metadata,
    );
  }

  /// Creates a copy of this message with updated fields
  UIMessage copyWith({
    String? id,
    MessageRole? role,
    List<UIMessagePart>? parts,
    Map<String, dynamic>? metadata,
  }) {
    return UIMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      parts: parts ?? this.parts,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts the message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'parts': parts.map((p) => p.toJson()).toList(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates a message from JSON
  factory UIMessage.fromJson(Map<String, dynamic> json) {
    return UIMessage(
      id: json['id'] as String,
      role: MessageRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      parts: (json['parts'] as List)
          .map((p) => UIMessagePart.fromJson(p as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, role, parts, metadata];
}

/// Message role enumeration
enum MessageRole {
  system,
  user,
  assistant,
}
