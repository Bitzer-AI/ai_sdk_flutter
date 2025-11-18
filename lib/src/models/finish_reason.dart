/// Finish reason for a message generation
enum FinishReason {
  /// Natural stop point
  stop,

  /// Maximum token limit reached
  length,

  /// Content was filtered
  contentFilter,

  /// Tool calls were made
  toolCalls,

  /// Error occurred
  error,

  /// Other/unknown reason
  other,

  /// Unknown finish reason
  unknown,
}

/// Extension to parse finish reason from string
extension FinishReasonExtension on FinishReason {
  static FinishReason fromString(String? value) {
    if (value == null) return FinishReason.unknown;

    switch (value) {
      case 'stop':
        return FinishReason.stop;
      case 'length':
        return FinishReason.length;
      case 'content-filter':
      case 'contentFilter':
        return FinishReason.contentFilter;
      case 'tool-calls':
      case 'toolCalls':
        return FinishReason.toolCalls;
      case 'error':
        return FinishReason.error;
      case 'other':
        return FinishReason.other;
      default:
        return FinishReason.unknown;
    }
  }
}
