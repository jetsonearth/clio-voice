import Foundation
import SwiftUI

@MainActor
final class StreamingTextCache {
    struct Snapshot {
        let crisp: AttributedString
        let overlay: AttributedString
    }
    private(set) var snapshot = Snapshot(crisp: AttributedString(""), overlay: AttributedString(""))
    func set(_ newSnapshot: Snapshot) {
        snapshot = newSnapshot
    }
}



