import Foundation

enum CoordinateFormatter {
    static func format(_ value: Double, isLatitude: Bool) -> String {
        let absVal = abs(value)
        let degrees = Int(absVal)
        let minutes = (absVal - Double(degrees)) * 60.0

        let direction: String
        if isLatitude {
            direction = value >= 0 ? "N" : "S"
        } else {
            direction = value >= 0 ? "E" : "O"
        }

        return "\(degrees)° \(String(format: "%.3f", minutes))' \(direction)"
    }

    static func toDecimalDegrees(degrees: Int, minutes: Double, isNegative: Bool) -> Double {
        var result = Double(degrees) + (minutes / 60.0)
        if isNegative { result = -result }
        return result
    }
}