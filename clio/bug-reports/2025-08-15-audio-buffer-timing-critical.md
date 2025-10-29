# CRITICAL BUG: Audio Buffer Timing Issue - Word Order Corruption

## Issue Summary
**Date**: August 15, 2025  
**Severity**: 🔴 **CRITICAL** - Core transcription functionality corrupted  
**Component**: Soniox Streaming Service / Audio Buffer Management  
**Impact**: Transcription accuracy compromised - words appear in wrong order  

## Problem Description

The Soniox streaming transcription service is experiencing a critical audio buffer timing issue where the **first few seconds of audio get reordered** in the final transcript. This appears to be related to WebSocket connection establishment timing and audio buffer management during cold starts.

### Evidence of Issue

**Example 1:**
- **User spoke**: "Hey, so I have a conversation thread..."
- **Transcribed as**: "A conversation thread. Hey, so I have between a user and I..."
- **Analysis**: "Hey" was moved from the beginning to after "conversation thread"

**Example 2:**  
- **User spoke**: "I'm going to try it again and see if it's going to happen - and still..."
- **Transcribed as**: "It's going to happen. I'm going to try it again and see if — and still..."
- **Analysis**: Audio segments reordered - "It's going to happen" moved to front incorrectly

### ⚠️ RELATED AUDIO FILE CORRUPTION

**Critical Discovery**: The saved audio files also show corruption during these same incidents:
- **First second of audio is cut off or missing**
- **Audio gaps correspond to transcript reordering**
- **Audio file fragmentation matches WebSocket connection timing**

This confirms the issue affects **both transcript accuracy AND audio file integrity**.

## Technical Analysis from Logs

### Key Timing Evidence

1. **Multiple WebSocket Connections Established**:
   ```
   🔌 WebSocket ready after 4074ms - buffered 3.6s of audio
   🔌 WebSocket ready after 5467ms - buffered 1.4s of audio
   ```

2. **Buffer Flushing During Connection Delays**:
   ```
   📦 Flushing 36 buffered packets (3.6s of audio, 115200 bytes)
   📦 Flushing 14 buffered packets (1.4s of audio, 44800 bytes)
   ```

3. **Cold Start Audio Recovery**:
   ```
   🔄 [CAPTURE RECOVERY] Restarting audio capture without closing WebSocket
   🌐 [RECOVERY] WebSocket not ready during capture restart – initiating connection
   ```

4. **Temp Key Fetch Delays**:
   ```
   🔑 [FRESH-KEY] Fetched and cached temp key in 1795ms
   🔑 [FRESH-KEY] Fetched and cached temp key in 2644ms
   ```

### Root Cause Hypothesis

The issue appears to stem from **audio buffer management during WebSocket connection establishment**:

1. **Audio starts recording** immediately when user presses hotkey
2. **WebSocket connection takes 4-6 seconds** to establish (cold start + temp key fetch)
3. **Audio gets buffered** in multiple chunks during connection delay
4. **Buffer flush order may not match recording chronology** when multiple connections are involved
5. **Soniox receives audio segments out of sequence**, leading to transcript reordering

## Technical Investigation Required

### Files to Examine
- `Clio/Services/AI/SonioxStreamingService.swift`
- Audio buffer management in streaming service
- WebSocket connection lifecycle management
- Audio packet sequencing logic

### Key Questions for QA/Engineers

1. **Buffer Sequencing**: How are audio packets sequenced when multiple WebSocket connections are established?
2. **Connection Recovery**: Does the "capture recovery" process preserve chronological order of buffered audio?
3. **Packet Ordering**: Are sequence numbers (`seq=0`, `seq=1`, etc.) correctly maintained across connection restarts?
4. **Cold Start Impact**: Why are multiple temp key fetches happening simultaneously?
5. **Audio File Integrity**: How does capture restart affect saved audio file completeness?
6. **Audio Gaps**: Are audio file gaps caused by tap removal during active recording?

## Reproduction Steps

1. **Trigger cold start conditions**: Fresh app launch or long idle period
2. **Start recording immediately** when multiple WebSocket connections will be established
3. **Speak during the first 3-6 seconds** while WebSocket is connecting
4. **Observe transcript output** for word order corruption

## Expected vs Actual Behavior

**Expected**: Audio transcribed in exact chronological order as spoken  
**Actual**: First few seconds of audio segments appear reordered in final transcript

## Debugging Approach

### Immediate Actions
1. **Add sequence number logging** to all audio packets sent to Soniox
2. **Track buffer flush chronology** during WebSocket establishment
3. **Monitor packet order** when multiple connections are involved
4. **Verify Soniox receives packets in correct sequence**
5. **Test audio file integrity** during cold start recordings
6. **Monitor audio tap lifecycle** during capture restarts

### Specific Log Analysis
- Search logs for pattern: Multiple "WebSocket ready" messages with different buffer sizes
- Correlate timing between "Capture Recovery" and "Buffer flush" events
- Verify sequence numbers in "Sending audio packet seq=" logs

### Testing Protocol
1. **Reproduce with controlled audio**: Use known test phrases to verify exact reordering
2. **Test during different connection states**: Cold start, warm connections, recovery scenarios
3. **Monitor network latency impact**: Test with various connection speeds
4. **Verify fix doesn't break normal streaming**: Ensure warm connections still work correctly

## Impact Assessment
- **User Experience**: Transcription accuracy severely compromised
- **Use Case Impact**: Meeting notes, dictation, and professional use cases affected
- **Frequency**: Probabilistic - occurs during cold starts and connection issues
- **Criticality**: HIGH - Core functionality reliability compromised

## Related Components
- `SonioxStreamingService.swift` - WebSocket management
- Audio capture and buffering system
- Connection recovery logic
- Temp key caching system
- Cold start optimization system

---
**Reporter**: User feedback via conversation logs  
**Status**: ❌ OPEN - Requires immediate engineering investigation  
**Assigned**: [Engineering Team - Audio Pipeline]