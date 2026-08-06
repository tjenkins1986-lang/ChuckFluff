import Foundation
import SwiftData

@Model
class CatchEntry {
    var species: String
    var weightLb: Double
    var quantity: Int
    var method: String
    // 0 = not recorded.
    var lengthInches: Double

    init(species: String = "", weightLb: Double = 0, quantity: Int = 1, method: String = "", lengthInches: Double = 0) {
        self.species = species
        self.weightLb = weightLb
        self.quantity = quantity
        self.method = method
        self.lengthInches = lengthInches
    }
}
