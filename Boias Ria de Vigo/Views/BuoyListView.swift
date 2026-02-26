import SwiftUI

struct BuoyListView: View {
    @ObservedObject var viewModel: BuoysViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Boias Visíveis", systemImage: "scope")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.visibleBuoys.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }

            if viewModel.visibleBuoys.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "water.waves")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Nenhuma boia")
                        .font(.headline)
                    Text("Nenhuma boia encontrada para este percurso.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.visibleBuoys) { buoy in
                        BuoyRowView(
                            buoy: buoy,
                            isSelected: viewModel.selectedBuoyId == buoy.id,
                            onSelect: { viewModel.selectBuoy(buoy) },
                            onDelete: { viewModel.removeBuoy(id: buoy.id) }
                        )
                    }
                }
            }
        }
    }
}

struct BuoyRowView: View {
    let buoy: Buoy
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                sideIndicator
                    .frame(width: 4, height: 40)
                    .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 4) {
                    Text(buoy.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)

                    Text("\(buoy.formattedLatitude), \(buoy.formattedLongitude)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()

                    if let description = buoy.description, !description.isEmpty {
                        Text(description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                if let side = buoy.side {
                    Text(side.displayName)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(side == .babor ? .red : .green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            (side == .babor ? Color.red : Color.green).opacity(0.12)
                        )
                        .clipShape(Capsule())
                }
            }
            .padding(12)
            .background(isSelected ? Color.accentColor.opacity(0.08) : Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentColor.opacity(0.3) : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Remover Boia", systemImage: "trash")
            }
        }
    }

    private var sideIndicator: some View {
        Group {
            switch buoy.side {
            case .babor:    Color.red
            case .estribor: Color.green
            case nil:       Color.blue
            }
        }
    }
}
