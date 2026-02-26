import Foundation
import MapKit
import SwiftUI

final class BuoysViewModel: ObservableObject {
    @Published var buoys: [Buoy] = []
    @Published var activeRoute: RouteId = .all
    @Published var selectedBuoyId: String?
    @Published var cameraRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.2328, longitude: -8.7226),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    var visibleBuoys: [Buoy] {
        guard activeRoute != .all else { return buoys }
        let names = activeRoute.buoyNames
        return buoys.filter { names.contains($0.name) }
    }

    var routeCoordinates: [CLLocationCoordinate2D] {
        guard activeRoute != .all else { return [] }
        let ordered = activeRoute.buoyNames.compactMap { name in
            buoys.first { $0.name == name }
        }
        return ordered.map(\.coordinate)
    }

    var selectedBuoy: Buoy? {
        guard let selectedBuoyId else { return nil }
        return buoys.first { $0.id == selectedBuoyId }
    }

    init() {
        loadInitialBuoys()
    }

    func addBuoy(name: String, latitude: Double, longitude: Double, description: String?, side: BuoySide?) {
        let buoy = Buoy(
            id: UUID().uuidString,
            name: name,
            latitude: latitude,
            longitude: longitude,
            description: description,
            side: side,
            createdAt: Date()
        )
        buoys.append(buoy)
    }

    func removeBuoy(id: String) {
        buoys.removeAll { $0.id == id }
        if selectedBuoyId == id {
            selectedBuoyId = nil
        }
    }

    func selectBuoy(_ buoy: Buoy) {
        selectedBuoyId = buoy.id
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            cameraRegion = MKCoordinateRegion(
                center: buoy.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }

    func selectRoute(_ route: RouteId) {
        activeRoute = route
        selectedBuoyId = nil
        fitMapToVisibleBuoys(for: route)
    }

    private func fitMapToVisibleBuoys(for route: RouteId) {
        let targets: [Buoy]
        if route == .all {
            targets = buoys
        } else {
            let names = route.buoyNames
            targets = buoys.filter { names.contains($0.name) }
        }
        guard !targets.isEmpty else { return }

        let lats = targets.map(\.latitude)
        let lngs = targets.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lngs.min()! + lngs.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(lats.max()! - lats.min()!, 0.05) * 1.5,
            longitudeDelta: max(lngs.max()! - lngs.min()!, 0.05) * 1.5
        )
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            cameraRegion = MKCoordinateRegion(center: center, span: span)
        }
    }

    private func loadInitialBuoys() {
        // Babor (port/red) buoys — routes 1 and 2
        addBuoy(
            name: "Subrido",
            latitude: 42.24351,
            longitude: -8.86414,
            description: "Boia lateral cilíndrica vermelha nº2. Boca Norte da Ría. Reflector radar. Luz vermelha, 4 lampejos/11s.",
            side: .babor
        )
        addBuoy(
            name: "La Negra",
            latitude: 42.15333,
            longitude: -8.88833,
            description: "Boia cardinal Oeste. Marcação N das Serralleiras. Luz branca, 9 lampejos/15s.",
            side: .babor
        )
        addBuoy(
            name: "Baliza Meteorológica Sur Cíes",
            latitude: 42.16900,
            longitude: -8.91100,
            description: "Boia meteorológica e oceanográfica (ODAS). Dados de vento, ondulação e temperatura. Boca Sul das Ilhas Cíes.",
            side: .babor
        )

        // Estribor (starboard/green) buoys — routes 3 and 4
        addBuoy(
            name: "Lousal",
            latitude: 42.27475,
            longitude: -8.68928,
            description: "Boia lateral nº12. Baixo de Lousal, plataforma rochosa a 7,7m de profundidade. Aprox. 600m a sul de Punta Domaio.",
            side: .estribor
        )
        addBuoy(
            name: "Tofiño",
            latitude: 42.22847,
            longitude: -8.77869,
            description: "Torre baliza verde nº3. Baixo Tofiño, ribeira sul da Ría. Luz verde, GpD(4)/11s, alcance 5Mn.",
            side: .estribor
        )
        addBuoy(
            name: "Bondaña",
            latitude: 42.20667,
            longitude: -8.80833,
            description: "Baliza baixo Bondaña nº1. Balizamento geral da Ría de Vigo. Reflector radar.",
            side: .estribor
        )
    }
}
