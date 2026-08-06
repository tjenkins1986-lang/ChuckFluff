import SwiftUI
import SwiftData
import PhotosUI

struct EditSessionView: View {
    let session: FishingSession
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var configs: [UserConfig]

    @State private var sessionName: String
    @State private var date: Date
    @State private var locationName: String
    @State private var weatherCondition: String
    @State private var temperatureCelsius: Double
    @State private var waterTemperatureCelsius: Double
    @State private var showTempPicker = false
    @State private var showWaterTempPicker = false
    @State private var windSpeed: String
    @State private var windDirection: String
    @State private var gaugeHeight: String
    @State private var cubicFeetPerSecond: String
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var notes: String
    @State private var showNoteSheet = false
    @State private var catches: [DraftCatch]
    @State private var photoData: [Data]
    @State private var rodUsed: String
    @State private var reelUsed: String
    @State private var showAddCatch = false
    @State private var showMap = false
    @State private var pinnedLatitude: Double?
    @State private var pinnedLongitude: Double?
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @FocusState private var focusedField: EditField?

    enum EditField {
        case sessionName, locationName, windSpeed, gaugeHeight, cubicFeetPerSecond
    }

    var config: UserConfig? { configs.first }

    var calculatedDuration: Double {
        var end = endTime
        if endTime < startTime {
            end = Calendar.current.date(byAdding: .day, value: 1, to: endTime) ?? endTime
        }
        return end.timeIntervalSince(startTime) / 3600
    }

    var isNextDay: Bool { endTime < startTime }

    init(session: FishingSession) {
        self.session = session
        _sessionName = State(initialValue: session.sessionName)
        _date = State(initialValue: session.date)
        _locationName = State(initialValue: session.locationName)
        _weatherCondition = State(initialValue: session.weatherCondition)
        _temperatureCelsius = State(initialValue: session.temperatureCelsius)
        _waterTemperatureCelsius = State(initialValue: session.waterTemperatureCelsius)
        _windSpeed = State(initialValue: session.windSpeed == 0 ? "" : String(session.windSpeed))
        _windDirection = State(initialValue: session.windDirection)
        _gaugeHeight = State(initialValue: session.gaugeHeight == 0 ? "" : String(session.gaugeHeight))
        _cubicFeetPerSecond = State(initialValue: session.cubicFeetPerSecond == 0 ? "" : String(session.cubicFeetPerSecond))
        _startTime = State(initialValue: session.startTime)
        _endTime = State(initialValue: session.endTime)
        _notes = State(initialValue: session.notes)
        _catches = State(initialValue: session.catches.map {
            DraftCatch(species: $0.species, weightLb: $0.weightLb, quantity: $0.quantity, method: $0.method, lengthInches: $0.lengthInches)
        })
        _photoData = State(initialValue: session.photoData)
        _rodUsed = State(initialValue: session.rodUsed)
        _reelUsed = State(initialValue: session.reelUsed)
        _pinnedLatitude = State(initialValue: session.latitude == 0 ? nil : session.latitude)
        _pinnedLongitude = State(initialValue: session.longitude == 0 ? nil : session.longitude)
    }

    var sessionDetailsBox: some View {
        GroupBox(label: Label("Session Details", systemImage: "calendar")) {
            VStack(spacing: 12) {
                TextField("Session name", text: $sessionName)
                    .focused($focusedField, equals: .sessionName)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onTapGesture { focusedField = .sessionName }
                SessionTimingFields(date: $date, startTime: $startTime, endTime: $endTime,
                                     duration: calculatedDuration, isNextDay: isNextDay)
            }
            .padding(.top, 8)
        }
        .formBoxPadding(top: 16)
    }

