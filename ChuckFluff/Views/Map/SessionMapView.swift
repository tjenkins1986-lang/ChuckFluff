import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct SessionMapView: View {
    @Query private var sessions: [FishingSession]
    @StateObject private var locationManager = LocationManager()
    @State private var selectedSession: FishingSession? = nil
    @State private var hasCentredOnUser = false
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
        )
    )

    var pinnedSessions: [FishingSession] {
        sessions.filter { session in session.latitude != 0 }
    }

    var emptyStateView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Save sessions with a location pin to see them here")
                    .font(.caption)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .padding()
                Spacer()
            }
            .padding(.bottom, 40)
        }
    }

    func annotationButton(for session: FishingSession) -> some View {
        Button(action: { selectedSession = session }) {
            ZStack {
                Circle().fill(.blue).frame(width: 36, height: 36)
                Image(systemName: "fish.fill").foregroundColor(.white).font(.system(size: 16))
            }
        }
    }

    var mapContent: some View {
        ZStack {
            Map(position: $position) {
                UserAnnotation()
                ForEach(pinnedSessions) { session in
                    Annotation(
                        session.locationName,
                        coordinate: CLLocationCoordinate2D(
                            latitude: session.latitude,
                            longitude: session.longitude
                        )
                    ) {
                        annotationButton(for: session)
                    }
                }
            }
            .ignoresSafeArea()
            .onReceive(locationManager.$userLocation) { location in
                guard let location = location, !hasCentredOnUser else { return }
                position = .region(MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
                ))
                hasCentredOnUser = true
            }
            if pinnedSessions.isEmpty { emptyStateView }
        }
    }

    var body: some View {
        NavigationStack {
            mapContent
                .navigationTitle("Map")
                .sheet(item: $selectedSession) { session in
                    MapSessionSummaryView(session: session)
                        .presentationDetents([.medium])
                }
        }
    }
}
