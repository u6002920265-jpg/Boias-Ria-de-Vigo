import SwiftUI
import MapKit

struct BuoyMapView: UIViewRepresentable {
    @ObservedObject var viewModel: BuoysViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.showsCompass = true
        map.showsScale = true
        map.setRegion(viewModel.cameraRegion, animated: false)
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        context.coordinator.viewModel = viewModel

        // Sync region only when triggered programmatically (not by user pan)
        if context.coordinator.shouldSyncRegion {
            context.coordinator.shouldSyncRegion = false
            map.setRegion(viewModel.cameraRegion, animated: true)
        }

        // Sync annotations
        let currentIds = Set(map.annotations.compactMap { ($0 as? BuoyAnnotation)?.buoyId })
        let desiredIds = Set(viewModel.visibleBuoys.map(\.id))
        if currentIds != desiredIds {
            map.removeAnnotations(map.annotations.filter { $0 is BuoyAnnotation })
            let annotations = viewModel.visibleBuoys.map { BuoyAnnotation(buoy: $0) }
            map.addAnnotations(annotations)
        }

        // Refresh annotation views for selection/colour changes
        for annotation in map.annotations {
            if let a = annotation as? BuoyAnnotation,
               let view = map.view(for: a) as? BuoyAnnotationView {
                view.update(
                    isSelected: viewModel.selectedBuoyId == a.buoyId,
                    showAllRoute: viewModel.activeRoute == .all,
                    side: a.side
                )
            }
        }

        // Sync polyline overlay
        map.removeOverlays(map.overlays)
        if viewModel.routeCoordinates.count >= 2 {
            var coords = viewModel.routeCoordinates
            let polyline = MKPolyline(coordinates: &coords, count: coords.count)
            map.addOverlay(polyline)
        }
    }

    // MARK: – Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var viewModel: BuoysViewModel
        var shouldSyncRegion = false
        private var regionObserver: Any?

        init(viewModel: BuoysViewModel) {
            self.viewModel = viewModel
            super.init()
            regionObserver = viewModel.$cameraRegion.sink { [weak self] _ in
                self?.shouldSyncRegion = true
            }
        }

        func mapView(_ map: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let a = annotation as? BuoyAnnotation else { return nil }
            let id = "BuoyPin"
            let view = (map.dequeueReusableAnnotationView(withIdentifier: id) as? BuoyAnnotationView)
                ?? BuoyAnnotationView(annotation: a, reuseIdentifier: id)
            view.annotation = a
            view.canShowCallout = false
            view.update(
                isSelected: viewModel.selectedBuoyId == a.buoyId,
                showAllRoute: viewModel.activeRoute == .all,
                side: a.side
            )
            return view
        }

        func mapView(_ map: MKMapView, didSelect view: MKAnnotationView) {
            map.deselectAnnotation(view.annotation, animated: false)
            guard let a = view.annotation as? BuoyAnnotation,
                  let buoy = viewModel.buoys.first(where: { $0.id == a.buoyId }) else { return }
            viewModel.selectBuoy(buoy)
        }

        func mapView(_ map: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: polyline)
                r.strokeColor = UIColor.red.withAlphaComponent(0.7)
                r.lineWidth = 3
                r.lineDashPattern = [8, 6]
                return r
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: – MKAnnotation wrapper

final class BuoyAnnotation: NSObject, MKAnnotation {
    let buoyId: String
    let side: BuoySide?
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?

    init(buoy: Buoy) {
        self.buoyId = buoy.id
        self.side = buoy.side
        self.coordinate = buoy.coordinate
        self.title = buoy.name
    }
}

// MARK: – Custom annotation view

final class BuoyAnnotationView: MKAnnotationView {
    private let circle = UIView()
    private let icon = UIImageView()
    private let label = UILabel()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        centerOffset = .zero

        circle.layer.cornerRadius = 14
        circle.frame = CGRect(x: 4, y: 4, width: 28, height: 28)
        addSubview(circle)

        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        icon.image = UIImage(systemName: "mappin.circle.fill", withConfiguration: cfg)
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.frame = circle.bounds
        circle.addSubview(icon)

        label.font = .systemFont(ofSize: 9, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.isHidden = true
        label.frame = CGRect(x: -20, y: 32, width: 76, height: 14)
        addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(isSelected: Bool, showAllRoute: Bool, side: BuoySide?) {
        let color: UIColor
        if isSelected {
            color = .systemOrange
        } else if showAllRoute {
            color = .systemBlue
        } else {
            switch side {
            case .babor:    color = .systemRed
            case .estribor: color = .systemGreen
            case nil:       color = .systemBlue
            }
        }

        let size: CGFloat = isSelected ? 36 : 28
        let inset: CGFloat = (36 - size) / 2
        circle.frame = CGRect(x: inset, y: inset, width: size, height: size)
        circle.layer.cornerRadius = size / 2
        circle.backgroundColor = color
        circle.layer.shadowColor = color.cgColor
        circle.layer.shadowRadius = isSelected ? 6 : 3
        circle.layer.shadowOpacity = 0.4
        circle.layer.shadowOffset = .zero

        icon.frame = circle.bounds

        label.text = (annotation as? BuoyAnnotation).flatMap { _ in
            isSelected ? (annotation?.title ?? nil) : nil
        }
        label.isHidden = !isSelected
    }
}
