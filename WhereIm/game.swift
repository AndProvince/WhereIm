//
//  game.swift
//  WhereIm
//
//  Created by Андрей on 25.07.2024.
//

import SwiftUI
import MapKit
import Combine

class Game: ObservableObject {
    @Published var region: MKCoordinateRegion? = nil
    @Published var cars: [CarAnnotation] = []
    @Published var centerAnnotation: StarAnnotation?
    
    private var level: Int {
        didSet {
            cars.removeAll()
            addCars(for: level)
        }
    }
    
    private var timer: Timer?
    
    init(level: Int) {
        self.level = level
    }
    
    public func startGame(region: MKCoordinateRegion) {
        self.region = region
        self.nextLevel()
        
        centerAnnotation = StarAnnotation(coordinate: region.center, emoji: "🌟")
    }
    
    public func endGame() {
        self.region = nil
        self.cars.removeAll()
        
        timer?.invalidate()
        timer = nil
    }
    
    private func nextLevel() {
        self.level += 1
        startTimer()
    }
    
    private func addCars(for level: Int) {
        for ind in 0..<level {
            let randomCoordinate = CLLocationCoordinate2D(latitude: self.region!.center.latitude + Double.random(in: -0.02...0.02), longitude: self.region!.center.longitude + Double.random(in: -0.02...0.02))
            let identifier = ind
            let emoji = ["🚗", "🚙"].randomElement()!
            
            let car = CarAnnotation(coordinate: randomCoordinate, identifier: identifier, emoji: emoji)
            cars.append(car)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateCarPositions()
        }
    }
    
    private func updateCarPositions() {
        guard let centerCoordinate = self.region?.center else { return }
        let stopDistance: Double = 0.003
        let speed: Double = 0.0002
        
        for car in cars {
            let currentCoordinate = car.coordinate
            let distanceToCenter = sqrt(pow(centerCoordinate.latitude - currentCoordinate.latitude, 2) + pow(centerCoordinate.longitude - currentCoordinate.longitude, 2))
            if distanceToCenter < stopDistance { continue }
            
            let deltaLatitude = (centerCoordinate.latitude - currentCoordinate.latitude) / distanceToCenter
            let deltaLongitude = (centerCoordinate.longitude - currentCoordinate.longitude) / distanceToCenter
            
            let newLatitude = currentCoordinate.latitude + deltaLatitude * speed
            let newLongitude = currentCoordinate.longitude + deltaLongitude * speed
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1.0) {
                    car.coordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
                }
            }
        }
    }
}

class CarAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: Int
    var emoji: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: Int, emoji: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        self.emoji = emoji
        super.init()
    }
}

class StarAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: Int
    var emoji: String
    
    init(coordinate: CLLocationCoordinate2D, emoji: String) {
        self.coordinate = coordinate
        self.identifier = -1
        self.emoji = emoji
        super.init()
    }
}
