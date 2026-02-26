import SwiftUI

struct RouteSelectorView: View {
    @ObservedObject var viewModel: BuoysViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Percursos", systemImage: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath")
                .font(.headline)
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(RouteId.allCases) { route in
                        RouteChip(
                            route: route,
                            isActive: viewModel.activeRoute == route,
                            action: {
                                viewModel.selectRoute(route)
                            }
                        )
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
}

struct RouteChip: View {
    let route: RouteId
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: route.icon)
                        .font(.subheadline.weight(.semibold))
                    Text(route.label)
                        .font(.subheadline.weight(.semibold))
                }

                Text(route.subtitle)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minWidth: 120, alignment: .leading)
            .background(isActive ? Color.accentColor : Color(UIColor.tertiarySystemBackground))
            .foregroundColor(isActive ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
