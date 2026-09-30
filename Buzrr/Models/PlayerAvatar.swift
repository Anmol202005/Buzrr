//
//  PlayerAvatar.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation

enum PlayerAvatar {
    static let webDirectory = "/images/player_profile/"
    static let indexRange = 1...12
    static let fallbackAsset = "profile1"


    private static let jpgIndices: Set<Int> = [5, 7, 8, 9, 10, 11]

    static func fileExtension(for index: Int) -> String {
        jpgIndices.contains(index) ? "jpg" : "png"
    }


    static func serverValue(forIndex index: Int) -> String {
        "\(webDirectory)profile\(index).\(fileExtension(for: index))"
    }




    static func assetName(forProfilePic value: String?) -> String {
        guard let value, let index = index(from: value) else { return fallbackAsset }
        return "profile\(index)"
    }


    static func index(from value: String) -> Int? {
        let last = value.split(separator: "/").last.map(String.init) ?? value
        let digits = last.drop(while: { !$0.isNumber }).prefix(while: { $0.isNumber })
        guard let index = Int(digits), indexRange.contains(index) else { return nil }
        return index
    }
}
