import 'dart:async';
import 'tool.dart';

/// Manages tool registration and execution.
class ToolExecutor {
  final Map<String, Tool> _tools = {};
  final List<String> _approvalRequired = [];

  /// Register a tool for use.
  void registerTool(Tool tool, {bool requiresApproval = false}) {
    _tools[tool.name] = tool;
    if (requiresApproval) {
      _approvalRequired.add(tool.name);
    }
  }

  /// Unregister a tool.
  void unregisterTool(String toolName) {
    _tools.remove(toolName);
    _approvalRequired.remove(toolName);
  }

  /// Check if a tool is registered.
  bool hasTool(String toolName) {
    return _tools.containsKey(toolName);
  }

  /// Check if a tool requires approval before execution.
  bool requiresApproval(String toolName) {
    return _approvalRequired.contains(toolName);
  }

  /// Get all registered tools.
  List<Tool> get tools => List.unmodifiable(_tools.values);

  /// Get tool schemas for AI consumption.
  List<Map<String, dynamic>> getToolSchemas() {
    return _tools.values.map((tool) => tool.toJson()).toList();
  }

  /// Execute a tool by name with the given parameters.
  /// 
  /// Returns the result of the tool execution.
  /// Throws [ToolExecutionException] if the tool is not found or execution fails.
  Future<dynamic> executeTool(String toolName, Map<String, dynamic> parameters) async {
    final tool = _tools[toolName];
    if (tool == null) {
      throw ToolExecutionException('Tool not found: $toolName');
    }

    try {
      final typedParams = tool.parseParameters(parameters);
      final result = await tool.execute(typedParams);
      return result;
    } catch (e, stackTrace) {
      throw ToolExecutionException(
        'Tool execution failed: $toolName',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Clear all registered tools.
  void clear() {
    _tools.clear();
    _approvalRequired.clear();
  }
}

/// Exception thrown when tool execution fails.
class ToolExecutionException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  ToolExecutionException(
    this.message, {
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ToolExecutionException: $message');
    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }
    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }
    return buffer.toString();
  }
}
