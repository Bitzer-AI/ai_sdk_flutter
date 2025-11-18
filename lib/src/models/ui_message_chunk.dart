import 'package:equatable/equatable.dart';
import 'ui_message_part.dart';

/// Represents a streaming chunk from the AI SDK data stream protocol
abstract class UIMessageChunk extends Equatable {
  const UIMessageChunk();

  /// Type identifier for the chunk
  String get type;

  /// Factory to create chunk from JSON
  static UIMessageChunk fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'text-start':
        return TextStartChunk.fromJson(json);
      case 'text-delta':
        return TextDeltaChunk.fromJson(json);
      case 'text-end':
        return TextEndChunk.fromJson(json);
      case 'reasoning-start':
        return ReasoningStartChunk.fromJson(json);
      case 'reasoning-delta':
        return ReasoningDeltaChunk.fromJson(json);
      case 'reasoning-end':
        return ReasoningEndChunk.fromJson(json);
      case 'tool-input-start':
        return ToolInputStartChunk.fromJson(json);
      case 'tool-input-delta':
        return ToolInputDeltaChunk.fromJson(json);
      case 'tool-input-available':
        return ToolInputAvailableChunk.fromJson(json);
      case 'tool-output-available':
        return ToolOutputAvailableChunk.fromJson(json);
      case 'source-url':
        return SourceUrlChunk.fromJson(json);
      case 'source-document':
        return SourceDocumentChunk.fromJson(json);
      case 'file':
        return FileChunk.fromJson(json);
      case 'start-step':
        return const StartStepChunk();
      case 'finish-step':
        return const FinishStepChunk();
      case 'start':
        return StartChunk.fromJson(json);
      case 'finish':
        return FinishChunk.fromJson(json);
      case 'error':
        return ErrorChunk.fromJson(json);
      case 'abort':
        return const AbortChunk();
      case 'message-metadata':
        return MessageMetadataChunk.fromJson(json);
      default:
        // Handle data-* chunks
        if (type.startsWith('data-')) {
          return DataChunk.fromJson(json);
        }
        return UnknownChunk(type: type, data: json);
    }
  }
}

// Text chunks
class TextStartChunk extends UIMessageChunk {
  @override
  final String type = 'text-start';
  final String id;
  final Map<String, dynamic>? providerMetadata;

  const TextStartChunk({required this.id, this.providerMetadata});

  factory TextStartChunk.fromJson(Map<String, dynamic> json) {
    return TextStartChunk(
      id: json['id'] as String,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, id, providerMetadata];
}

class TextDeltaChunk extends UIMessageChunk {
  @override
  final String type = 'text-delta';
  final String id;
  final String delta;
  final Map<String, dynamic>? providerMetadata;

  const TextDeltaChunk({
    required this.id,
    required this.delta,
    this.providerMetadata,
  });

  factory TextDeltaChunk.fromJson(Map<String, dynamic> json) {
    return TextDeltaChunk(
      id: json['id'] as String,
      delta: json['delta'] as String,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, id, delta, providerMetadata];
}

class TextEndChunk extends UIMessageChunk {
  @override
  final String type = 'text-end';
  final String id;
  final Map<String, dynamic>? providerMetadata;

  const TextEndChunk({required this.id, this.providerMetadata});

  factory TextEndChunk.fromJson(Map<String, dynamic> json) {
    return TextEndChunk(
      id: json['id'] as String,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, id, providerMetadata];
}

// Reasoning chunks
class ReasoningStartChunk extends UIMessageChunk {
  @override
  final String type = 'reasoning-start';
  final String id;
  final Map<String, dynamic>? providerMetadata;

  const ReasoningStartChunk({required this.id, this.providerMetadata});

  factory ReasoningStartChunk.fromJson(Map<String, dynamic> json) {
    return ReasoningStartChunk(
      id: json['id'] as String,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, id, providerMetadata];
}

class ReasoningDeltaChunk extends UIMessageChunk {
  @override
  final String type = 'reasoning-delta';
  final String id;
  final String delta;
  final Map<String, dynamic>? providerMetadata;

  const ReasoningDeltaChunk({
    required this.id,
    required this.delta,
    this.providerMetadata,
  });

