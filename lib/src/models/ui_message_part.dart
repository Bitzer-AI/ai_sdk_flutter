import 'package:equatable/equatable.dart';

/// Base class for all UI message parts
abstract class UIMessagePart extends Equatable {
  const UIMessagePart();

  /// Type identifier for the part
  String get type;

  /// Converts the part to JSON
  Map<String, dynamic> toJson();

  /// Factory method to create a part from JSON
  static UIMessagePart fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'text':
        return TextUIPart.fromJson(json);
      case 'reasoning':
        return ReasoningUIPart.fromJson(json);
      case 'file':
        return FileUIPart.fromJson(json);
      case 'step-start':
        return const StepStartUIPart();
      case 'source-url':
        return SourceUrlUIPart.fromJson(json);
      case 'source-document':
        return SourceDocumentUIPart.fromJson(json);
      default:
        // Handle tool parts (tool-*)
        if (type.startsWith('tool-')) {
          return ToolUIPart.fromJson(json);
        }
        // Handle data parts (data-*)
        if (type.startsWith('data-')) {
          return DataUIPart.fromJson(json);
        }
        // Unknown type - return as generic data
        return UnknownUIPart(type: type, data: json);
    }
  }
}

/// Text content part of a message
class TextUIPart extends UIMessagePart {
  @override
  final String type = 'text';

  final String text;
  final TextState? state;
  final Map<String, dynamic>? providerMetadata;

  const TextUIPart({
    required this.text,
    this.state,
    this.providerMetadata,
  });

  TextUIPart copyWith({
    String? text,
    TextState? state,
    Map<String, dynamic>? providerMetadata,
  }) {
    return TextUIPart(
      text: text ?? this.text,
      state: state ?? this.state,
      providerMetadata: providerMetadata ?? this.providerMetadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      if (state != null) 'state': state!.name,
      if (providerMetadata != null) 'providerMetadata': providerMetadata,
    };
  }

  factory TextUIPart.fromJson(Map<String, dynamic> json) {
    return TextUIPart(
      text: json['text'] as String,
      state: json['state'] != null
          ? TextState.values.firstWhere(
              (s) => s.name == json['state'],
              orElse: () => TextState.done,
            )
          : null,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, text, state, providerMetadata];
}

/// Text streaming state
enum TextState { streaming, done }

/// Reasoning content part (for models with chain-of-thought)
class ReasoningUIPart extends UIMessagePart {
  @override
  final String type = 'reasoning';

  final String text;
  final TextState? state;
  final Map<String, dynamic>? providerMetadata;

  const ReasoningUIPart({
    required this.text,
    this.state,
    this.providerMetadata,
  });

  ReasoningUIPart copyWith({
    String? text,
    TextState? state,
    Map<String, dynamic>? providerMetadata,
  }) {
    return ReasoningUIPart(
      text: text ?? this.text,
      state: state ?? this.state,
      providerMetadata: providerMetadata ?? this.providerMetadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      if (state != null) 'state': state!.name,
      if (providerMetadata != null) 'providerMetadata': providerMetadata,
    };
  }

  factory ReasoningUIPart.fromJson(Map<String, dynamic> json) {
    return ReasoningUIPart(
      text: json['text'] as String,
      state: json['state'] != null
          ? TextState.values.firstWhere(
              (s) => s.name == json['state'],
              orElse: () => TextState.done,
            )
          : null,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, text, state, providerMetadata];
}

/// Tool invocation part
class ToolUIPart extends UIMessagePart {
  @override
  final String type; // e.g., 'tool-weatherTool'

  final String toolCallId;
  final ToolCallState state;
  final dynamic input;
  final dynamic output;
  final String? errorText;
  final bool? providerExecuted;
  final String? title;
  final Map<String, dynamic>? callProviderMetadata;

  const ToolUIPart({
    required this.type,
    required this.toolCallId,
    required this.state,
    this.input,
    this.output,
    this.errorText,
    this.providerExecuted,
    this.title,
    this.callProviderMetadata,
  });

  ToolUIPart copyWith({
    String? type,
    String? toolCallId,
    ToolCallState? state,
    dynamic input,
    dynamic output,
    String? errorText,
    bool? providerExecuted,
    String? title,
    Map<String, dynamic>? callProviderMetadata,
  }) {
    return ToolUIPart(
      type: type ?? this.type,
      toolCallId: toolCallId ?? this.toolCallId,
      state: state ?? this.state,
      input: input ?? this.input,
      output: output ?? this.output,
      errorText: errorText ?? this.errorText,
      providerExecuted: providerExecuted ?? this.providerExecuted,
      title: title ?? this.title,
      callProviderMetadata: callProviderMetadata ?? this.callProviderMetadata,
    );
  }

