# AI SDK Flutter Example

This example demonstrates how to use the `ai_sdk_flutter` package to create an AI-powered chat application with streaming responses and tool calling.

## Features Demonstrated

- 🎯 Basic chat with streaming responses
- 🔧 Tool calling (weather and calculator examples)
- 📊 Real-time message updates
- ⚠️ Error handling

## Running the Example

1. Set up your AI backend endpoint (compatible with Vercel AI SDK v5)
2. Update the API URL in `lib/main.dart`
3. Run the example:

```bash
flutter run
```

## What's Included

- **Simple Chat UI**: Text input and message display
- **Weather Tool**: Example tool that returns weather information
- **Calculator Tool**: Example tool for mathematical operations
- **Streaming Support**: Real-time message updates as the AI responds
- **Error Handling**: Graceful error display and recovery

## Code Structure

- `lib/main.dart`: Main application entry point
- `lib/chat_screen.dart`: Chat UI implementation
- `lib/tools/`: Example tool implementations

## Backend Setup

This example requires a backend server compatible with Vercel AI SDK v5. You can create one using:

```typescript
import { streamText } from 'ai';
import { openai } from '@ai-sdk/openai';

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = await streamText({
    model: openai('gpt-4-turbo'),
    messages,
    tools: {
      weather: {
        description: 'Get weather for a city',
        parameters: z.object({
          city: z.string(),
        }),
      },
    },
  });

  return result.toDataStreamResponse();
}
```

## Learn More

- [ai_sdk_flutter Documentation](../README.md)
- [Vercel AI SDK](https://sdk.vercel.ai/)
