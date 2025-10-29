import XCTest
@testable import Clio

final class RawDisfluencySanitizerTests: XCTestCase {

    func testRemovesLeadingChineseFiller() {
        let input = "嗯, 你好。"
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "你好。")
    }

    func testRemovesEnglishFillersWithDash() {
        let input = "So, basically, um-- we should try again."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "We should try again.")
    }

    func testKeepsLegitimateWordUsage() {
        let input = "I like apples and you know the recipe."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), input)
    }

    func testMixedLanguageCleanup() {
        let input = "嗯 我觉得 uh 我们可以先试试。"
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "我觉得我们可以先试试。")
    }

    func testRemovesBracketedLike() {
        let input = "It's, like, really good."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "It's really good.")
    }

    func testMaintainsCommaWhenRemovingMiddleFiller() {
        let input = "I think we fixed it, uh, the feature is good, but just one thing--"
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "I think we fixed it, the feature is good, but just one thing")
    }

    func testCapitalizesAfterRemovingLeadingEnglishFiller() {
        let input = "Uh, yes."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "Yes.")
    }

    func testDoesNotAlterMixedCaseWithoutFillers() {
        let input = "Stop. iPhone is new."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), input)
    }

    func testKeepsRightTagQuestion() {
        let input = "This is the right move, right?"
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), input)
    }

    func testSpanishEhLeadingFiller() {
        let input = "Eh, podemos empezar."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "Podemos empezar.")
    }

    func testSpanishPhraseOSea() {
        let input = "O sea, deberíamos intentarlo."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "Deberíamos intentarlo.")
    }

    func testGermanAhem() {
        let input = "Ähm, das ist gut."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "Das ist gut.")
    }

    func testFrenchEuh() {
        let input = "Euh, merci beaucoup."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "Merci beaucoup.")
    }

    func testJapaneseEtto() {
        let input = "えっと、始めましょう。"
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "始めましょう。")
    }

    func testKoreanEum() {
        let input = "음, 좋아요."
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "좋아요.")
    }

    func testRemovesSpaceAfterChineseSentenceBeforeLatin() {
        let input = "我觉得没什么问题。 okay, great!"
        XCTAssertEqual(RawDisfluencySanitizer.clean(input), "我觉得没什么问题。okay, great!")
    }
}
