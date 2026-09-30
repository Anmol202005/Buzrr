//
//  GuestSessionStore.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation
import Observation

@Observable
final class GuestSessionStore {
    private enum Key {
        static let playerId = "buzrr.playerId"
        static let token = "buzrr.playerToken"
        static let name = "buzrr.playerName"
        static let profile = "buzrr.playerProfile"
        static let seenIntro = "buzrr.seenIntro"
    }

    private(set) var playerId: String?
    private(set) var token: String?
    private(set) var displayName: String?
    private(set) var profile: String?

    private(set) var hasSeenIntro: Bool

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.playerId = defaults.string(forKey: Key.playerId)
        self.token = defaults.string(forKey: Key.token)
        self.displayName = defaults.string(forKey: Key.name)
        self.profile = defaults.string(forKey: Key.profile)
        self.hasSeenIntro = defaults.bool(forKey: Key.seenIntro)
    }


    func markIntroSeen() {
        hasSeenIntro = true
        defaults.set(true, forKey: Key.seenIntro)
    }


    var hasIdentity: Bool {
        playerId != nil && token != nil
    }

    func save(playerId: String, token: String, displayName: String, profile: String) {
        self.playerId = playerId
        self.token = token
        self.displayName = displayName
        self.profile = profile

        defaults.set(playerId, forKey: Key.playerId)
        defaults.set(token, forKey: Key.token)
        defaults.set(displayName, forKey: Key.name)
        defaults.set(profile, forKey: Key.profile)
    }

    func updateDisplayName(_ name: String) {
        displayName = name
        defaults.set(name, forKey: Key.name)
    }


    func clear() {
        playerId = nil
        token = nil
        displayName = nil
        profile = nil

        defaults.removeObject(forKey: Key.playerId)
        defaults.removeObject(forKey: Key.token)
        defaults.removeObject(forKey: Key.name)
        defaults.removeObject(forKey: Key.profile)
    }
}
