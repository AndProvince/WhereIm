//
//  ContentView.swift
//  WhereIm
//
//  Created by Андрей on 25.07.2024.
//

import SwiftUI
import MapKit
import SpriteKit
import Combine

struct ContentView: View {
    @AppStorage("AppState") var appState: AppState = .intro
    
    @StateObject private var locationManager = LocationManager()
    
    @StateObject private var game = Game(level: 5)
    
    var body: some View {
        ZStack {
            MapView(region: $locationManager.region, fixedRegion: $game.region, cars: $game.cars)
                    .ignoresSafeArea(.all)
                
            switch appState {
            case .intro:
                // Start game button
                VStack {
                    Spacer()
                    Button(action: {
                        print("Game started!")
                        game.startGame(region: locationManager.region)
                        appState = .game
                        
                    }) {
                        Text("Start game")
                            .frame(width: 150, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            case .game:
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            game.endGame()
                            print("End game")
                            appState = .intro
                        }) {
                            Text("X")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .opacity(0.5)
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
