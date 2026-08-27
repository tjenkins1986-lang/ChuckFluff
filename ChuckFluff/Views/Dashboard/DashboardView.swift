import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var sessions: [FishingSession]
    @Query private var configs: [UserConfig]

    var totalFish: Int { sessions.reduce(0) { $0 + $1.totalFish } }
    var totalWeight: Double { sessions.reduce(0) { $0 + $1.totalWeight } }
    var bestSession: FishingSession? { sessions.max(by: { $0.totalFish < $1.totalFish }) }

    var speciesList: [String] { configs.first?.speciesList ?? [] }

    var speciesData: [(species: String, count: Int)] {
        var counts: [String: Int] = [:]
        for session in sessions {
            for catch_ in session.catches {
                counts[catch_.species, default: 0] += catch_.quantity
            }
        }
        return counts.map { (species: $0.key, count: $0.value) }.sorted { $0.count > $1.count }
    }

    var monthlyData: [(month: String, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        guard let twelveMonthsAgo = calendar.date(byAdding: .month, value: -11, to: now) else { return [] }
        let startOfWindow = calendar.date(from: calendar.dateComponents([.year, .month], from: twelveMonthsAgo)) ?? twelveMonthsAgo

        var counts: [String: Int] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        for session in sessions {
            guard session.date >= startOfWindow else { continue }
            let key = formatter.string(from: session.date)
            counts[key, default: 0] += session.totalFish
        }
        return counts.map { (month: $0.key, count: $0.value) }
            .sorted {
                let fmt = DateFormatter()
                fmt.dateFormat = "MMM yy"
                return (fmt.date(from: $0.month) ?? Date()) < (fmt.date(from: $1.month) ?? Date())
            }
    }

    func personalBestWeight(for species: String) -> Double? {
        var best: Double? = nil
        for session in sessions {
            for catch_ in session.catches where catch_.species == species && catch_.weightLb > 0 {
                if best == nil || catch_.weightLb > best! { best = catch_.weightLb }
            }
        }
        return best
    }

    func personalBestLength(for species: String) -> Double? {
        var best: Double? = nil
        for session in sessions {
            for catch_ in session.catches where catch_.species == species && catch_.lengthInches > 0 {
                if best == nil || catch_.lengthInches > best! { best = catch_.lengthInches }
            }
        }
        return best
    }

    func favouriteMethodData(for species: String) -> (method: String, count: Int)? {
        var counts: [String: Int] = [:]
        for session in sessions {
            for catch_ in session.catches where catch_.species == species {
                let m = catch_.method.trimmingCharacters(in: .whitespacesAndNewlines)
                if !m.isEmpty { counts[m, default: 0] += catch_.quantity }
            }
        }
        guard let top = counts.max(by: { $0.value < $1.value }) else { return nil }
        return (method: top.key, count: top.value)
    }

    var statCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()), GridItem(.flexible()),
            GridItem(.flexible()), GridItem(.flexible())
        ], spacing: 12) {
            StatCardView(title: "Sessions", value: "\(sessions.count)", icon: "calendar")
            StatCardView(title: "Total Fish", value: "\(totalFish)", icon: "fish.fill")
            StatCardView(title: "Total Weight", value: String(format: "%.1f lb", totalWeight), icon: "scalemass.fill")
            StatCardView(title: "Best Session", value: bestSession != nil ? "\(bestSession!.totalFish) fish" : "–", icon: "star.fill")
        }
        .padding(.horizontal)
    }

    private var sectionLabelFont: Font { .ledgerMono(10.5, weight: .medium) }

    var monthlyChart: some View {
        let maxCount = monthlyData.map { $0.count }.max() ?? 1
        let chartHeight: CGFloat = 120
        return VStack(alignment: .leading, spacing: 8) {
            Text("Catches Over Time")
                .font(sectionLabelFont).tracking(1.2).textCase(.uppercase)
                .foregroundColor(.ledgerTextLow)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(monthlyData, id: \.month) { item in
                        VStack(spacing: 4) {
                            Text("\(item.count)")
                                .font(.ledgerMono(11))
                                .foregroundColor(.ledgerTextMid)
                            RoundedRectangle(cornerRadius: LedgerMetric.radiusDot)
                                .fill(Color.ledgerBrass)
                                .frame(
                                    width: 44,
                                    height: max(8, chartHeight * CGFloat(item.count) / CGFloat(maxCount))
                                )
                            Text(item.month)
                                .font(.ledgerMono(10))
                                .foregroundColor(.ledgerTextLow)
                                .fixedSize()
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 160)
            }
            .padding(.vertical, 4)
            .ledgerTile()
            .padding(.horizontal)
        }
    }

    var speciesChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Species Breakdown")
                .font(sectionLabelFont).tracking(1.2).textCase(.uppercase)
                .foregroundColor(.ledgerTextLow)
                .padding(.horizontal)
            VStack(spacing: 8) {
                ForEach(speciesData, id: \.species) { item in
                    let maxCount = speciesData.first?.count ?? 1
                    HStack {
                        Text(item.species).font(.subheadline).foregroundColor(.ledgerTextHi)
                            .frame(width: 140, alignment: .leading)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: LedgerMetric.radiusDot)
                                    .fill(Color.ledgerInkRaised)
                                    .frame(maxWidth: .infinity)
                                RoundedRectangle(cornerRadius: LedgerMetric.radiusDot)
                                    .fill(Color.ledgerBrass)
                                    .frame(width: max(8, geo.size.width * CGFloat(item.count) / CGFloat(maxCount)))
                            }
                        }
                        .frame(height: 24)
                        Text("\(item.count)").font(.ledgerMono(13)).foregroundColor(.ledgerTextMid)
                            .frame(width: 36, alignment: .trailing)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 4)
            .ledgerTile()
            .padding(.horizontal)
        }
    }

    var recordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Records")
                .font(sectionLabelFont).tracking(1.2).textCase(.uppercase)
                .foregroundColor(.ledgerTextLow)
                .padding(.horizontal)
            VStack(spacing: 0) {
                ForEach(speciesList, id: \.self) { species in
                    HStack {
                        Text(species).font(.subheadline).foregroundColor(.ledgerTextHi)
                        Spacer()
                        if let recordText = recordText(for: species) {
                            Text(recordText)
                                .font(.ledgerDisplay(15)).foregroundColor(.ledgerBrass)
                        } else {
                            Text("No record yet")
                                .font(.subheadline).foregroundColor(.ledgerTextLow)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    if species != speciesList.last {
                        Divider().overlay(Color.ledgerLine).padding(.leading)
                    }
                }
            }
            .ledgerTile(padding: 0)
            .padding(.horizontal)
        }
    }

    /// Combines the species' personal-best weight and/or length, whichever were recorded.
    func recordText(for species: String) -> String? {
        let weight = personalBestWeight(for: species)
        let length = personalBestLength(for: species)
        switch (weight, length) {
        case let (w?, l?):
            return String(format: "%.1f lb · %.1f in", w, l)
        case let (w?, nil):
            return String(format: "%.1f lb", w)
        case let (nil, l?):
            return String(format: "%.1f in", l)
        case (nil, nil):
            return nil
        }
    }

    var methodsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Favourite Method")
                .font(sectionLabelFont).tracking(1.2).textCase(.uppercase)
                .foregroundColor(.ledgerTextLow)
                .padding(.horizontal)
            VStack(spacing: 0) {
                ForEach(speciesList, id: \.self) { species in
                    HStack {
                        Text(species).font(.subheadline).foregroundColor(.ledgerTextHi)
                            .frame(width: 130, alignment: .leading)
                        Spacer()
                        if let data = favouriteMethodData(for: species) {
                            Text(data.method)
                                .font(.subheadline).foregroundColor(.ledgerBrass)
                            Text("· \(data.count) fish")
                                .font(.ledgerMono(12)).foregroundColor(.ledgerTextLow)
                        } else {
                            Text("No data yet")
                                .font(.subheadline).foregroundColor(.ledgerTextLow)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    if species != speciesList.last {
                        Divider().overlay(Color.ledgerLine).padding(.leading)
                    }
                }
            }
            .ledgerTile(padding: 0)
            .padding(.horizontal)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statCards
                    if !monthlyData.isEmpty { monthlyChart }
                    if !speciesData.isEmpty { speciesChart }
                    if !speciesList.isEmpty { recordsSection }
                    if !speciesList.isEmpty { methodsSection }
                    if sessions.isEmpty {
                        ContentUnavailableView(
                            "No Data Yet",
                            systemImage: "chart.bar",
                            description: Text("Start logging sessions and your dashboard will come to life.")
                        )
                        .padding(.top, 40)
                    }
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .ledgerScreenBackground()
            .navigationTitle("Dashboard")
        }
    }
}
