// EntityExtractor.swift
// Apple Natural Language Framework integration
// On-device entity extraction for privacy and performance

import NaturalLanguage

class EntityExtractor {
    private let tagger = NLTagger(tagSchemes: [.nameType])
    
    func extractEntities(from text: String) -> [EntityType: [String]] {
        tagger.string = text
        var entities: [EntityType: [String]] = [:]
        
        tagger.enumerateTaggedTokens(in: text.startIndex..<text.endIndex, 
                                    unit: .word, 
                                    scheme: .nameType) { tokenRange, tag, _ in
            if let tag = tag {
                let entityText = String(text[tokenRange])
                let entityType = EntityType(from: tag)
                entities[entityType, default: []].append(entityText)
            }
            return true
        }
        
        return entities
    }
}

enum EntityType {
    case person, place, organization, other
    
    init(from tag: NLTag) {
        switch tag {
        case .personalName: self = .person
        case .placeName: self = .place
        case .organizationName: self = .organization
        default: self = .other
        }
    }
}