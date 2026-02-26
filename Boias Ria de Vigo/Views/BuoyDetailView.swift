import SwiftUI
import MapKit

struct BuoyDetailView: View {
    let buoy: Buoy
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion

    init(buoy: Buoy, onDelete: @escaping () -> Void) {
        self.buoy = buoy
        self.onDelete = onDelete
        _region = State(initialValue: MKCoordinateRegion(
            center: buoy.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Map(coordinateRegion: .constant(region),
                        annotationItems: [buoy]) { b in
                        MapMarker(coordinate: b.coordinate, tint: markerColor)
                    }
                    .frame(height: 220)
                    .disabled(true)

                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text(buoy.name)
                                .font(.title2.bold())

                            if let side = buoy.side {
                                Text(side.displayName)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(side == .babor ? .red : .green)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        (side == .babor ? Color.red : Color.green).opacity(0.12)
                                    )
                                    .clipShape(Capsule())
                            }
                        }

                        VStack(spacing: 12) {
                            coordinateRow(label: "Latitude", value: buoy.formattedLatitude)
                            coordinateRow(label: "Longitude", value: buoy.formattedLongitude)
                            coordinateRow(label: "Decimal", value: String(format: "%.5f, %.5f", buoy.latitude, buoy.longitude))
                        }
                        .padding(16)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        if let description = buoy.description, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Descrição", systemImage: "text.alignleft")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)

                                Text(description)
                                    .font(.body)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Text("Adicionada em \(buoy.createdAt, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(role: .destructive) {
                            onDelete()
                            dismiss()
                        } label: {
                            Label("Remover Boia", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    private func coordinateRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit())
                .foregroundColor(.primary)
        }
    }

    private var markerColor: Color {
        guard let side = buoy.side else { return .blue }
        return side == .babor ? .red : .green
    }
}
