import Foundation
import SwiftData

@Model
class UserConfig {
    var speciesList: [String]
    var rodList: [String]
    var reelList: [String]

    init(speciesList: [String] = [], rodList: [String] = [], reelList: [String] = []) {
        self.speciesList = speciesList
        self.rodList = rodList
        self.reelList = reelList
    }
}
