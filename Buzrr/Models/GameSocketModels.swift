//
//  GameSocketModels.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation

enum GamePhase: String, Decodable, Equatable {
    case lobby
    case starting
    case question
    case reveal
    case final
    case ended
}


struct PublicQuestion: Decodable, Equatable, Identifiable {
    struct Option: Decodable, Equatable, Identifiable {
        let id: String
        let title: String
    }

    let id: String
    let title: String
    let media: String?
    let mediaType: String?
    let timeOut: Int
    let options: [Option]
}

struct QuestionStartPayload: Decodable {
    let index: Int
    let qCount: Int
    let question: PublicQuestion

    let remainingMs: Int
}

struct QuestionEndPayload: Decodable, Equatable {
    let index: Int
    let counts: [Int]
    let correctOptionIds: [String]
}

struct AnswerResultPayload: Decodable, Equatable {
    let answered: Bool
    let optionId: String?
    let isCorrect: Bool
    let score: Int
    let totalScore: Int
    let rank: Int?
}

struct LiveLeaderboardEntry: Decodable, Equatable, Identifiable {
    let playerId: String
    let name: String
    let profilePic: String?
    let score: Int
    let rank: Int

    var id: String { playerId }
}

struct LeaderboardPayload: Decodable {
    let entries: [LiveLeaderboardEntry]
    let isFinal: Bool
}

struct GameOverPayload: Decodable {
    struct EloChange: Decodable, Equatable {
        let before: Int
        let after: Int
    }

    let entries: [LiveLeaderboardEntry]
    let resultId: String?
    let eloChanges: [String: EloChange]?
    let rated: Bool?
}

struct RosterPlayer: Decodable, Equatable, Identifiable {
    let id: String
    let name: String
    let profilePic: String?
    let connected: Bool
}

struct PlayerConnectionPayload: Decodable {
    let playerId: String
    let connected: Bool
}

struct StateSyncPayload: Decodable {
    let phase: GamePhase
    let mode: String
    let qIndex: Int
    let qCount: Int
    let question: PublicQuestion?

    let remainingMs: Int?
    let reveal: QuestionEndPayload?
    let leaderboard: [LiveLeaderboardEntry]?
    let players: [RosterPlayer]
    let you: AnswerResultPayload?
}


struct SubmitAnswerAck: Decodable {
    let accepted: Bool
    let reason: String?
}



extension PublicQuestion {
    static let previewQuestion = PublicQuestion(
        id: "q1",
        title: "Which country is the home to the Eiffel Tower?",
        media: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCg95hhWhCnU2y-j7NooUWXabUw-YmT_-G28jCtFZg2g&s=10",
        mediaType: "image",
        timeOut: 30,
        options: [
            .init(id: "o1", title: "France"),
            .init(id: "o2", title: "Germany"),
            .init(id: "o3", title: "Italy"),
            .init(id: "o4", title: "Spain"),
        ]
    )
}

extension RosterPlayer {
    static let previews: [RosterPlayer] = [
        RosterPlayer(id: "1", name: "Anmol", profilePic: "profile1", connected: true),
        RosterPlayer(id: "2", name: "Shivansh", profilePic: "profile2", connected: true),
        RosterPlayer(id: "3", name: "Yashi", profilePic: "profile3", connected: false),
    ]
}

extension LiveLeaderboardEntry {
    static let previews: [LiveLeaderboardEntry] = [
        .init(playerId: "1", name: "Anmol", profilePic: "profile1", score: 2400, rank: 1),
        .init(playerId: "2", name: "Shivansh", profilePic: "profile2", score: 1800, rank: 2),
        .init(playerId: "3", name: "Yashi", profilePic: "profile3", score: 1200, rank: 3),
    ]
}
