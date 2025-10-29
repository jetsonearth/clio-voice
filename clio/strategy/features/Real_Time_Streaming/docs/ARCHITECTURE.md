# Real-Time Streaming Architecture

## System Overview

This document outlines the architecture for implementing real-time streaming text insertion, transforming Clio from batch processing to real-time streaming like WhisperFlow.

## Key Components

### Client Side (Swift)
- **DirectTextInserter.swift** - Direct AXUIElement text insertion
- **StreamingEnhancementService.swift** - Server-Sent Events handling
- **WhisperState.swift** - Updated streaming integration

### Server Side (Node.js/Fly.io)
- **Streaming LLM Proxy** - Real-time Groq API streaming
- **Server-Sent Events** - WebSocket alternative for streaming
- **Token Processing** - Real-time @mention detection

## Data Flow

```
User Speech → ASR (400ms) → First Token (100ms) → Stream Remaining Tokens
                                    ↓
                        Direct Text Insertion + @Mention Processing
```

## Performance Targets

- **Current**: 1280ms total delay before any text appears
- **Target**: 500ms to first visible text (60% improvement)
- **User Experience**: Real-time feedback similar to ChatGPT/Claude