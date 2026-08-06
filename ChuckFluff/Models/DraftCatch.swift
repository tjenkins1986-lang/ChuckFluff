import Foundation

/// An in-progress catch entry being built in the New/Edit Session forms, before it's
/// converted into a persisted `CatchEntry` on save.
struct DraftCatch {
    var species: String
    var weightLb: Double
    var quantity: Int
    var method: String
}
