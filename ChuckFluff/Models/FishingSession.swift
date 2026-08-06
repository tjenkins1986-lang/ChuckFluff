import Foundation
import SwiftData

@Model
class FishingSession {
    var sessionName: String
    var date: Date
    var locationName: String
    var latitude: Double
    var longitude: Double
    var weatherCondition: String
    // 999 marks "not entered" for air/water temperature — 0°C is a valid reading, so it can't be the sentinel.
    var temperatureCelsius: Double
    var waterTemperatureCelsius: Double
    var windSpeed: Double
    var windDirection: String
    // 0 = not recorded, for both.
    var gaugeHeight: Double
    var cubicFeetPerSecond: Double
    var startTime: Date
    var endTime: Date
    var duration: Double
    var notes: String
    var photoData: [Data]
    var rodUsed: String
    var reelUsed: String
    @Relationship(deleteRule: .cascade) var catches: [CatchEntry]

    init(sessionName: String = "",
         date: Date = .now,
         locationName: String = "",
         latitude: Double = 0,
         longitude: Double = 0,
         weatherCondition: String = "Sunny",
         temperatureCelsius: Double = 999,
         waterTemperatureCelsius: Double = 999,
         windSpeed: Double = 0,
         windDirection: String = "",
         gaugeHeight: Double = 0,
         cubicFeetPerSecond: Double = 0,
         startTime: Date = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date(),
         endTime: Date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date(),
         duration: Double = 0,
         notes: String = "",
         photoData: [Data] = [],
         rodUsed: String = "",
         reelUsed: String = "",
         catches: [CatchEntry] = []) {
        self.sessionName = sessionName
        self.date = date
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.weatherCondition = weatherCondition
        self.temperatureCelsius = temperatureCelsius
        self.waterTemperatureCelsius = waterTemperatureCelsius
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.gaugeHeight = gaugeHeight
        self.cubicFeetPerSecond = cubicFeetPerSecond
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.notes = notes
        self.photoData = photoData
        self.rodUsed = rodUsed
        self.reelUsed = reelUsed
        self.catches = catches
    }

    var totalFish: Int {
        catches.reduce(0) { $0 + $1.quantity }
    }

    var totalWeight: Double {
        catches.reduce(0) { $0 + ($1.weightLb * Double($1.quantity)) }
    }
}
