import SwiftUI
import MapKit
import CoreLocation

struct MapPinView: View {
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )
    @State private var pinLocation: CLLocationCoordinate2D? = nil
    @State private var hasCentredOnUser = false
    @State private var currentCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(
        latitude: 51.5074, longitude: -0.1278
    )

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) {
                    UserAnnotation()
                    if let pin = pinLocation {
                        Marker("Your spot", coordinate: pin).tint(Color.ledgerBrass)
                    }
                }
                .ignoresSafeArea()
                .onMapCameraChange { context in
                    currentCenter = context.region.center
                }
                .onReceive(locationManager.$userLocation) { location in
                    guard let location = location, !hasCentredOnUser else { return }
                    position = .region(MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    ))
                    currentCenter = location
                    hasCentredOnUser = true
                }

                Image(systemName: "plus.circle")
                    .font(.title)
                    .foregroundColor(.ledgerBrass)
                    .shadow(radius: 3)
                    .allowsHitTesting(false)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { pinLocation = currentCenter }) {
                            Label(pinLocation == nil ? "Drop Pin Here" : "Move Pin Here",
                                  systemImage: "mappin.circle.fill")
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Choose Location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        if let pin = pinLocation {
                            latitude = pin.latitude
                            longitude = pin.longitude
                        }
                        dismiss()
                    }
                    .disabled(pinLocation == nil)
                }
            }
        }
    }
}
