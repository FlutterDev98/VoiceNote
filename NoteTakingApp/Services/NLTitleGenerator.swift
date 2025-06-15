import Foundation
import NaturalLanguage

protocol TitleGenerating {
    func generateTitle(from text: String) -> String
}

final class NLTitleGenerator: TitleGenerating {
    private let tagger: NLTagger
    private let stopWords: Set<String> = [
        "i", "am", "is", "are", "was", "were", "be", "been", "being", "the", "in", "of", "to", "a", "an", "and", "on", "for", "with", "at", "by", "from", "as", "that", "this", "it", "get", "got", "have", "has", "had", "do", "does", "did", "will", "would", "can", "could", "should", "may", "might", "must", "shall", "you", "your", "we", "our", "they", "their", "he", "she", "his", "her", "or", "but", "if", "so", "because", "about", "into", "through", "over", "after", "before", "under", "above", "out", "up", "down", "off", "not", "no", "yes", "just", "like", "also", "too", "very", "more", "most", "some", "such", "only", "own", "same", "than", "then", "once"
    ]
    
    init() {
        self.tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
    }
    
    func generateTitle(from text: String) -> String {
        // Get first sentence
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        guard let firstSentence = sentences.first else { return "Voice Note" }
        
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        var importantWords: [(String, Double, NLTag?)] = []
        
        // Named entities
        tagger.string = firstSentence
        tagger.enumerateTags(in: firstSentence.startIndex..<firstSentence.endIndex,
                            unit: .word,
                            scheme: .nameType,
                            options: options) { tag, tokenRange in
            if let tag = tag {
                let word = String(firstSentence[tokenRange])
                let score: Double
                switch tag {
                case .personalName, .placeName, .organizationName:
                    score = 3.0
                default:
                    score = 1.0
                }
                importantWords.append((word, score, nil))
            }
            return true
        }
        // If we found named entities, use them for the title
        let namedEntities = importantWords.filter { $0.1 == 3.0 }
        if !namedEntities.isEmpty {
            return namedEntities.map { $0.0.capitalized }.joined(separator: " ")
        }
        // Parts of speech
        tagger.enumerateTags(in: firstSentence.startIndex..<firstSentence.endIndex,
                            unit: .word,
                            scheme: .lexicalClass,
                            options: options) { tag, tokenRange in
            if let tag = tag {
                let word = String(firstSentence[tokenRange])
                let lowerWord = word.lowercased()
                guard !stopWords.contains(lowerWord) else { return true }
                let score: Double
                switch tag {
                case .verb:
                    score = 2.5
                case .noun:
                    score = 2.0
                case .adjective:
                    score = 1.5
                default:
                    score = 0.5
                }
                importantWords.append((word, score, tag))
            }
            return true
        }
        // Filter out stop words and auxiliary verbs
        let filtered = importantWords.filter { !stopWords.contains($0.0.lowercased()) }
        // Prefer verbs and nouns
        let sorted = filtered.sorted {
            if $0.1 == $1.1 {
                // Prefer verbs, then nouns, then adjectives
                let order: [NLTag?] = [.verb, .noun, .adjective]
                let idx0 = order.firstIndex(of: $0.2) ?? 3
                let idx1 = order.firstIndex(of: $1.2) ?? 3
                return idx0 < idx1
            }
            return $0.1 > $1.1
        }
        let topWords = sorted.prefix(3).map { $0.0.capitalized }
        if !topWords.isEmpty {
            return topWords.joined(separator: " ")
        }
        // Fallback: Use first few words of first sentence, excluding stop words
        let words = firstSentence.components(separatedBy: " ")
            .filter { !stopWords.contains($0.lowercased()) }
        if words.count > 2 {
            return words.prefix(3).map { $0.capitalized }.joined(separator: " ")
        }
        return "Voice Note"
    }
} 