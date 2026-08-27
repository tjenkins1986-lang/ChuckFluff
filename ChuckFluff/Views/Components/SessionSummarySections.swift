import SwiftUI

/// Read-only summary sections for a saved session — shared by SessionDetailView (History tab)
/// and MapSessionSummaryView (Map tab pin sheet).

private func ledgerSectionHeader(_ title: String) -> some View {
    Text(title)
        .font(.ledgerMono(10.5, weight: .medium))
        .tracking(1.2)
        .textCase(.uppercase)
        .foregroundColor(.ledgerTextLow)
}

struct SessionDetailsSection: View {
    let session: FishingSession
    var showCoordinates: Bool = true

    var body: some View {
        Section(header: ledgerSectionHeader("Session Details")) {
            LabeledContent("Date", value: session.date.formatted(date: .long, time: .omitted))
            LabeledContent("Location", value: session.locationName)
            LabeledContent("Start Time", value: session.startTime.formatted(date: .omitted, time: .shortened))
            LabeledContent("End Time", value: session.endTime.formatted(date: .omitted, time: .shortened))
            LabeledContent("Duration", value: String(format: "%.1f hrs", session.duration))
            if showCoordinates && session.latitude != 0 {
                LabeledContent("Coordinates", value: String(format: "%.4f, %.4f", session.latitude, session.longitude))
            }
        }
        .listRowBackground(Color.ledgerInkSurface)
        .foregroundColor(.ledgerTextHi)
    }
}

struct SessionConditionsSection: View {
    let session: FishingSession

    var body: some View {
        Section(header: ledgerSectionHeader("Conditions")) {
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
            if session.gaugeHeight != 0 {
                LabeledContent("Gauge Height", value: String(format: "%.2f ft", session.gaugeHeight))
            }
            if session.cubicFeetPerSecond != 0 {
                LabeledContent("Flow", value: String(format: "%.1f cfs", session.cubicFeetPerSecond))
            }
        }
        .listRowBackground(Color.ledgerInkSurface)
        .foregroundColor(.ledgerTextHi)
    }
}

struct SessionGearSection: View {
    let session: FishingSession

    var body: some View {
        Group {
            if !session.rodUsed.isEmpty || !session.reelUsed.isEmpty {
                Section(header: ledgerSectionHeader("Gear")) {
                    if !session.rodUsed.isEmpty {
                        LabeledContent("Rod", value: session.rodUsed)
                    }
                    if !session.reelUsed.isEmpty {
                        LabeledContent("Reel", value: session.reelUsed)
                    }
                }
                .listRowBackground(Color.ledgerInkSurface)
                .foregroundColor(.ledgerTextHi)
            }
        }
    }
}

struct SessionCatchesSection: View {
    let session: FishingSession

    var body: some View {
        Section(header: ledgerSectionHeader(
            "Catches (\(session.totalFish) fish · \(String(format: "%.1f", session.totalWeight)) lb total)"
        )) {
            if session.catches.isEmpty {
                Text("No catches recorded").foregroundColor(.ledgerTextLow)
            } else {
                ForEach(session.catches) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.species).bold().foregroundColor(.ledgerTextHi)
                            Text(catchSummary(for: entry))
                                .font(.ledgerMono(12))
                                .foregroundColor(.ledgerTextMid)
                            if !entry.method.isEmpty {
                                Text("Method: \(entry.method)")
                                    .font(.caption).foregroundColor(.ledgerTextMid)
                            }
                        }
                        Spacer()
                        Text(String(format: "%.1f lb", entry.weightLb * Double(entry.quantity)))
                            .font(.ledgerDisplay(17))
                            .foregroundColor(.ledgerBrass)
                    }
                }
            }
        }
        .listRowBackground(Color.ledgerInkSurface)
    }

    private func catchSummary(for entry: CatchEntry) -> String {
        var summary = "Qty: \(entry.quantity) · \(String(format: "%.1f", entry.weightLb)) lb each"
        if entry.lengthInches != 0 {
            summary += " · \(String(format: "%.1f", entry.lengthInches)) in"
        }
        return summary
    }
}
