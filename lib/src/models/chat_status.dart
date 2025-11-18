/// Chat status enumeration matching AI SDK's status types
enum ChatStatus {
  /// Ready to send messages
  ready,

  /// Message has been submitted and waiting for response
  submitted,

  /// Currently streaming a response
  streaming,

  /// An error occurred
  error,
}
