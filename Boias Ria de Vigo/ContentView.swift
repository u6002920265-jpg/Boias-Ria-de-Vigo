import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BuoysViewModel()
    @State private var showAddBuoy = false

    var body: some View {
        ZStack(alignment: .bottom) {
            BuoyMapView(viewModel: viewModel)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(UIColor.systemFill))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        RouteSelectorView(viewModel: viewModel)
                        BuoyListView(viewModel: viewModel)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .frame(maxHeight: 320)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showAddBuoy = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
        }
        .sheet(isPresented: $showAddBuoy) {
            AddBuoyView(viewModel: viewModel)
        }
        .sheet(item: Binding(
            get: { viewModel.selectedBuoy },
            set: { _ in viewModel.selectedBuoyId = nil }
        )) { buoy in
            BuoyDetailView(buoy: buoy) {
                viewModel.removeBuoy(id: buoy.id)
            }
        }
    }
}
