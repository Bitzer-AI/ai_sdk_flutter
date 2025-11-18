import 'package:flutter_test/flutter_test.dart';
import 'package:ai_sdk_flutter/ai_sdk_flutter.dart';

void main() {
  group('UIMessage', () {
    test('creates user message with text', () {
      final message = UIMessage.user(
        id: 'msg_123',
        text: 'Hello',
      );

      expect(message.id, 'msg_123');
      expect(message.role, MessageRole.user);
      expect(message.parts.length, 1);
      expect(message.parts.first, isA<TextUIPart>());
      expect((message.parts.first as TextUIPart).text, 'Hello');
    });

    test('creates assistant message with text', () {
      final message = UIMessage.assistant(
        id: 'msg_456',
        text: 'Hi there',
      );

      expect(message.id, 'msg_456');
      expect(message.role, MessageRole.assistant);
      expect(message.parts.length, 1);
      expect(message.parts.first, isA<TextUIPart>());
      expect((message.parts.first as TextUIPart).text, 'Hi there');
      expect((message.parts.first as TextUIPart).state, TextState.done);
    });

    test('creates system message with text', () {
      final message = UIMessage.system(
        id: 'msg_789',
        text: 'You are helpful',
      );

      expect(message.id, 'msg_789');
      expect(message.role, MessageRole.system);
      expect(message.parts.length, 1);
      expect(message.parts.first, isA<TextUIPart>());
      expect((message.parts.first as TextUIPart).text, 'You are helpful');
    });

    test('equality works correctly', () {
      final message1 = UIMessage(
        id: 'msg_1',
        role: MessageRole.user,
        parts: [TextUIPart(text: 'Hello')],
      );

      final message2 = UIMessage(
        id: 'msg_1',
        role: MessageRole.user,
        parts: [TextUIPart(text: 'Hello')],
      );

      final message3 = UIMessage(
        id: 'msg_2',
        role: MessageRole.user,
        parts: [TextUIPart(text: 'Hello')],
      );

      expect(message1, equals(message2));
      expect(message1, isNot(equals(message3)));
    });

    test('toJson and fromJson work correctly', () {
      final original = UIMessage(
        id: 'msg_test',
        role: MessageRole.assistant,
        parts: [
          TextUIPart(text: 'Response', state: TextState.done),
          ToolUIPart(
            type: 'tool-weather',
            toolCallId: 'call_1',
            state: ToolCallState.output_available,
            input: {'city': 'NYC'},
            output: {'temp': 72},
          ),
        ],
        metadata: {'timestamp': 12345},
      );

      final json = original.toJson();
      final restored = UIMessage.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.role, original.role);
      expect(restored.parts.length, original.parts.length);
      expect(restored.metadata, original.metadata);
    });
  });

  group('UIMessagePart', () {
    test('TextUIPart has correct properties', () {
      final part = TextUIPart(text: 'Hello', state: TextState.streaming);

      expect(part.type, 'text');
      expect(part.text, 'Hello');
      expect(part.state, TextState.streaming);
    });

    test('ToolUIPart has correct properties', () {
      final part = ToolUIPart(
        type: 'tool-calculator',
        toolCallId: 'call_123',
        state: ToolCallState.input_available,
        input: {'expression': '2+2'},
      );

      expect(part.type, 'tool-calculator');
      expect(part.toolCallId, 'call_123');
      expect(part.state, ToolCallState.input_available);
      expect(part.input, {'expression': '2+2'});
    });

    test('FileUIPart has correct properties', () {
      final part = FileUIPart(
        url: 'https://example.com/doc.pdf',
        mediaType: 'application/pdf',
        filename: 'document.pdf',
      );

      expect(part.type, 'file');
      expect(part.filename, 'document.pdf');
      expect(part.mediaType, 'application/pdf');
      expect(part.url, 'https://example.com/doc.pdf');
    });

    test('ReasoningUIPart has correct properties', () {
      final part = ReasoningUIPart(
        text: 'Let me think...',
        state: TextState.done,
      );

      expect(part.type, 'reasoning');
      expect(part.text, 'Let me think...');
      expect(part.state, TextState.done);
    });
  });

  group('ChatStatus', () {
    test('has all expected states', () {
      expect(ChatStatus.values.length, 4);
      expect(ChatStatus.values, contains(ChatStatus.ready));
      expect(ChatStatus.values, contains(ChatStatus.submitted));
      expect(ChatStatus.values, contains(ChatStatus.streaming));
      expect(ChatStatus.values, contains(ChatStatus.error));
    });
  });

  group('FinishReason', () {
    test('fromString parses correctly', () {
      expect(FinishReasonExtension.fromString('stop'), FinishReason.stop);
      expect(FinishReasonExtension.fromString('length'), FinishReason.length);
      expect(FinishReasonExtension.fromString('content-filter'), FinishReason.contentFilter);
      expect(FinishReasonExtension.fromString('tool-calls'), FinishReason.toolCalls);
      expect(FinishReasonExtension.fromString('error'), FinishReason.error);
      expect(FinishReasonExtension.fromString('other'), FinishReason.other);
      expect(FinishReasonExtension.fromString('unknown-value'), FinishReason.unknown);
    });
  });

  group('ToolInvocation', () {
    test('state queries work correctly', () {
      final invocation1 = ToolInvocation(
        toolCallId: 'call_1',
        toolName: 'test',
        state: ToolCallState.input_streaming,
      );
      expect(invocation1.isInputStreaming, true);
      expect(invocation1.hasInputAvailable, false);
      expect(invocation1.hasOutputAvailable, false);

      final invocation2 = ToolInvocation(
        toolCallId: 'call_2',
        toolName: 'test',
        state: ToolCallState.output_available,
        output: {'answer': 42},
      );
      expect(invocation2.hasOutputAvailable, true);
      expect(invocation2.output, {'answer': 42});

      final invocation3 = ToolInvocation(
        toolCallId: 'call_3',
        toolName: 'test',
        state: ToolCallState.output_error,
        errorText: 'Failed',
      );
      expect(invocation3.hasError, true);
      expect(invocation3.errorText, 'Failed');
    });
  });
}
