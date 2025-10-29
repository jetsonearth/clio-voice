import Foundation
import NaturalLanguage
import os

/// Local entity extraction using Apple's Natural Language framework
/// Provides privacy-first named entity recognition for improving transcription accuracy
class LocalEntityExtractor {
    private let logger = Logger(
        subsystem: "com.jetsonai.clio",
        category: "local-ner"
    )
    
    private let tagger = NLTagger(tagSchemes: [.nameType])
    
    /// Extract entities from text using Apple NL framework
    func extractEntities(from text: String) -> ExtractedEntities {
        logger.debug("🔍 Starting local entity extraction from \(text.count) characters")
        
        tagger.string = text
        
        // Detect dominant language for better performance
        if let language = NLLanguageRecognizer.dominantLanguage(for: text) {
            tagger.setLanguage(language, range: text.startIndex..<text.endIndex)
        }
        
        var people: [String] = []
        var organizations: [String] = []
        var places: [String] = []
        var other: [String] = []
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, 
                             unit: .word, 
                             scheme: .nameType,
                             options: []) { tag, tokenRange in
            
            guard let tag = tag else { return true }
            
            let entityText = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip very short entities (likely OCR errors)
            guard entityText.count >= 2 else { return true }
            
            switch tag {
            case .personalName:
                people.append(entityText)
            case .organizationName:
                organizations.append(entityText)
            case .placeName:
                places.append(entityText)
            default:
                other.append(entityText)
            }
            
            return true
        }
        
        let processingTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Remove duplicates and clean up
        let cleanedPeople = Array(Set(people)).filter { !$0.isEmpty }
        let cleanedOrganizations = Array(Set(organizations)).filter { !$0.isEmpty }
        let cleanedPlaces = Array(Set(places)).filter { !$0.isEmpty }
        let cleanedOther = Array(Set(other)).filter { !$0.isEmpty }
        
        let totalEntities = cleanedPeople.count + cleanedOrganizations.count + cleanedPlaces.count + cleanedOther.count
        
        logger.notice("✅ Entity extraction completed in \(String(format: "%.1f", processingTime * 1000))ms")
        logger.notice("📊 Found entities: \(cleanedPeople.count) people, \(cleanedOrganizations.count) orgs, \(cleanedPlaces.count) places, \(cleanedOther.count) other")
        
        if totalEntities > 0 {
            logger.debug("👥 People: \(cleanedPeople.joined(separator: ", "))")
            logger.debug("🏢 Organizations: \(cleanedOrganizations.joined(separator: ", "))")
            logger.debug("📍 Places: \(cleanedPlaces.joined(separator: ", "))")
            logger.debug("🔍 Other: \(cleanedOther.joined(separator: ", "))")
        }
        
        return ExtractedEntities(
            people: cleanedPeople,
            organizations: cleanedOrganizations,
            places: cleanedPlaces,
            other: cleanedOther,
            processingTimeMs: processingTime * 1000
        )
    }
    
    /// Build vocabulary hints from extracted entities for ASR improvement
    func buildVocabularyHints(from entities: ExtractedEntities) -> [String] {
        var vocabulary: [String] = []
        
        // Add all entity text as vocabulary hints
        vocabulary.append(contentsOf: entities.people)
        vocabulary.append(contentsOf: entities.organizations)
        vocabulary.append(contentsOf: entities.places)
        vocabulary.append(contentsOf: entities.other)
        
        // Generate variations for better matching
        for person in entities.people {
            // Add first name only if it's a full name
            let components = person.components(separatedBy: " ")
            if components.count > 1 {
                vocabulary.append(components[0]) // First name
                if components.count > 2 {
                    vocabulary.append(components.last!) // Last name
                }
            }
        }
        
        // Remove duplicates and filter out very short terms
        let uniqueVocabulary = Array(Set(vocabulary))
            .filter { $0.count >= 2 }
            .sorted()
        
        logger.debug("📝 Built vocabulary with \(uniqueVocabulary.count) terms")
        
        return uniqueVocabulary
    }
    
    /// Format entities for AI enhancement context
    func formatForAIContext(entities: ExtractedEntities) -> String {
        var contextParts: [String] = []
        
        if !entities.people.isEmpty {
            contextParts.append("People: \(entities.people.joined(separator: ", "))")
        }
        
        if !entities.organizations.isEmpty {
            contextParts.append("Organizations: \(entities.organizations.joined(separator: ", "))")
        }
        
        if !entities.places.isEmpty {
            contextParts.append("Places: \(entities.places.joined(separator: ", "))")
        }
        
        if contextParts.isEmpty {
            return ""
        }
        
        return "Context Entities - \(contextParts.joined(separator: " | "))"
    }
}

/// Structured entity extraction results
struct ExtractedEntities {
    let people: [String]
    let organizations: [String]
    let places: [String]
    let other: [String]
    let processingTimeMs: Double
    
    var isEmpty: Bool {
        return people.isEmpty && organizations.isEmpty && places.isEmpty && other.isEmpty
    }
    
    var totalCount: Int {
        return people.count + organizations.count + places.count + other.count
    }
}