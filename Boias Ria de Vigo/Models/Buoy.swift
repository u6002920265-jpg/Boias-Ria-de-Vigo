import Foundation
import MapKit

enum BuoySide: String, Codable, Sendable, CaseIterable {
    case babor = "Babor"
    case estribor = "Estribor"

    var displayName: String { rawValue }
}

struct Buoy: Identifiable, Sendable {
    let id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var description: String?
    var side: BuoySide?
    let createdAt: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var formattedLatitude: String {
        CoordinateFormatter.format(latitude, isLatitude: true)
    }

    var formattedLongitude: String {
        CoordinateFormatter.format(longitude, isLatitude: false)
    }
}