import 'package:flutter_test/flutter_test.dart';
import 'package:ai_sdk_flutter/ai_sdk_flutter.dart';

void main() {
  group('IdGenerator', () {
    test('generate creates unique IDs', () {
      final id1 = IdGenerator.generate(prefix: 'test');
      final id2 = IdGenerator.generate(prefix: 'test');

      expect(id1, isNot(equals(id2)));
      expect(id1, startsWith('test'));
      expect(id2, startsWith('test'));
      expect(id1.length, greaterThan(4));
    });

    test('generate respects size parameter', () {
      final id = IdGenerator.generate(prefix: 'test', size: 10);

      expect(id.length, 14); // 'test' (4) + 10 random chars
      expect(id, startsWith('test'));
      expect(id.substring(4).length, 10);
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
