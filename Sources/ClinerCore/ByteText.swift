import Foundation

public enum ByteText {
    public static func format(_ bytes: Int64, locale: Locale = .current) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.unitOptions = .naturalScale
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 1
        formatter.numberFormatter.minimumFractionDigits = 0
        let measurement = Measurement(value: Double(max(0, bytes)), unit: UnitInformationStorage.bytes)
        return formatter.string(from: measurement)
    }
}
