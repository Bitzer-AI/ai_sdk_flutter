import 'package:equatable/equatable.dart';
import 'ui_message_part.dart';

/// Tool invocation state and data for rendering in the UI
class ToolInvocation extends Equatable {
  final String toolCallId;
  final String toolName;
  final ToolCallState state;
  final dynamic input;
  final dynamic output;
  final String? errorText;
  final bool? providerExecuted;
  final String? title;

  const ToolInvocation({
    required this.toolCallId,
    required this.toolName,
    required this.state,
    this.input,
    this.output,
    this.errorText,
    this.providerExecuted,
    this.title,
  });

  /// Creates a tool invocation from a ToolUIPart
  factory ToolInvocation.fromPart(ToolUIPart part) {
    return ToolInvocation(
      toolCallId: part.toolCallId,
      toolName: part.toolName,
      state: part.state,
      input: part.input,
      output: part.output,
      errorText: part.errorText,
      providerExecuted: part.providerExecuted,
      title: part.title,
    );
  }

  /// Whether the tool is currently streaming input
  bool get isInputStreaming => state == ToolCallState.input_streaming;

  /// Whether the tool has complete input
  bool get hasInputAvailable => state == ToolCallState.input_available;

  /// Whether the tool has output available
  bool get hasOutputAvailable => state == ToolCallState.output_available;

  /// Whether the tool encountered an error
  bool get hasError => state == ToolCallState.output_error;

  /// Whether the tool execution was denied
  bool get isDenied => state == ToolCallState.output_denied;

  ToolInvocation copyWith({
    String? toolCallId,
    String? toolName,
    ToolCallState? state,
    dynamic input,
    dynamic output,
    String? errorText,
    bool? providerExecuted,
    String? title,
  }) {
    return ToolInvocation(
      toolCallId: toolCallId ?? this.toolCallId,
      toolName: toolName ?? this.toolName,
      state: state ?? this.state,
      input: input ?? this.input,
      output: output ?? this.output,
      errorText: errorText ?? this.errorText,
      providerExecuted: providerExecuted ?? this.providerExecuted,
      title: title ?? this.title,
    );
  }

  @override
  List<Object?> get props => [
        toolCallId,
        toolName,
        state,
        input,
        output,
        errorText,
        providerExecuted,
        title,
      ];
}
