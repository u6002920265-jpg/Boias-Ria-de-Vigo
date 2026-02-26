import SwiftUI

struct AddBuoyView: View {
    @ObservedObject var viewModel: BuoysViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var latDegrees: String = ""
    @State private var latMinutes: String = ""
    @State private var latDirection: LatDirection = .north
    @State private var lngDegrees: String = ""
    @State private var lngMinutes: String = ""
    @State private var lngDirection: LngDirection = .west
    @State private var description: String = ""
    @State private var selectedSide: BuoySide?

    @FocusState private var focusedField: Field?

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && Int(latDegrees) != nil
        && Double(latMinutes) != nil
        && Int(lngDegrees) != nil
        && Double(lngMinutes) != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Identificação") {
                    TextField("Nome da Boia", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)

                    Picker("Sentido", selection: $selectedSide) {
                        Text("Nenhum").tag(Optional<BuoySide>.none)
                        ForEach(BuoySide.allCases, id: \.self) { side in
                            Text(side.displayName).tag(Optional(side))
                        }
                    }
                }

                Section("Latitude (DD° MM.MMM')") {
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            TextField("42", text: $latDegrees)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                                .focused($focusedField, equals: .latDeg)
                            Text("°")
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 4) {
                            TextField("13.500", text: $latMinutes)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .latMin)
                            Text("'")
                                .foregroundColor(.secondary)
                        }

                        Picker("", selection: $latDirection) {
                            Text("N").tag(LatDirection.north)
                            Text("S").tag(LatDirection.south)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 80)
                    }
                }

                Section("Longitude (DD° MM.MMM')") {
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            TextField("08", text: $lngDegrees)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                                .focused($focusedField, equals: .lngDeg)
                            Text("°")
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 4) {
                            TextField("45.123", text: $lngMinutes)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .lngMin)
                            Text("'")
                                .foregroundColor(.secondary)
                        }

                        Picker("", selection: $lngDirection) {
                            Text("W").tag(LngDirection.west)
                            Text("E").tag(LngDirection.east)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 80)
                    }
                }

                Section("Descrição (Opcional)") {
                    TextField("Estado, cor ou notas…", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                        .focused($focusedField, equals: .description)
                }
            }
            .navigationTitle("Nova Boia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        addBuoy()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private func addBuoy() {
        guard let latD = Int(latDegrees),
              let latM = Double(latMinutes),
              let lngD = Int(lngDegrees),
              let lngM = Double(lngMinutes) else { return }

        let latitude = CoordinateFormatter.toDecimalDegrees(
            degrees: latD, minutes: latM, isNegative: latDirection == .south
        )
        let longitude = CoordinateFormatter.toDecimalDegrees(
            degrees: lngD, minutes: lngM, isNegative: lngDirection == .west
        )

        let desc = description.trimmingCharacters(in: .whitespaces)
        viewModel.addBuoy(
            name: name.trimmingCharacters(in: .whitespaces),
            latitude: latitude,
            longitude: longitude,
            description: desc.isEmpty ? nil : desc,
            side: selectedSide
        )
        dismiss()
    }
}

private enum Field {
    case name, latDeg, latMin, lngDeg, lngMin, description
}

private enum LatDirection {
    case north, south
}

private enum LngDirection {
    case west, east
}