  factory ReasoningDeltaChunk.fromJson(Map<String, dynamic> json) {
    return ReasoningDeltaChunk(
      id: json['id'] as String,
      delta: json['delta'] as String,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, id, delta, providerMetadata];
}

class ReasoningEndChunk extends UIMessageChunk {
  @override
  final String type = 'reasoning-end';
  final String id;
  final Map<String, dynamic>? providerMetadata;

  const ReasoningEndChunk({required this.id, this.providerMetadata});

  factory ReasoningEndChunk.fromJson(Map<String, dynamic> json) {
    return ReasoningEndChunk(
      id: json['id'] as String,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, id, providerMetadata];
}

// Tool chunks
class ToolInputStartChunk extends UIMessageChunk {
  @override
  final String type = 'tool-input-start';
  final String toolCallId;
  final String toolName;
  final String? title;
  final bool? dynamic;

  const ToolInputStartChunk({
    required this.toolCallId,
    required this.toolName,
    this.title,
    this.dynamic,
  });

  factory ToolInputStartChunk.fromJson(Map<String, dynamic> json) {
    return ToolInputStartChunk(
      toolCallId: json['toolCallId'] as String,
      toolName: json['toolName'] as String,
      title: json['title'] as String?,
      dynamic: json['dynamic'] as bool?,
    );
  }

  @override
  List<Object?> get props => [type, toolCallId, toolName, title, dynamic];
}

class ToolInputDeltaChunk extends UIMessageChunk {
  @override
  final String type = 'tool-input-delta';
  final String toolCallId;
  final String inputTextDelta;

  const ToolInputDeltaChunk({
    required this.toolCallId,
    required this.inputTextDelta,
  });

  factory ToolInputDeltaChunk.fromJson(Map<String, dynamic> json) {
    return ToolInputDeltaChunk(
      toolCallId: json['toolCallId'] as String,
      inputTextDelta: json['inputTextDelta'] as String,
    );
  }

  @override
  List<Object?> get props => [type, toolCallId, inputTextDelta];
}

class ToolInputAvailableChunk extends UIMessageChunk {
  @override
  final String type = 'tool-input-available';
  final String toolCallId;
  final String toolName;
  final dynamic input;
  final Map<String, dynamic>? callProviderMetadata;

  const ToolInputAvailableChunk({
    required this.toolCallId,
    required this.toolName,
    required this.input,
    this.callProviderMetadata,
  });

