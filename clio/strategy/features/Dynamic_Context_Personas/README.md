# Dynamic Context & Persona-Based Hot Words Feature Specification

**Version:** 1.0  
**Date:** July 30, 2025  
**Status:** Planning Phase  

## Executive Summary

### Vision
Transform Clio from a generic voice transcription tool into an intelligent, context-aware assistant that adapts to users' professional environments and technical vocabularies. By implementing dynamic context detection and persona-based hot word preloading, we can dramatically improve ASR accuracy for technical terms, proper nouns, and domain-specific language that traditional speech recognition models struggle with.

### Business Value
- **Differentiation**: Unique positioning as the only voice transcription app that understands technical contexts
- **User Retention**: Significantly improved accuracy leads to higher user satisfaction and reduced churn
- **Market Expansion**: Opens new market segments (developers, medical professionals, designers, etc.)
- **Competitive Advantage**: Leverages existing PowerMode architecture for rapid implementation

### Key Innovation
Instead of requiring users to manually maintain dictionaries, Clio will automatically detect their professional context (coding tools, design apps, medical software) and intelligently preload relevant technical vocabularies. When a developer opens VS Code, Clio automatically understands React, TypeScript, and API terminology. When switching to email, it adapts to professional communication context.

## Problem Statement

### Current Limitations

**1. Generic ASR Models Miss Technical Terms**
- "Claude Code" → "clawed code" 
- "useState" → "use state" (loses camelCase formatting)
- "GraphQL" → "graphic QL"
- "Kubernetes" → "Cuban NADES" or similar phonetic errors

**2. Manual Dictionary Management is Cumbersome**
- Users must anticipate and pre-enter technical terms
- Limited to ~25 words due to character constraints
- Static approach doesn't adapt to changing contexts
- No intelligent prioritization of terms

**3. Context Switching Overhead**
- Same configuration used for coding, email, meetings
- No adaptation to current professional environment
- Missed opportunities for context-aware accuracy improvements

**4. Competitive Gap**
- Other transcription tools don't address technical vocabulary
- Opportunity to own the "developer/professional tools" market segment
- Current PowerMode system provides foundation but lacks intelligent automation

### User Pain Points

> "I have to spell out React component names every time because Clio doesn't recognize them"

> "When I'm coding, half my variable names get transcribed incorrectly"

> "I keep having to add technical terms to my dictionary, but I can only fit a few"

> "It works great for regular speech but fails on the technical stuff I need most"

## Solution Overview

### Core Concept: Invisible Intelligence
Clio becomes invisibly smarter by:
1. **Context Detection**: Automatically recognizing when users are in technical environments
2. **Persona Activation**: Applying relevant professional vocabularies based on detected context
3. **Dynamic Vocabulary**: Real-time extraction of technical terms from visible applications
4. **Seamless Integration**: Zero user configuration required - intelligence happens in background

### Three-Layer Architecture

**Layer 1: Context Detection**
- Active application monitoring (existing `ActiveWindowService`)
- Browser URL analysis for web-based tools
- Screen content analysis for technical term extraction
- Usage pattern recognition

**Layer 2: Persona Intelligence**
- Pre-curated technical dictionaries per profession
- Dynamic vocabulary selection based on detected context
- Priority-based term loading to optimize ASR performance
- Automatic term lifecycle management

**Layer 3: ASR Enhancement**
- Intelligent integration with Soniox context parameter
- Smart payload optimization to stay within API limits
- Real-time vocabulary adjustment during transcription sessions
- Fallback mechanisms for unknown contexts

### Example User Journey

**Before (Current State):**
1. Developer opens VS Code
2. Starts voice transcription for code comments
3. Says "Initialize useState hook for the GraphQL response"
4. Gets: "Initialize use state hook for the graphic QL response" ❌
5. Manually corrects or adds terms to limited dictionary

**After (With Dynamic Context):**
1. Developer opens VS Code
2. Clio detects development environment, activates "Frontend Developer" persona
3. Automatically preloads: React, useState, GraphQL, TypeScript, API, hooks, etc.
4. Says "Initialize useState hook for the GraphQL response"  
5. Gets: "Initialize useState hook for the GraphQL response" ✅
6. Zero manual intervention required

## Technical Architecture

### New Components

#### 1. PersonaManager
```swift
class PersonaManager: ObservableObject {
    enum PersonaType {
        case frontendDeveloper, backendDeveloper, mobileApp, 
             designer, medical, legal, marketing, default
    }
    
    func getVocabularyFor(persona: PersonaType) -> [String]
    func detectPersonaFromContext(app: String, url: String?) -> PersonaType
    func getPriorityTerms(for: PersonaType, context: String) -> [String]
}
```

