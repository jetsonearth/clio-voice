# Bug Reports & User Feedback

This directory contains structured documentation of user-reported issues and feedback for the Clio voice transcription app.

## Directory Structure

```
bug-reports/
├── README.md                    # This file
├── bug-report-template.md       # Template for new reports
├── YYYY-MM-DD-description.md    # Individual bug reports
└── analytics/                   # Future: aggregated analysis
```

## How to Use

### Creating New Bug Reports
1. Copy `bug-report-template.md`
2. Rename to `YYYY-MM-DD-brief-description.md`
3. Fill in all relevant sections
4. Prioritize issues (Critical → High → Medium → Low)
5. Add to follow-up actions

### Priority Levels
- 🔴 **CRITICAL**: App crashes, data loss, security vulnerabilities
- 🔴 **HIGH**: Core functionality broken (transcription, recording)
- 🟠 **MEDIUM**: UX issues, minor features, user retention problems
- 🟡 **LOW**: Enhancement requests, cosmetic issues

### Common Issue Categories
1. **Recording Issues**: CMD key, microphone permissions, audio capture
2. **Transcription Problems**: Whisper processing, AI enhancement, accuracy
3. **Authentication**: Sign-in persistence, onboarding flow
4. **Performance**: Latency, memory usage, app responsiveness  
5. **UI/UX**: Interface bugs, workflow problems, accessibility

## User Feedback Patterns

### Desktop App Challenges
- Permission management complexity
- Platform-specific behaviors difficult to reproduce
- Hardware/OS variations cause inconsistent experiences
- Users expect web app simplicity on desktop

### Quality Assurance Notes
- Test on fresh installations frequently
- Verify permission flows with new users
- Check authentication persistence after quit/restart
- Monitor core transcription pipeline reliability

## Current Critical Issues

### 🔴 CRITICAL: Audio Buffer Timing Issue (August 15, 2025)
**File**: `2025-08-15-audio-buffer-timing-critical.md`  
**Problem**: Word order corruption in transcriptions due to buffer mismanagement during WebSocket connection establishment  
**Impact**: Transcription accuracy compromised - first few seconds of audio appear reordered  
**Evidence**: Multiple WebSocket connections, overlapping sequence numbers, buffer flush timing issues

## Action Items from Current Reports
- [ ] 🔴 **CRITICAL**: Fix audio buffer chronological ordering in SonioxStreamingService
- [ ] 🔴 **CRITICAL**: Prevent multiple WebSocket connections during startup
- [ ] 🔴 **CRITICAL**: Fix temp key fetch race conditions
- [ ] Debug CMD key transcription pipeline for new users
- [ ] Fix authentication persistence after app quit
- [ ] Improve permission request flow clarity
- [ ] Add better error messaging for failed recordings