  /// Gets the tool name from the type (e.g., 'tool-weatherTool' -> 'weatherTool')
  String get toolName => type.substring('tool-'.length);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'toolCallId': toolCallId,
      'state': state.name.replaceAll('_', '-'),
      if (input != null) 'input': input,
      if (output != null) 'output': output,
      if (errorText != null) 'errorText': errorText,
      if (providerExecuted != null) 'providerExecuted': providerExecuted,
      if (title != null) 'title': title,
      if (callProviderMetadata != null)
        'callProviderMetadata': callProviderMetadata,
    };
  }

  factory ToolUIPart.fromJson(Map<String, dynamic> json) {
    return ToolUIPart(
      type: json['type'] as String,
      toolCallId: json['toolCallId'] as String,
      state: ToolCallState.values.firstWhere(
        (s) => s.name == json['state'].toString().replaceAll('-', '_'),
        orElse: () => ToolCallState.input_streaming,
      ),
      input: json['input'],
      output: json['output'],
      errorText: json['errorText'] as String?,
      providerExecuted: json['providerExecuted'] as bool?,
      title: json['title'] as String?,
      callProviderMetadata:
          json['callProviderMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        type,
        toolCallId,
        state,
        input,
        output,
        errorText,
        providerExecuted,
        title,
        callProviderMetadata,
      ];
}

/// Tool call state enumeration
enum ToolCallState {
  input_streaming,
  input_available,
  output_available,
  output_error,
  output_denied,
}

/// File attachment part
class FileUIPart extends UIMessagePart {
  @override
  final String type = 'file';

  final String url;
  final String mediaType;
  final String? filename;
  final Map<String, dynamic>? providerMetadata;

  const FileUIPart({
    required this.url,
    required this.mediaType,
    this.filename,
    this.providerMetadata,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'mediaType': mediaType,
      if (filename != null) 'filename': filename,
      if (providerMetadata != null) 'providerMetadata': providerMetadata,
    };
  }

  factory FileUIPart.fromJson(Map<String, dynamic> json) {
    return FileUIPart(
      url: json['url'] as String,
      mediaType: json['mediaType'] as String,
      filename: json['filename'] as String?,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, url, mediaType, filename, providerMetadata];
}

/// Source URL part (for RAG)
class SourceUrlUIPart extends UIMessagePart {
  @override
  final String type = 'source-url';

  final String sourceId;
  final String url;
  final String? title;
  final Map<String, dynamic>? providerMetadata;

  const SourceUrlUIPart({
    required this.sourceId,
    required this.url,
    this.title,
    this.providerMetadata,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sourceId': sourceId,
      'url': url,
      if (title != null) 'title': title,
      if (providerMetadata != null) 'providerMetadata': providerMetadata,
    };
  }

  factory SourceUrlUIPart.fromJson(Map<String, dynamic> json) {
    return SourceUrlUIPart(
      sourceId: json['sourceId'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      providerMetadata: json['providerMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [type, sourceId, url, title, providerMetadata];
}

/// Source document part (for RAG)
class SourceDocumentUIPart extends UIMessagePart {
  @override
  final String type = 'source-document';

  final String sourceId;
  final String mediaType;
  final String title;
  final String? filename;
  final Map<String, dynamic>? providerMetadata;

  const SourceDocumentUIPart({
    required this.sourceId,
    required this.mediaType,
    required this.title,
    this.filename,
    this.providerMetadata,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sourceId': sourceId,
      'mediaType': mediaType,
      'title': title,
      if (filename != null) 'filename': filename,
      if (providerMetadata != null) 'providerMetadata': providerMetadata,
    };
  }

  factory SourceDocumentUIPart.fromJson(Map<String, dynamic> json) {
    return SourceDocumentUIPart(
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

/// Custom data part (data-*)
class DataUIPart extends UIMessagePart {
  @override
  final String type; // e.g., 'data-weather'

  final String? id;
  final dynamic data;

  const DataUIPart({
    required this.type,
    this.id,
    required this.data,
  });

  /// Gets the data type name (e.g., 'data-weather' -> 'weather')
  String get dataName => type.substring('data-'.length);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (id != null) 'id': id,
      'data': data,
    };
  }

  factory DataUIPart.fromJson(Map<String, dynamic> json) {
    return DataUIPart(
      type: json['type'] as String,
      id: json['id'] as String?,
      data: json['data'],
    );
  }

  @override
  List<Object?> get props => [type, id, data];
}

/// Step start boundary part
class StepStartUIPart extends UIMessagePart {
  @override
  final String type = 'step-start';

  const StepStartUIPart();

  @override
  Map<String, dynamic> toJson() {
    return {'type': type};
  }

  @override
  List<Object?> get props => [type];
}

/// Unknown part type (fallback)
class UnknownUIPart extends UIMessagePart {
  @override
  final String type;

  final Map<String, dynamic> data;

  const UnknownUIPart({
    required this.type,
    required this.data,
  });

  @override
  Map<String, dynamic> toJson() => data;

  @override
  List<Object?> get props => [type, data];
}
