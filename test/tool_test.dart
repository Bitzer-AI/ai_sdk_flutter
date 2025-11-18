import 'package:ai_sdk_flutter/ai_sdk_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tool', () {
    test('FunctionTool executes correctly', () async {
      final tool = FunctionTool(
        name: 'add',
        description: 'Adds two numbers',
        parametersSchema: {
          'type': 'object',
          'properties': {
            'a': {'type': 'number'},
            'b': {'type': 'number'},
          },
          'required': ['a', 'b'],
        },
        execute: (params) {
          return params['a'] + params['b'];
        },
      );

      final result = await tool.execute({'a': 5, 'b': 3});

      expect(result, 8);
      expect(tool.name, 'add');
      expect(tool.description, 'Adds two numbers');
    });

    test('toJson creates correct schema', () {
      final tool = FunctionTool(
        name: 'weather',
        description: 'Gets weather',
        parametersSchema: {
          'type': 'object',
          'properties': {
            'city': {'type': 'string'},
          },
        },
        execute: (params) => {'temp': 72},
      );

      final json = tool.toJson();

      expect(json['type'], 'function');
      expect(json['function']['name'], 'weather');
      expect(json['function']['description'], 'Gets weather');
      expect(json['function']['parameters']['type'], 'object');
    });
  });

  group('ToolExecutor', () {
    late ToolExecutor executor;

    setUp(() {
      executor = ToolExecutor();
    });

    test('registers and executes tools', () async {
      final addTool = FunctionTool(
        name: 'add',
        description: 'Adds numbers',
        parametersSchema: {},
        execute: (params) => params['a'] + params['b'],
      );

      executor.registerTool(addTool);

      expect(executor.hasTool('add'), true);
      expect(executor.tools.length, 1);

      final result = await executor.executeTool('add', {'a': 10, 'b': 20});
      expect(result, 30);
    });

    test('unregisters tools', () {
      final tool = FunctionTool(
        name: 'test',
        description: 'Test tool',
        parametersSchema: {},
        execute: (params) => null,
      );

      executor.registerTool(tool);
      expect(executor.hasTool('test'), true);

      executor.unregisterTool('test');
      expect(executor.hasTool('test'), false);
    });

    test('tracks approval requirements', () {
      final tool = FunctionTool(
        name: 'dangerous',
        description: 'Dangerous operation',
        parametersSchema: {},
        execute: (params) => null,
      );

      executor.registerTool(tool, requiresApproval: true);

      expect(executor.requiresApproval('dangerous'), true);
      expect(executor.requiresApproval('other'), false);
    });

    test('throws exception for missing tool', () async {
      expect(
        () => executor.executeTool('nonexistent', {}),
        throwsA(isA<ToolExecutionException>()),
      );
    });

    test('wraps execution errors', () async {
      final failingTool = FunctionTool(
        name: 'fail',
        description: 'Always fails',
        parametersSchema: {},
        execute: (params) => throw Exception('Tool error'),
      );

      executor.registerTool(failingTool);

      expect(
        () => executor.executeTool('fail', {}),
        throwsA(isA<ToolExecutionException>()),
      );
    });

    test('getToolSchemas returns all schemas', () {
      executor.registerTool(
        FunctionTool(
          name: 'tool1',
          description: 'First tool',
          parametersSchema: {},
          execute: (params) => null,
        ),
      );
      executor.registerTool(
        FunctionTool(
          name: 'tool2',
          description: 'Second tool',
          parametersSchema: {},
          execute: (params) => null,
        ),
      );

      final schemas = executor.getToolSchemas();

      expect(schemas.length, 2);
      expect(schemas[0]['function']['name'], 'tool1');
      expect(schemas[1]['function']['name'], 'tool2');
    });

    test('clear removes all tools', () {
      executor.registerTool(
        FunctionTool(
          name: 'tool',
          description: 'Tool',
          parametersSchema: {},
          execute: (params) => null,
        ),
        requiresApproval: true,
      );

      expect(executor.tools.length, 1);
      expect(executor.requiresApproval('tool'), true);

      executor.clear();

      expect(executor.tools.length, 0);
      expect(executor.requiresApproval('tool'), false);
    });
  });
}
