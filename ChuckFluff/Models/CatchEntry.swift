import Foundation
import SwiftData

@Model
class CatchEntry {
    var species: String
    var weightLb: Double
    var quantity: Int
    var method: String

    init(species: String = "", weightLb: Double = 0, quantity: Int = 1, method: String = "") {
        self.species = species
        self.weightLb = weightLb
        self.quantity = quantity
        self.method = method
    }
}
