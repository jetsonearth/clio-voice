# Technical Analysis: Dual WebSocket Startup → Pre‑buffer Reordering at Start

## Log Pattern Analysis

### Critical Timing Sequence (Issue Example 1)

```
⏱️ [TIMING] mic_engaged @ 1755242442.302
🔌 WebSocket ready after 4074ms - buffered 3.6s of audio
🔌 WebSocket ready after 5467ms - buffered 1.4s of audio
```

**Problem Identified**: Two separate WebSocket connections established with different buffer sizes.

### Buffer Management Evidence

#### Connection 1: Primary Connection
```
🔌 WebSocket ready after 4074ms - buffered 3.6s of audio
📦 Flushing 36 buffered packets (3.6s of audio, 115200 bytes)
📤 Sent buffered packet 0/36 seq=0 size=3200
📤 Sent buffered packet 35/36 seq=50 size=3200
```

#### Connection 2: Recovery Connection  
```
🔌 WebSocket ready after 5467ms - buffered 1.4s of audio
📦 Flushing 14 buffered packets (1.4s of audio, 44800 bytes)
📤 Sent buffered packet 0/14 seq=1 size=3200
📤 Sent buffered packet 13/14 seq=14 size=3200
```

### Root Cause Evidence

#### 1. Multiple Temp Key Fetches
```
🔑 [FRESH-KEY] Fetched and cached temp key in 1795ms
🔑 [FRESH-KEY] Fetched and cached temp key in 2644ms
```
**Issue**: Two simultaneous temp key requests suggest race condition

#### 2. Audio Capture Recovery During Connection
```
🔁 [DEVICE] Device/default changed – refreshing capture path
🔄 [CAPTURE RECOVERY] Restarting audio capture without closing WebSocket
🌐 [RECOVERY] WebSocket not ready during capture restart – initiating connection
```
**Issue**: Audio capture restarted while WebSocket still connecting

#### 3. Sequence Number Overlap
- Connection 1: `seq=0` to `seq=50` 
- Connection 2: `seq=1` to `seq=14`
**Issue**: Overlapping sequence numbers suggest audio from same time period sent twice

### Timing Analysis

| Event | Time | Duration | Issue |
|-------|------|----------|-------|
| Recording starts | 0ms | - | ✅ Normal |
| First connection ready | 4074ms | 4.1s | ⚠️ Long delay |
| Second connection ready | 5467ms | 5.5s | ❌ Duplicate connection |
| Total connection time | - | 5.5s | ❌ Way too long |

### Buffer Sequencing Problem

**Expected Flow**:
```
Audio Timeline: [0-1s] → [1-2s] → [2-3s] → [3-4s] → [4-5s]
Transcript:     "Hey"  → "so I"  → "have" → "a"    → "conversation"
```

**Actual Flow (Suspected)**:
```
Connection 1: [3.6s buffered] → [2-5.6s audio] → "conversation thread"
Connection 2: [1.4s buffered] → [0-1.4s audio] → "Hey so I have"
Result:       "A conversation thread. Hey, so I have..."
```

## Engineering Debug Tasks

### Immediate Investigation

1. **Verify Sequence Number Logic**
   - Check `SonioxStreamingService.swift` sequence counter
   - Confirm each WebSocket connection uses separate counters
   - Ensure no sequence number collisions

2. **Audio Buffer Chronology**
   - Add timestamps to all buffered audio packets
   - Log buffer creation time vs flush time
   - Verify FIFO ordering of audio segments

3. **WebSocket Connection Management**
   - Investigate why multiple connections establish simultaneously
   - Check connection recovery logic in capture restart
   - Ensure duplicate connections are prevented

### Code Areas to Examine

#### Primary Suspects
```swift
// Clio/Services/AI/SonioxStreamingService.swift
func startStreaming() // Multiple connection establishment
func bufferAudioPacket() // Buffer ordering logic  
func flushBuffer() // Buffer→WebSocket sequencing
```

#### Secondary Areas
```swift
// Audio capture restart logic
func restartAudioCapture()
// Connection recovery
func handleConnectionRecovery() 
// Temp key management
func fetchTempKey()
```

### Testing Protocol

#### Reproduction Setup
1. **Cold Start Conditions**: Fresh app launch or long idle
2. **Network Conditions**: Add artificial latency to simulate slow connections
3. **Audio Input**: Use controlled test phrases with distinct words
4. **Timing**: Record during first 5 seconds when connections are establishing

#### Verification Checklist
- [ ] Only one WebSocket connection establishes per recording session
- [ ] Audio buffers maintain strict chronological order
- [ ] Sequence numbers are monotonic and gap-free
- [ ] Connection recovery doesn't cause duplicate audio transmission
- [ ] Temp key caching prevents multiple simultaneous fetches

### Expected Fix Areas

1. **Connection Deduplication**: Prevent multiple WebSocket connections during startup
2. **Buffer Sequencing**: Ensure strict chronological order in buffer flush
3. **Temp Key Caching**: Fix race condition in simultaneous key requests
4. **Recovery Logic**: Prevent connection restart during active establishment

---
**Analysis Date**: August 15, 2025  
**Priority**: 🔴 CRITICAL - Fix required before next release