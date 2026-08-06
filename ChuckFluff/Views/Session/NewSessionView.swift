import SwiftUI
import SwiftData
import PhotosUI
import CoreLocation

struct NewSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var configs: [UserConfig]

    @State private var sessionName = ""
    @State private var date = Date()
    @State private var locationName = ""
    @State private var weatherCondition = "Sunny"
    @State private var temperatureCelsius: Double = 999
    @State private var waterTemperatureCelsius: Double = 999
    @State private var showTempPicker = false
    @State private var showWaterTempPicker = false
    @State private var showNameSheet = false
    @State private var showLocationSheet = false
    @State private var showWindSpeedSheet = false
    @State private var windSpeed = ""
    @State private var windDirection = ""
    @State private var startTime: Date = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime: Date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var notes = ""
    @State private var showNoteSheet = false
    @State private var showMap = false
    @State private var pinnedLatitude: Double? = nil
    @State private var pinnedLongitude: Double? = nil
    @State private var catches: [DraftCatch] = []
    @State private var showAddCatch = false
    @State private var showingSaved = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []
    @State private var rodUsed = ""
    @State private var reelUsed = ""
    @StateObject private var locationManager = LocationManager()

    var config: UserConfig? { configs.first }

    var calculatedDuration: Double {
        var end = endTime
        if endTime < startTime {
            end = Calendar.current.date(byAdding: .day, value: 1, to: endTime) ?? endTime
        }
        return end.timeIntervalSince(startTime) / 3600
    }

    var isNextDay: Bool { endTime < startTime }

    var sessionDetailsBox: some View {
        GroupBox(label: Label("Session Details", systemImage: "calendar")) {
            VStack(spacing: 12) {
                Button(action: { showNameSheet = true }) {
                    HStack {
                        Text("Session Name")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(sessionName.isEmpty ? "optional" : sessionName)
                            .foregroundColor(sessionName.isEmpty ? .secondary : .primary)
                            .lineLimit(1)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary).font(.caption)
                    }
                }
                .buttonStyle(.plain)
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
                Button(action: { showLocationSheet = true }) {
                    HStack {
                        Text("Location Name")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(locationName.isEmpty ? "required" : locationName)
                            .foregroundColor(locationName.isEmpty ? .secondary : .primary)
                            .lineLimit(1)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary).font(.caption)
                    }
                }
                .buttonStyle(.plain)

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

                Button(action: useGPS) {
                    HStack {
                        Image(systemName: "location.fill").foregroundColor(.blue)
                        Text("Use my current location")
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
        GroupBox(label: Label("Conditions (Optional)", systemImage: "cloud.sun.fill")) {
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
            }
            .padding(.top, 8)
        }
        .formBoxPadding()
    }

    var windSpeedRow: some View {
        Button(action: { showWindSpeedSheet = true }) {
            HStack {
                Text("Wind Speed (mph)").foregroundColor(.primary)
                Spacer()
                Text(windSpeed.isEmpty ? "optional" : windSpeed)
                    .foregroundColor(windSpeed.isEmpty ? .secondary : .primary)
                Image(systemName: "chevron.right").foregroundColor(.secondary).font(.caption)
            }
        }
        .buttonStyle(.plain)
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
                    CatchesListBox(catches: $catches, showAddCatch: $showAddCatch)
                    PhotosBox(photoData: $photoData, selectedPhotos: $selectedPhotos, title: "Photos (Optional)")
                    NotesBox(notes: $notes, showNoteSheet: $showNoteSheet)
                }
            }
            .navigationTitle("New Session")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveSession() }
                        .disabled(locationName.isEmpty)
                }
            }
            .sheet(isPresented: $showMap) {
                MapPinView(latitude: $pinnedLatitude, longitude: $pinnedLongitude)
            }
            .sheet(isPresented: $showAddCatch) {
                AddCatchView(catches: $catches)
            }
            .sheet(isPresented: $showNoteSheet) {
                NoteEditorView(note: $notes)
            }
            .sheet(isPresented: $showNameSheet) {
                AddItemSheet(
                    title: "Session Name",
                    placeholder: "e.g. Opening Day on the Tay",
                    isPresented: $showNameSheet
                ) { name in
                    sessionName = name
                }
                .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showLocationSheet) {
                AddItemSheet(
                    title: "Location Name",
                    placeholder: "e.g. River Tay",
                    isPresented: $showLocationSheet
                ) { name in
                    locationName = name
                }
                .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showWindSpeedSheet) {
                AddItemSheet(
                    title: "Wind Speed (mph)",
                    placeholder: "e.g. 12",
                    isPresented: $showWindSpeedSheet
                ) { value in
                    windSpeed = value
                }
                .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $showTempPicker) {
                TemperaturePickerView(title: "Air Temperature", temperatureCelsius: $temperatureCelsius)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showWaterTempPicker) {
                TemperaturePickerView(title: "Water Temperature", temperatureCelsius: $waterTemperatureCelsius)
                    .presentationDetents([.medium])
            }
            .alert("Session Saved!", isPresented: $showingSaved) {
                Button("OK") {
                    resetForm()
                }
            } message: {
                Text("Your fishing session has been logged.")
            }
        }
    }

    func useGPS() {
        if let location = locationManager.userLocation {
            pinnedLatitude = location.latitude
            pinnedLongitude = location.longitude
        }
    }

    func saveSession() {
        let session = FishingSession(
            sessionName: sessionName,
            date: date,
            locationName: locationName,
            latitude: pinnedLatitude ?? 0,
            longitude: pinnedLongitude ?? 0,
            weatherCondition: weatherCondition,
            temperatureCelsius: temperatureCelsius,
            waterTemperatureCelsius: waterTemperatureCelsius,
            windSpeed: Double(windSpeed) ?? 0,
            windDirection: windDirection,
            startTime: startTime,
            endTime: endTime,
            duration: calculatedDuration,
            notes: notes,
            photoData: photoData,
            rodUsed: rodUsed,
            reelUsed: reelUsed,
            catches: catches.map {
                CatchEntry(species: $0.species, weightLb: $0.weightLb, quantity: $0.quantity, method: $0.method)
            }
        )
        modelContext.insert(session)
        showingSaved = true
    }

    func resetForm() {
        sessionName = ""
        date = Date()
        locationName = ""
        temperatureCelsius = 999
        waterTemperatureCelsius = 999
        windSpeed = ""
        windDirection = ""
        startTime = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date()
        endTime = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
        notes = ""
        catches = []
        photoData = []
        selectedPhotos = []
        pinnedLatitude = nil
        pinnedLongitude = nil
        rodUsed = ""
        reelUsed = ""
    }
}