**Responsibilities:**
- Maintain curated dictionaries for each professional persona
- Detect appropriate persona based on active application context
- Provide prioritized term lists optimized for ASR context limits
- Learn and adapt vocabulary based on recognition success rates

**Integration Points:**
- Extends existing `PowerModeManager` architecture
- Leverages `ActiveWindowService` for context detection
- Integrates with `SonioxStreamingService` context parameter

#### 2. ContextualDictionaryService
```swift
class ContextualDictionaryService: ObservableObject {
    func buildContextualVocabulary(
        persona: PersonaType, 
        screenContext: String,
        userDictionary: [String]
    ) -> [String]
    
    func optimizeForAPILimits(terms: [String]) -> [String]
    func trackTermEffectiveness(term: String, recognized: Bool)
}
```

**Responsibilities:**
- Combine persona dictionaries with real-time context analysis
- Extract technical terms from visible screen content
- Optimize vocabulary selection for Soniox API constraints (154 chars max)
- Provide analytics on term recognition effectiveness

#### 3. DevelopmentContextExtractor
```swift
class DevelopmentContextExtractor {
    func extractFromCode(content: String, language: ProgrammingLanguage) -> [String]
    func parseIdentifiers(from: String) -> [TechnicalTerm]
    func detectFrameworks(in: String) -> [String]
    func extractAPIEndpoints(from: String) -> [String]
}
```

**Responsibilities:**
- Parse visible code for function names, variables, imports
- Detect programming languages and frameworks in use
- Extract API endpoints and technical identifiers
- Filter meaningful terms from general code syntax

### Integration with Existing Systems

#### PowerMode Enhancement
Extend existing `PowerModeConfig` to support persona assignments:

```swift
struct PowerModeConfig {
    // Existing properties...
    var assignedPersonas: [PersonaType] = []
    var enableDynamicVocabulary: Bool = true
    var vocabularyPriority: VocabularyPriority = .balanced
}
```

#### Soniox Context Integration
Enhance `SonioxStreamingService.getDictionaryContext()`:

```swift
private func getDictionaryContext() -> String? {
    // Existing user dictionary
    let userTerms = getUserDictionaryTerms()
    
    // NEW: Dynamic persona-based terms
    let personaTerms = PersonaManager.shared.getContextualTerms(
        for: ActiveWindowService.shared.detectedPersona,
        screenContext: ContextService.shared.getScreenContext()
    )
    
    // Combine and optimize for API limits
    let combinedTerms = ContextualDictionaryService.shared.optimizeTerms(
        userTerms + personaTerms
    )
    
    return combinedTerms.joined(separator: ", ")
}
```

#### Context Service Integration
Extend `ContextService` to provide technical term extraction:

```swift
extension ContextService {
    func extractTechnicalTerms() -> [String] {
        guard let screenText = screenCaptureService.lastCapturedText else { return [] }
        
        return DevelopmentContextExtractor().extractRelevantTerms(
            from: screenText,
            persona: PersonaManager.shared.activePersona
        )
    }
}
```

## Implementation Phases

### Phase 1: Foundation (Weeks 1-2)
**Goal**: Establish core persona system and basic context detection

**Deliverables:**
- [ ] `PersonaManager` with 5 core personas (Frontend Dev, Backend Dev, Designer, Medical, Default)
- [ ] Basic persona detection based on application bundle IDs
- [ ] Integration with existing `ActiveWindowService`
- [ ] Curated vocabulary sets for each persona (500+ terms each)

**Success Criteria:**
- Persona detection works for major development tools (VS Code, Xcode, IntelliJ)
- Basic vocabulary loading integrates with Soniox context parameter
- No performance regression on existing transcription pipeline

### Phase 2: Smart Context Extraction (Weeks 3-4)
**Goal**: Real-time technical term extraction from active applications

**Deliverables:**
- [ ] `DevelopmentContextExtractor` with code parsing capabilities
- [ ] Programming language detection (JavaScript, Swift, Python, Java, etc.)
- [ ] Framework recognition (React, SwiftUI, Django, Spring, etc.)
- [ ] Variable and function name extraction

**Success Criteria:**
- Accurate extraction of identifiers from visible code
- Framework detection with 90%+ accuracy for major frameworks
- Intelligent filtering of relevant vs. noise terms

### Phase 3: Dynamic Vocabulary Optimization (Weeks 5-6)
**Goal**: Intelligent vocabulary selection and API optimization

