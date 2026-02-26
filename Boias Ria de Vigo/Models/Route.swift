import Foundation

enum RouteId: String, CaseIterable, Identifiable, Sendable {
    case all
    case numeral1
    case numeral2
    case numeral3
    case numeral4

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "Todas as Boias"
        case .numeral1: return "Numeral 1"
        case .numeral2: return "Numeral 2"
        case .numeral3: return "Numeral 3"
        case .numeral4: return "Numeral 4"
        }
    }

    var subtitle: String {
        switch self {
        case .all: return "Visão Geral"
        case .numeral1: return "Subrido (Babor) → La Negra (Babor)"
        case .numeral2: return "Subrido (Babor) → Met. Cíes (Babor)"
        case .numeral3: return "Lousal (Estribor) → Tofiño (Estribor)"
        case .numeral4: return "Lousal (Estribor) → Bondaña (Estribor)"
        }
    }

    var icon: String {
        switch self {
        case .all: return "globe.europe.africa"
        case .numeral1: return "1.circle.fill"
        case .numeral2: return "2.circle.fill"
        case .numeral3: return "3.circle.fill"
        case .numeral4: return "4.circle.fill"
        }
    }

    var buoyNames: [String] {
        switch self {
        case .all: return []
        case .numeral1: return ["Subrido", "La Negra"]
        case .numeral2: return ["Subrido", "Baliza Meteorológica Sur Cíes"]
        case .numeral3: return ["Lousal", "Tofiño"]
        case .numeral4: return ["Lousal", "Bondaña"]
        }
    }
}