    var locationBox: some View {
        GroupBox(label: Label("Location", systemImage: "map.fill")) {
            VStack(spacing: 12) {
                TextField("Location name", text: $locationName)
                    .focused($focusedField, equals: .locationName)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onTapGesture { focusedField = .locationName }
                Button(action: { showMap = true }) {
                    HStack {
                        Image(systemName: "map.fill").foregroundColor(.blue)
                        Text(pinnedLatitude != nil ? "Pin set ✓ — tap to change" : "Drop a pin on the map")
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary).font(.caption)
                    }
                }
                .buttonStyle(.plain)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                if let lat = pinnedLatitude, let lon = pinnedLongitude {
                    HStack {
                        Image(systemName: "mappin.circle.fill").foregroundColor(.red)
                        Text("📍 \(lat, specifier: "%.4f"), \(lon, specifier: "%.4f")")
                            .font(.caption).foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(.top, 8)
        }
        .formBoxPadding()
    }

    var conditionsBox: some View {
        GroupBox(label: Label("Conditions", systemImage: "cloud.sun.fill")) {
            VStack(spacing: 12) {
                WeatherPickerRow(weatherCondition: $weatherCondition)
                Divider()
                TemperaturePickerRow(title: "Air Temp (°C)", temperatureCelsius: $temperatureCelsius) {
                    showTempPicker = true
                }
                Divider()
                TemperaturePickerRow(title: "Water Temp (°C)", temperatureCelsius: $waterTemperatureCelsius) {
                    showWaterTempPicker = true
                }
                Divider()
                windSpeedRow
                Divider()
                WindDirectionPickerRow(windDirection: $windDirection)
                Divider()
                gaugeHeightRow
                Divider()
                flowRow
            }
            .padding(.top, 8)
        }
        .formBoxPadding()
    }

    var windSpeedRow: some View {
        HStack {
            Text("Wind Speed (mph)")
            Spacer()
            TextField("optional", text: $windSpeed)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
                .focused($focusedField, equals: .windSpeed)
                .textFieldStyle(.roundedBorder)
                .onTapGesture { focusedField = .windSpeed }
        }
    }

    var gaugeHeightRow: some View {
        HStack {
            Text("Gauge Height (ft)")
            Spacer()
            TextField("optional", text: $gaugeHeight)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
                .focused($focusedField, equals: .gaugeHeight)
                .textFieldStyle(.roundedBorder)
                .onTapGesture { focusedField = .gaugeHeight }
        }
    }

    var flowRow: some View {
        HStack {
            Text("Flow (cfs)")
            Spacer()
            TextField("optional", text: $cubicFeetPerSecond)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
                .focused($focusedField, equals: .cubicFeetPerSecond)
                .textFieldStyle(.roundedBorder)
                .onTapGesture { focusedField = .cubicFeetPerSecond }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    sessionDetailsBox
                    locationBox
                    conditionsBox
                    GearPickerBox(rodUsed: $rodUsed, reelUsed: $reelUsed,
                                  rodList: config?.rodList ?? [], reelList: config?.reelList ?? [])
                    CatchesListBox(catches: $catches, showAddCatch: $showAddCatch, emptyMessage: "No catches recorded")
                    PhotosBox(photoData: $photoData, selectedPhotos: $selectedPhotos)
                    NotesBox(notes: $notes, showNoteSheet: $showNoteSheet)
                }
            }
            .onAppear { focusedField = nil }
            .navigationTitle("Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEdits() }
                        .disabled(locationName.isEmpty)
                }
            }
            .sheet(isPresented: $showMap, onDismiss: { focusedField = nil }) {
                MapPinView(latitude: $pinnedLatitude, longitude: $pinnedLongitude)
            }
            .sheet(isPresented: $showAddCatch, onDismiss: { focusedField = nil }) {
                AddCatchView(catches: $catches)
            }
            .sheet(isPresented: $showNoteSheet) {
                NoteEditorView(note: $notes)
            }
            .sheet(isPresented: $showTempPicker) {
                TemperaturePickerView(title: "Air Temperature", temperatureCelsius: $temperatureCelsius)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showWaterTempPicker) {
                TemperaturePickerView(title: "Water Temperature", temperatureCelsius: $waterTemperatureCelsius)
                    .presentationDetents([.medium])
            }
        }
    }

    func saveEdits() {
        session.sessionName = sessionName
        session.date = date
        session.locationName = locationName
        session.latitude = pinnedLatitude ?? session.latitude
        session.longitude = pinnedLongitude ?? session.longitude
        session.weatherCondition = weatherCondition
        session.temperatureCelsius = temperatureCelsius
        session.waterTemperatureCelsius = waterTemperatureCelsius
        session.windSpeed = Double(windSpeed) ?? 0
        session.windDirection = windDirection
        session.gaugeHeight = Double(gaugeHeight) ?? 0
        session.cubicFeetPerSecond = Double(cubicFeetPerSecond) ?? 0
        session.startTime = startTime
        session.endTime = endTime
        session.duration = calculatedDuration
        session.notes = notes
        session.photoData = photoData
        session.rodUsed = rodUsed
        session.reelUsed = reelUsed
        for entry in session.catches { modelContext.delete(entry) }
        session.catches = catches.map {
            CatchEntry(species: $0.species, weightLb: $0.weightLb, quantity: $0.quantity, method: $0.method, lengthInches: $0.lengthInches)
        }
        dismiss()
    }
}
