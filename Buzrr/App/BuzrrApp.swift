//
//  BuzrrApp.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import SwiftUI

@main
struct BuzrrApp: App {
    @State private var gameClient = GameClient()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(gameClient)
        }
    }
}