  factory ToolInputAvailableChunk.fromJson(Map<String, dynamic> json) {
    return ToolInputAvailableChunk(
      toolCallId: json['toolCallId'] as String,
      toolName: json['toolName'] as String,
      input: json['input'],
      callProviderMetadata:
          json['callProviderMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props =>
      [type, toolCallId, toolName, input, callProviderMetadata];
}

class ToolOutputAvailableChunk extends UIMessageChunk {
  @override
  final String type = 'tool-output-available';
  final String toolCallId;
  final dynamic output;

  const ToolOutputAvailableChunk({
    required this.toolCallId,
    required this.output,
  });

  factory ToolOutputAvailableChunk.fromJson(Map<String, dynamic> json) {
    return ToolOutputAvailableChunk(
      toolCallId: json['toolCallId'] as String,
      output: json['output'],
    );
  }

  @override
  List<Object?> get props => [type, toolCallId, output];
}

// Source chunks
class SourceUrlChunk extends UIMessageChunk {
  @override
  final String type = 'source-url';
  final String sourceId;
  final String url;
  final String? title;
  final Map<String, dynamic>? providerMetadata;

  const SourceUrlChunk({
    required this.sourceId,
    required this.url,
    this.title,
    this.providerMetadata,
  });

  factory SourceUrlChunk.fromJson(Map<String, dynamic> json) {
    return SourceUrlChunk(
      sourceId: json['sourceId'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, sourceId, url, title, providerMetadata];
}

class SourceDocumentChunk extends UIMessageChunk {
  @override
  final String type = 'source-document';
  final String sourceId;
  final String mediaType;
  final String title;
  final String? filename;
  final Map<String, dynamic>? providerMetadata;

  const SourceDocumentChunk({
    required this.sourceId,
    required this.mediaType,
    required this.title,
    this.filename,
    this.providerMetadata,
  });

  factory SourceDocumentChunk.fromJson(Map<String, dynamic> json) {
    return SourceDocumentChunk(
      sourceId: json['sourceId'] as String,
      mediaType: json['mediaType'] as String,
      title: json['title'] as String,
      filename: json['filename'] as String?,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props =>
      [type, sourceId, mediaType, title, filename, providerMetadata];
}

// File chunk
class FileChunk extends UIMessageChunk {
  @override
  final String type = 'file';
  final String url;
  final String mediaType;
  final Map<String, dynamic>? providerMetadata;

  const FileChunk({
    required this.url,
    required this.mediaType,
    this.providerMetadata,
  });

  factory FileChunk.fromJson(Map<String, dynamic> json) {
    return FileChunk(
      url: json['url'] as String,
      mediaType: json['mediaType'] as String,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, url, mediaType, providerMetadata];
}

// Data chunk (custom data types)
class DataChunk extends UIMessageChunk {
  @override
  final String type; // e.g., 'data-weather'
  final String? id;
  final dynamic data;
  final bool? transient;

  const DataChunk({
    required this.type,
    this.id,
    required this.data,
    this.transient,
  });

  factory DataChunk.fromJson(Map<String, dynamic> json) {
    return DataChunk(
      type: json['type'] as String,
      id: json['id'] as String?,
      data: json['data'],
      transient: json['transient'] as bool?,
    );
  }

  @override
  List<Object?> get props => [type, id, data, transient];
}

// Step chunks
class StartStepChunk extends UIMessageChunk {
  @override
  final String type = 'start-step';

  const StartStepChunk();

  @override
  List<Object?> get props => [type];
}

class FinishStepChunk extends UIMessageChunk {
  @override
  final String type = 'finish-step';

  const FinishStepChunk();

  @override
  List<Object?> get props => [type];
}

// Message lifecycle chunks
class StartChunk extends UIMessageChunk {
  @override
  final String type = 'start';
  final String? messageId;
  final Map<String, dynamic>? messageMetadata;

  const StartChunk({this.messageId, this.messageMetadata});

  factory StartChunk.fromJson(Map<String, dynamic> json) {
    return StartChunk(
      messageId: json['messageId'] as String?,
      messageMetadata: json['messageMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, messageId, messageMetadata];
}

class FinishChunk extends UIMessageChunk {
  @override
  final String type = 'finish';
  final String? finishReason;
  final Map<String, dynamic>? messageMetadata;

  const FinishChunk({this.finishReason, this.messageMetadata});

  factory FinishChunk.fromJson(Map<String, dynamic> json) {
    return FinishChunk(
      finishReason: json['finishReason'] as String?,
      messageMetadata: json['messageMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, finishReason, messageMetadata];
}

// Error chunk
class ErrorChunk extends UIMessageChunk {
  @override
  final String type = 'error';
  final String errorText;

  const ErrorChunk({required this.errorText});

  factory ErrorChunk.fromJson(Map<String, dynamic> json) {
    return ErrorChunk(errorText: json['errorText'] as String);
  }

  @override
  List<Object?> get props => [type, errorText];
}

// Abort chunk
class AbortChunk extends UIMessageChunk {
  @override
  final String type = 'abort';

  const AbortChunk();

  @override
  List<Object?> get props => [type];
}

// Message metadata chunk
class MessageMetadataChunk extends UIMessageChunk {
  @override
  final String type = 'message-metadata';
  final Map<String, dynamic> messageMetadata;

  const MessageMetadataChunk({required this.messageMetadata});

  factory MessageMetadataChunk.fromJson(Map<String, dynamic> json) {
    return MessageMetadataChunk(
      messageMetadata: json['messageMetadata'] as Map<String, dynamic>,
    );
  }

  @override
  List<Object?> get props => [type, messageMetadata];
}

// Unknown chunk (fallback)
class UnknownChunk extends UIMessageChunk {
  @override
  final String type;
  final Map<String, dynamic> data;

  const UnknownChunk({required this.type, required this.data});

  @override
  List<Object?> get props => [type, data];
}
