import 'package:flutter_test/flutter_test.dart';
import 'package:ai_sdk_flutter/ai_sdk_flutter.dart';

void main() {
  group('IdGenerator', () {
    test('generate creates unique IDs', () {
      final id1 = IdGenerator.generate('test');
      final id2 = IdGenerator.generate('test');

      expect(id1, isNot(equals(id2)));
      expect(id1, startsWith('test_'));
      expect(id2, startsWith('test_'));
    });

    test('generate respects size parameter', () {
      final id = IdGenerator.generate('test', size: 10);
      final parts = id.split('_');

      expect(parts.length, 2);
      expect(parts[0], 'test');
      expect(parts[1].length, 10);
    });

    test('generateMessageId creates valid message IDs', () {
      final id = IdGenerator.generateMessageId();

      expect(id, startsWith('msg_'));
      expect(id.length, greaterThan(4));
    });

    test('generateChatId creates valid chat IDs', () {
      final id = IdGenerator.generateChatId();

      expect(id, startsWith('chat_'));
      expect(id.length, greaterThan(5));
    });

    test('generateToolCallId creates valid tool call IDs', () {
      final id = IdGenerator.generateToolCallId();

      expect(id, startsWith('call_'));
      expect(id.length, greaterThan(5));
    });

    test('multiple calls create unique IDs', () {
      final ids = List.generate(100, (_) => IdGenerator.generateMessageId());
      final uniqueIds = Set.from(ids);

      expect(uniqueIds.length, 100);
    });
  });
}
