import SwiftUI
import SwiftData

struct AddCatchView: View {
    @Binding var catches: [DraftCatch]
    @Environment(\.dismiss) private var dismiss
    @Query private var configs: [UserConfig]

    @State private var species = ""
    @State private var customSpecies = ""
    @State private var quantity = 1
    @State private var stage: AddCatchStage = .selectSpecies
    @State private var weightStrings: [String] = []
    @State private var methodStrings: [String] = []

    enum AddCatchStage {
        case selectSpecies
        case enterWeights
    }

    var speciesList: [String] {
        let list = configs.first?.speciesList ?? []
        return list + ["Other"]
    }

    var effectiveSpecies: String {
        species == "Other" ? customSpecies : species
    }

    var canProceed: Bool {
        if species.isEmpty { return false }
        if species == "Other" && customSpecies.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        return true
    }

    var allWeightsEntered: Bool {
        weightStrings.allSatisfy { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Group {
                if stage == .selectSpecies {
                    speciesView
                } else {
                    weightsView
                }
            }
            .navigationTitle(stage == .selectSpecies ? "Add Catch" : effectiveSpecies)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(stage == .selectSpecies ? "Cancel" : "Back") {
                        if stage == .selectSpecies { dismiss() } else { stage = .selectSpecies }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if stage == .selectSpecies {
                        Button("Next") {
                            weightStrings = Array(repeating: "", count: quantity)
                            methodStrings = Array(repeating: "", count: quantity)
                            stage = .enterWeights
                        }
                        .disabled(!canProceed)
                    } else {
                        Button("Add") { saveCatches() }
                            .disabled(!allWeightsEntered)
                    }
                }
            }
        }
    }

    var speciesView: some View {
        Form {
            Section(header: Text("Select Species"),
                    footer: configs.first?.speciesList.isEmpty != false ?
                    Text("⚙️ No species added yet — go to the Settings & Help tab to add your target species.") :
                        Text("")) {
                if configs.first?.speciesList.isEmpty != false {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle").foregroundColor(.blue)
                        Text("Add your target species in the Settings & Help tab first.")
                            .foregroundColor(.secondary).font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
                ForEach(speciesList, id: \.self) { s in
                    Button(action: {
                        species = s
                        if s != "Other" { customSpecies = "" }
                    }) {
                        HStack {
                            Text(s).foregroundColor(.primary)
                            Spacer()
                            if species == s {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            if species == "Other" {
                Section("Species Name") {
                    TextField("Enter species name", text: $customSpecies)
                        .autocorrectionDisabled()
                }
            }
            Section("Number of Fish") {
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...50)
            }
        }
    }

    var weightsView: some View {
        Form {
            Section(header: Text("Enter details for each \(effectiveSpecies)"),
                    footer: Text("Weight in lb. Method is optional.")) {
                ForEach(0..<quantity, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fish \(i + 1)").bold()
                        HStack {
                            Text("Weight").foregroundColor(.secondary)
                            Spacer()
                            TextField("0.0", text: Binding(
                                get: { weightStrings[i] },
                                set: { newValue in
                                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                                    weightStrings[i] = filtered
                                }
                            ))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            Text("lb").foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Method").foregroundColor(.secondary)
                            Spacer()
                            TextField("e.g. Dry fly, Nymph, Spinner", text: Binding(
                                get: { methodStrings[i] },
                                set: { methodStrings[i] = $0 }
                            ))
                            .multilineTextAlignment(.trailing)
                            .frame(width: 200)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            Section("Summary") {
                HStack {
                    Text("Species")
                    Spacer()
                    Text(effectiveSpecies).foregroundColor(.secondary)
                }
                HStack {
                    Text("Total Fish")
                    Spacer()
                    Text("\(quantity)").foregroundColor(.secondary)
                }
                HStack {
                    Text("Total Weight")
                    Spacer()
                    let total = weightStrings.compactMap { Double($0) }.reduce(0, +)
                    Text(String(format: "%.1f lb", total)).foregroundColor(.secondary)
                }
            }
        }
    }

    func saveCatches() {
        for i in 0..<quantity {
            let weight = Double(weightStrings[i]) ?? 0
            catches.append(DraftCatch(
                species: effectiveSpecies,
                weightLb: weight,
                quantity: 1,
                method: methodStrings[i]
            ))
        }
        dismiss()
    }
}