**Deliverables:**
- [ ] `ContextualDictionaryService` with smart term prioritization
- [ ] API payload optimization for Soniox 154-character limit
- [ ] Term relevance scoring based on context frequency
- [ ] User dictionary integration with persona terms

**Success Criteria:**
- Stay within Soniox API constraints while maximizing term coverage
- Noticeable improvement in technical term recognition accuracy
- Seamless fallback when context detection fails

### Phase 4: Advanced Features & Learning (Weeks 7-8)
**Goal**: Adaptive learning and advanced context detection

**Deliverables:**
- [ ] Recognition success tracking and vocabulary adaptation
- [ ] Multi-persona support for complex workflows
- [ ] Browser-based tool detection (CodePen, GitHub, etc.)
- [ ] Performance analytics and optimization

**Success Criteria:**
- System learns and improves vocabulary effectiveness over time
- Support for complex workflows (coding + documentation + communication)
- Comprehensive analytics on recognition improvements

## User Experience Flow

### Seamless Background Operation

**New User Onboarding:**
1. User installs Clio (no additional setup required)
2. Opens VS Code for first time
3. Clio detects development environment, shows subtle notification: "✨ Enhanced for coding vocabulary"
4. Immediately benefits from improved technical term recognition

**Daily Workflow Integration:**
1. Morning: Opens email → Clio switches to professional communication mode
2. 10 AM: Opens VS Code → Frontend Developer persona activates
3. 2 PM: Switches to Figma → Designer persona activates  
4. 4 PM: Opens Zoom for meeting → Meeting Notes persona activates
5. Each transition happens automatically, zero user intervention

**Power User Controls:**
- **Settings Panel**: View active persona and vocabulary statistics
- **Manual Override**: Force specific persona for edge cases
- **Vocabulary Insights**: See which terms are helping recognition most
- **Custom Additions**: Add domain-specific terms to persona dictionaries

### UI Enhancements

**Status Indicator:**
```
🎯 Frontend Developer Mode
↳ 847 technical terms active
```

**Settings Panel Addition:**
```
Dynamic Vocabulary
├── Auto-detect context ✅
├── Active persona: Frontend Developer
├── Recognition improvement: +34% for technical terms
└── Manage custom vocabularies →
```

**Optional PowerMode Enhancements:**
```
Email Configuration
├── 📧 Professional Communication
├── Assigned Personas: [Business, Legal]
├── Dynamic vocabulary: ✅ Enabled
└── Custom terms: 12 additional
```

## Performance Considerations

### Pipeline Impact Analysis

**Current Pipeline (989ms total):**
- ASR Streaming: 413ms
- LLM Enhancement: 541ms  
- Overhead: 35ms

**Dynamic Vocabulary Additions:**
- Persona Detection: ~2ms (cached after first detection)
- Context Extraction: ~15ms (parallel with screen capture)
- Vocabulary Building: ~8ms (cached, updated only on context change)
- **Total Additional**: ~25ms overhead (2.5% increase)

**Optimizations:**
- Background persona detection during screen capture
- Vocabulary caching with intelligent invalidation
- Lazy loading of persona dictionaries
- Context change detection to minimize unnecessary updates

### Memory & Storage

**Memory Usage:**
- Persona dictionaries: ~2MB total (500 terms × 5 personas × average 20 chars)
- Context cache: ~500KB (rolling window of recent extractions)
- **Total Additional**: ~2.5MB (minimal impact)

**Storage Requirements:**
- Persona dictionaries: Bundled with app (no additional download)
- User vocabulary adaptations: <100KB per user
- Recognition analytics: <50KB per user

### API Optimization

**Soniox Context Limits:**
- Current: 154 characters max for context parameter
- Strategy: Priority-based term selection
- Fallback: Most relevant 8-12 terms when over limit
- Analytics: Track which terms provide best recognition improvement

## Success Metrics

### Primary KPIs

**Recognition Accuracy Improvement:**
- Target: 40%+ improvement for technical terms
- Measurement: Before/after comparison on standardized technical vocabulary
- Baseline: Current recognition rate for programming terms, brand names, technical jargon

**User Satisfaction:**
- Target: 25%+ increase in user ratings for "accuracy" category
- Measurement: In-app feedback and App Store reviews
- Qualitative: Reduction in user complaints about technical term recognition

**Engagement Metrics:**
- Target: 15%+ increase in daily active usage
- Theory: Better accuracy → more frequent use
- Measurement: Session frequency and duration analytics

### Secondary KPIs

**Context Detection Accuracy:**
- Target: 90%+ correct persona detection
- Measurement: User feedback on automatic persona selection
- Edge cases: Complex workflows, unknown applications

