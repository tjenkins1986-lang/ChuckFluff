import SwiftUI

/// Read-only summary sections for a saved session — shared by SessionDetailView (History tab)
/// and MapSessionSummaryView (Map tab pin sheet).

struct SessionDetailsSection: View {
    let session: FishingSession
    var showCoordinates: Bool = true

    var body: some View {
        Section("Session Details") {
            LabeledContent("Date", value: session.date.formatted(date: .long, time: .omitted))
            LabeledContent("Location", value: session.locationName)
            LabeledContent("Start Time", value: session.startTime.formatted(date: .omitted, time: .shortened))
            LabeledContent("End Time", value: session.endTime.formatted(date: .omitted, time: .shortened))
            LabeledContent("Duration", value: String(format: "%.1f hrs", session.duration))
            if showCoordinates && session.latitude != 0 {
                LabeledContent("Coordinates", value: String(format: "%.4f, %.4f", session.latitude, session.longitude))
            }
        }
    }
}

struct SessionConditionsSection: View {
    let session: FishingSession

    var body: some View {
        Section("Conditions") {
            LabeledContent("Weather", value: session.weatherCondition)
            if session.temperatureCelsius != 999 {
                LabeledContent("Air Temp", value: String(format: "%.0f°C", session.temperatureCelsius))
            }
            if session.waterTemperatureCelsius != 999 {
                LabeledContent("Water Temp", value: String(format: "%.0f°C", session.waterTemperatureCelsius))
            }
            if session.windSpeed != 0 {
                LabeledContent("Wind Speed", value: String(format: "%.1f mph", session.windSpeed))
            }
            if !session.windDirection.isEmpty {
                LabeledContent("Wind Direction", value: session.windDirection)
            }
        }
    }
}

struct SessionGearSection: View {
    let session: FishingSession

    var body: some View {
        Group {
            if !session.rodUsed.isEmpty || !session.reelUsed.isEmpty {
                Section("Gear") {
                    if !session.rodUsed.isEmpty {
                        LabeledContent("Rod", value: session.rodUsed)
                    }
                    if !session.reelUsed.isEmpty {
                        LabeledContent("Reel", value: session.reelUsed)
                    }
                }
            }
        }
    }
}

struct SessionCatchesSection: View {
    let session: FishingSession

    var body: some View {
        Section("Catches (\(session.totalFish) fish · \(String(format: "%.1f", session.totalWeight)) lb total)") {
            if session.catches.isEmpty {
                Text("No catches recorded").foregroundColor(.secondary)
            } else {
                ForEach(session.catches) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.species).bold()
                            Text("Qty: \(entry.quantity) · \(String(format: "%.1f", entry.weightLb)) lb each")
                                .font(.caption).foregroundColor(.secondary)
                            if !entry.method.isEmpty {
                                Text("Method: \(entry.method)").font(.caption).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Text(String(format: "%.1f lb", entry.weightLb * Double(entry.quantity)))
                            .font(.subheadline).foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
