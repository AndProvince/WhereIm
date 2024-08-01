//
//  MapView.swift
//  WhereIm
//
//  Created by Андрей on 25.07.2024.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var fixedRegion: MKCoordinateRegion?
    @Binding var cars: [CarAnnotation]
    
    let maxDelta: CLLocationDegrees = 0.02
    let minDelta: CLLocationDegrees = 0.01
    private let starAnnotation: StarAnnotation = StarAnnotation(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), emoji: "⭐️")
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
        context.coordinator.mapView = mapView
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Устанавливаем регион
        if let fixedRegion = fixedRegion {
            uiView.setRegion(fixedRegion, animated: true)
        } else {
            uiView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var mapView: MKMapView?
        var timer: Timer?
        
        init(_ parent: MapView) {
            self.parent = parent
            super.init()
            self.startTimer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let carAnnotation = annotation as? CarAnnotation {
                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "CarAnnotation")
                view.annotation = carAnnotation
                view.canShowCallout = false
                view.backgroundColor = .clear
                
                let label = UILabel()
                label.text = carAnnotation.emoji
                label.font = UIFont.systemFont(ofSize: 30)
                label.sizeToFit()
                view.addSubview(label)
                label.center = view.center
                
                return view
            } else if let starAnnotation = annotation as? StarAnnotation {
                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "StarAnnotation")
                view.annotation = starAnnotation
                view.canShowCallout = false
                view.backgroundColor = .clear
                
                let label = UILabel()
                label.text = starAnnotation.emoji
                label.font = UIFont.systemFont(ofSize: 30)
                label.sizeToFit()
                view.addSubview(label)
                label.center = view.center
                
                return view
            }
            return nil
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if let fixedRegion = parent.fixedRegion {
                mapView.setRegion(fixedRegion, animated: true)
            } else {
                var newRegion = mapView.region
                newRegion.span.latitudeDelta = max(parent.minDelta, min(parent.maxDelta, newRegion.span.latitudeDelta))
                newRegion.span.longitudeDelta = max(parent.minDelta, min(parent.maxDelta, newRegion.span.longitudeDelta))
                mapView.setRegion(newRegion, animated: false)
                parent.region = newRegion
                
                updateStarAnnotation(mapView)
            }
        }
        
        func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.checkRegion()
            }
        }
        
        func checkRegion() {
            guard let mapView = mapView else { return }
            if let fixedRegion = parent.fixedRegion {
                mapView.setRegion(fixedRegion, animated: true)
                
                for car in parent.cars {
                    updateCarAnnotation(mapView, car: car)
                }
            }
        }
        
        func updateCarAnnotation(_ mapView: MKMapView, car: CarAnnotation) {
            if let existingAnnotation = mapView.annotations.first(where: { ($0 as? CarAnnotation)?.identifier == car.identifier }) as? CarAnnotation {
                UIView.animate(withDuration: 1.0) {
                    existingAnnotation.coordinate = car.coordinate
                }
            } else {
                mapView.addAnnotation(car)
            }
        }
        
        func updateStarAnnotation(_ mapView: MKMapView) {
            if let existingAnnotation = mapView.annotations.first(where: { ($0 as? StarAnnotation)?.identifier == -1 }) as? StarAnnotation {
                UIView.animate(withDuration: 0.5) {
                    existingAnnotation.coordinate = mapView.region.center
                }
            } else {
                // Удаляем старую звезду перед добавлением новой
                removeStarAnnotations(mapView)
                parent.starAnnotation.coordinate = mapView.region.center
                mapView.addAnnotation(parent.starAnnotation)
            }
        }
        
        func removeCarAnnotations(_ mapView: MKMapView) {
            let carAnnotations = mapView.annotations.filter { $0 is CarAnnotation }
            mapView.removeAnnotations(carAnnotations)
        }
        
        func removeStarAnnotations(_ mapView: MKMapView) {
            let starAnnotations = mapView.annotations.filter { $0 is StarAnnotation }
            mapView.removeAnnotations(starAnnotations)
        }
        
        deinit {
            timer?.invalidate()
        }
    }
}