**Performance Impact:**
- Target: <50ms additional latency
- Measurement: End-to-end transcription timing
- Constraint: No regression in current 989ms pipeline

**Vocabulary Effectiveness:**
- Target: 70%+ of dynamic terms provide recognition improvement
- Measurement: A/B testing with/without specific terms
- Optimization: Remove ineffective terms, prioritize effective ones

### Analytics Dashboard

**User-Facing Insights:**
```
Your Recognition Improvements
├── Technical terms: +34% accuracy
├── Top helpful vocabularies: React, TypeScript, API
├── Context switches today: 12
└── Personas used: Frontend Dev, Email, Meeting
```

**Internal Analytics:**
- Persona detection accuracy by application
- Vocabulary term effectiveness rankings
- Performance impact metrics
- User adoption of different personas

## Risk Assessment & Mitigation

### Technical Risks

**Risk: Performance Degradation**
- *Probability*: Medium
- *Impact*: High (user experience)
- *Mitigation*: Comprehensive performance testing, background processing, caching strategies

**Risk: Context Detection Failures**
- *Probability*: Medium  
- *Impact*: Medium (reduced effectiveness)
- *Mitigation*: Graceful fallback to user dictionary, manual persona override option

**Risk: API Limit Constraints**
- *Probability*: High
- *Impact*: Medium (vocabulary truncation)
- *Mitigation*: Intelligent term prioritization, effectiveness-based selection

### Product Risks

**Risk: Feature Complexity**
- *Probability*: Medium
- *Impact*: Medium (user confusion)
- *Mitigation*: Default to invisible operation, progressive disclosure for power users

**Risk: Privacy Concerns**
- *Probability*: Low
- *Impact*: High (user trust)
- *Mitigation*: Clear data practices, local processing where possible, opt-out options

**Risk: Limited Persona Coverage**
- *Probability*: High
- *Impact*: Medium (market segment gaps)
- *Mitigation*: Phased rollout starting with largest segments, community vocabulary contributions

### Market Risks

**Risk: Competitive Response**
- *Probability*: Medium
- *Impact*: Medium (differentiation loss)
- *Mitigation*: First-mover advantage, deep integration with existing PowerMode system

**Risk: User Adoption**
- *Probability*: Low
- *Impact*: High (feature ROI)
- *Mitigation*: Default activation, clear value demonstration, gradual rollout

## Future Roadmap

### Version 2.0 Enhancements (6-12 months)

**Community Vocabularies:**
- User-contributed persona dictionaries
- Crowdsourced technical term databases
- Industry-specific vocabulary packs (medical, legal, finance)

**Advanced Learning:**
- Personal vocabulary learning from user corrections
- Contextual phrase recognition (not just individual terms)
- Cross-application learning (terms that work across contexts)

**Enterprise Features:**
- Team vocabulary sharing
- Company-specific term databases
- Integration with corporate knowledge bases

### Version 3.0 Vision (12+ months)

**AI-Powered Context Understanding:**
- LLM-based context analysis for deeper understanding
- Natural language processing of screen content
- Semantic relationship understanding between terms

**Real-Time Collaboration:**
- Shared vocabularies in team environments
- Real-time vocabulary suggestions during transcription
- Integration with development team workflows

**Advanced Persona Intelligence:**
- Automatic persona creation based on usage patterns
- Sub-persona recognition (React developer vs. Vue developer)
- Dynamic persona blending for complex workflows

## Conclusion

The Dynamic Context & Persona-Based Hot Words feature represents a fundamental evolution of Clio from a generic transcription tool to an intelligent, context-aware professional assistant. By leveraging our existing PowerMode architecture and adding invisible intelligence, we can dramatically improve accuracy for technical users while maintaining the seamless experience Clio is known for.

**Key Success Factors:**
1. **Seamless Integration**: Build on existing systems rather than replacing them
2. **Invisible Intelligence**: Users benefit without configuration overhead
3. **Performance Focus**: Maintain current speed while adding intelligence
4. **Gradual Rollout**: Phase implementation to manage risk and gather feedback

**Expected Impact:**
- 40%+ improvement in technical term recognition
- New market differentiation in professional/developer segments  
- Higher user satisfaction and retention
- Platform for future AI-powered enhancements

This feature positions Clio as the definitive voice transcription solution for professionals who need accurate recognition of technical vocabulary, creating a sustainable competitive advantage in an increasingly crowded market.

---

*This specification serves as the foundation for development planning and stakeholder alignment. Regular updates will be made as implementation progresses and user feedback is incorporated.*