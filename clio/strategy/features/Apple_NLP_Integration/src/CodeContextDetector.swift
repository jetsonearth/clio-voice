// CodeContextDetector.swift
// Code-aware transcription for developer workflows
// Competitive advantage against WhisperFlow

import Foundation

class CodeContextDetector {
    private let languagePatterns: [ProgrammingLanguage: [String]] = [
        .swift: ["func", "var", "let", "class", "struct", "enum", "@objc"],
        .javascript: ["function", "const", "let", "var", "class", "=>"],
        .python: ["def", "class", "import", "from", "if __name__"],
        .java: ["public", "private", "class", "interface", "import"],
        .cpp: ["#include", "namespace", "class", "template", "std::"]
    ]
    
    func detectProgrammingLanguage(from screenText: String) -> ProgrammingLanguage? {
        var languageScores: [ProgrammingLanguage: Int] = [:]
        
        for (language, patterns) in languagePatterns {
            let score = patterns.reduce(0) { count, pattern in
                count + screenText.components(separatedBy: pattern).count - 1
            }
            languageScores[language] = score
        }
        
        return languageScores.max(by: { $0.value < $1.value })?.key
    }
}

enum ProgrammingLanguage: String, CaseIterable {
    case swift, javascript, python, java, cpp
    
    var fileExtensions: [String] {
        switch self {
        case .swift: return [".swift"]
        case .javascript: return [".js", ".ts", ".jsx", ".tsx"]
        case .python: return [".py"]
        case .java: return [".java"]
        case .cpp: return [".cpp", ".hpp", ".c", ".h"]
        }
    }
}