import 'dart:async';

/// Represents a tool that can be called by the AI.
///
/// Tools are functions that the AI can invoke to perform actions
/// or retrieve information.
abstract class Tool<TParameters, TResult> {
  /// Unique identifier for the tool
  final String name;

  /// Human-readable description of what the tool does
  final String description;

  /// JSON schema for the tool's parameters
  final Map<String, dynamic> parametersSchema;

  const Tool({
    required this.name,
    required this.description,
    required this.parametersSchema,
  });

  /// Execute the tool with the given parameters.
  ///
  /// This method should be overridden by concrete tool implementations.
  FutureOr<TResult> execute(TParameters parameters);

  /// Convert raw JSON parameters to the typed parameter object.
  ///
  /// This method should be overridden to provide type-safe parameter parsing.
  TParameters parseParameters(Map<String, dynamic> json);

  /// Convert the tool to a JSON schema format for AI consumption.
  Map<String, dynamic> toJson() {
    return {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'parameters': parametersSchema,
      },
    };
  }
}

/// A simple tool implementation using function callbacks.
class FunctionTool extends Tool<Map<String, dynamic>, dynamic> {
  final FutureOr<dynamic> Function(Map<String, dynamic> parameters) _execute;

  const FunctionTool({
    required super.name,
    required super.description,
    required super.parametersSchema,
    required FutureOr<dynamic> Function(Map<String, dynamic> parameters)
        execute,
  }) : _execute = execute;

  @override
  FutureOr<dynamic> execute(Map<String, dynamic> parameters) {
    return _execute(parameters);
  }

  @override
  Map<String, dynamic> parseParameters(Map<String, dynamic> json) {
    return json;
  }
}
