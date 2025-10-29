import XCTest
@testable import Clio

final class TranscriptNormalizerTests: XCTestCase {

    func testMillisecondsAndNumbers() {
        XCTAssertEqual(TranscriptNormalizer.normalize("122 milliseconds"), "122ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("TTFB is 100017 milliseconds"), "TTFB is 100017ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("five milliseconds"), "5ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("五百毫秒"), "500ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("500—ms"), "500ms")
    }

    func testPercent() {
        XCTAssertEqual(TranscriptNormalizer.normalize("500 percent"), "500%")
        XCTAssertEqual(TranscriptNormalizer.normalize("percentage is five"), "percentage is five") // no unit, no change
        XCTAssertEqual(TranscriptNormalizer.normalize("百分之五"), "5%")
        XCTAssertEqual(TranscriptNormalizer.normalize("三点五 percent"), "3.5%")
        XCTAssertEqual(TranscriptNormalizer.normalize("three point five percent"), "3.5%")
    }

    func testLengthAndMass() {
        XCTAssertEqual(TranscriptNormalizer.normalize("three meters, one hundred kilograms"), "3m, 100kg")
        XCTAssertEqual(TranscriptNormalizer.normalize("二十厘米"), "20cm")
        XCTAssertEqual(TranscriptNormalizer.normalize("一公斤"), "1kg")
        XCTAssertEqual(TranscriptNormalizer.normalize("250 grams"), "250g")
    }

    func testCurrency() {
        XCTAssertEqual(TranscriptNormalizer.normalize("five hundred dollars"), "$500")
        XCTAssertEqual(TranscriptNormalizer.normalize("$ 1,017"), "$1017")
        XCTAssertEqual(TranscriptNormalizer.normalize("USD 500"), "$500")
    }

    func testDoesNotMangleNonNumericPhrases() {
        // Ensure ranges like "five to ten milliseconds" are not collapsed incorrectly
        let input = "five to ten milliseconds"
        let output = TranscriptNormalizer.normalize(input)
        XCTAssertEqual(output, input) // unchanged because ambiguous range

        // Ensure tokens per second phrase remains intact
        let s = "it should have been 1000 tokens per second, or 500ms, instead of literal words."
        let normalized = TranscriptNormalizer.normalize(s)
        XCTAssertEqual(normalized, "it should have been 1000 tokens per second, or 500ms, instead of literal words.")

        // Ensure we don't create spurious one-letter units from common words
        let phrase = "Alright, so somehow I'm in trial now. so strange. we're going to see."
        XCTAssertEqual(TranscriptNormalizer.normalize(phrase), phrase)
    }

    func testMultilanguageBasics() {
        // Japanese (Kanji numerals + unit)
        XCTAssertEqual(TranscriptNormalizer.normalize("五百ミリ秒"), "500ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("3秒"), "3s")

        // Korean (Hangul numerals + unit)
        XCTAssertEqual(TranscriptNormalizer.normalize("오백 밀리초"), "500ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("삼 점 오 퍼센트"), "3.5%") // spacing tolerated via tidy
        XCTAssertEqual(TranscriptNormalizer.normalize("3초"), "3s")

        // French
        XCTAssertEqual(TranscriptNormalizer.normalize("500 millisecondes"), "500ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("500 pour cent"), "500%")

        // German
        XCTAssertEqual(TranscriptNormalizer.normalize("100 Millisekunden"), "100ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("25 Prozent"), "25%")

        // Russian
        XCTAssertEqual(TranscriptNormalizer.normalize("500 миллисекунд"), "500ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("25 процентов"), "25%")

        // Arabic (Arabic-Indic digits)
        XCTAssertEqual(TranscriptNormalizer.normalize("٥٠٠ مللي ثانية"), "500ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("٥ بالمئة"), "5%")

        // Hindi (Devanagari digits)
        XCTAssertEqual(TranscriptNormalizer.normalize("५०० मिलीसेकंड"), "500ms")
        XCTAssertEqual(TranscriptNormalizer.normalize("५ प्रतिशत"), "5%")
    }
}
