//
//  GameSocketService.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation
import Observation
import SocketIO

@Observable
final class GameSocketService {
    enum Connection: Equatable {
        case idle
        case connecting
        case connected
        case reconnecting
        case disconnected
    }



    private(set) var connection: Connection = .idle
    private(set) var phase: GamePhase = .lobby
    private(set) var mode: String = "classic"
    private(set) var qIndex: Int = 0
    private(set) var qCount: Int = 0
    private(set) var question: PublicQuestion?
    private(set) var reveal: QuestionEndPayload?
    private(set) var players: [RosterPlayer] = []
    private(set) var you: AnswerResultPayload?
    private(set) var leaderboard: [LiveLeaderboardEntry] = []
    private(set) var finalEntries: [LiveLeaderboardEntry] = []
    private(set) var gameOverResultId: String?
    private(set) var isFinalLeaderboard: Bool = false
    private(set) var lastError: String?


    private(set) var selectedOptionId: String?

    private(set) var correctCount: Int = 0
    private(set) var answeredCount: Int = 0

    private(set) var gameStartedAt: Date?


    private(set) var deadline: Date?


    var hasAnswered: Bool {
        if phase != .question { return false }
        return selectedOptionId != nil || (you?.answered ?? false)
    }


    var elapsedTimeString: String {
        guard let gameStartedAt else { return "00:00" }
        let total = max(0, Int(Date().timeIntervalSince(gameStartedAt)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }



    @ObservationIgnored var onRemoved: ((_ banned: Bool) -> Void)?
    @ObservationIgnored var onSessionEnded: (() -> Void)?



    @ObservationIgnored private var manager: SocketManager?
    @ObservationIgnored private var socket: SocketIOClient?

    var remainingSeconds: Int {
        guard phase == .question, let deadline else { return 0 }
        return max(0, Int(deadline.timeIntervalSinceNow.rounded(.up)))
    }




    func connect(gameCode: String, token: String) {
        disconnect()

        let config: SocketIOClientConfiguration = [
            .connectParams(["userType": "player", "gameCode": gameCode]),

            .extraHeaders(["Authorization": "Bearer \(token)"]),
            .forceNew(true),
            .reconnects(true),
            .handleQueue(DispatchQueue.main),
        ]
        let manager = SocketManager(socketURL: APIConfiguration.baseURL, config: config)
        let socket = manager.defaultSocket
        self.manager = manager
        self.socket = socket
        connection = .connecting
        resetLiveState()

        socket.on(clientEvent: .connect) { [weak self] _, _ in
            guard let self else { return }
            Task { @MainActor in
                self.connection = .connected

                self.socket?.emit("request-sync")
            }
        }

        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            guard let self else { return }
            let reason = data.first as? String
            Task { @MainActor in
                self.connection = reason == "io server disconnect" ? .disconnected : .reconnecting
            }
        }

        socket.on(clientEvent: .error) { [weak self] data, _ in
            guard let self else { return }
            let message = data.first as? String
            Task { @MainActor in
                self.lastError = message
            }
        }

        socket.on("state-sync") { [weak self] data, _ in
            self?.handleStateSync(data)
        }
        socket.on("game-started") { [weak self] _, _ in
            self?.onMain { $0.phase = .starting }
        }
        socket.on("question-start") { [weak self] data, _ in
            guard let payload = Self.decode(QuestionStartPayload.self, from: data) else { return }
            self?.onMain {
                $0.phase = .question
                $0.qIndex = payload.index
                $0.qCount = payload.qCount
                $0.question = payload.question
                $0.reveal = nil
                $0.you = nil
                $0.selectedOptionId = nil
                if $0.gameStartedAt == nil { $0.gameStartedAt = Date() }
                $0.deadline = Date().addingTimeInterval(Double(payload.remainingMs) / 1000)
            }
        }
        socket.on("question-end") { [weak self] data, _ in
            guard let payload = Self.decode(QuestionEndPayload.self, from: data) else { return }
            self?.onMain {
                $0.phase = .reveal
                $0.reveal = payload
                $0.deadline = nil
            }
        }
        socket.on("answer-result") { [weak self] data, _ in
            guard let payload = Self.decode(AnswerResultPayload.self, from: data) else { return }
            self?.onMain { service in
                service.you = payload
                if payload.answered {
                    service.answeredCount += 1
                    if payload.isCorrect { service.correctCount += 1 }
                }
            }
        }
        socket.on("leaderboard") { [weak self] data, _ in
            guard let payload = Self.decode(LeaderboardPayload.self, from: data) else { return }
            self?.onMain {
                $0.leaderboard = payload.entries
                if payload.isFinal {
                    $0.isFinalLeaderboard = true
                    $0.finalEntries = payload.entries
                    $0.phase = .final
                }
            }
        }
        socket.on("game-over") { [weak self] data, _ in
            guard let payload = Self.decode(GameOverPayload.self, from: data) else { return }
            self?.onMain {
                $0.finalEntries = payload.entries
                $0.gameOverResultId = payload.resultId
                $0.phase = .ended
            }
        }
        socket.on("player-connection") { [weak self] data, _ in
            guard let payload = Self.decode(PlayerConnectionPayload.self, from: data) else { return }
            self?.onMain { service in
                guard let index = service.players.firstIndex(where: { $0.id == payload.playerId }) else { return }
                let existing = service.players[index]
                service.players[index] = RosterPlayer(
                    id: existing.id,
                    name: existing.name,
                    profilePic: existing.profilePic,
                    connected: payload.connected
                )
            }
        }
        socket.on("player-joined") { [weak self] _, _ in

            self?.onMain { $0.socket?.emit("request-sync") }
        }
        socket.on("player-removed") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any] else { return }
            let id = dict["id"] as? String
            let banned = dict["banned"] as? Bool ?? false
            self?.onMain { service in
                service.players.removeAll { $0.id == id }
                service.onRemoved?(banned)
            }
        }
        socket.on("player-left") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any], let id = dict["id"] as? String else { return }
            self?.onMain { $0.players.removeAll { $0.id == id } }
        }
        socket.on("game-session-ended") { [weak self] _, _ in
            self?.onMain { service in
                service.phase = .ended
                service.onSessionEnded?()
            }
        }

        socket.connect(withPayload: ["token": token])
    }

    func disconnect() {
        socket?.disconnect()
        socket = nil
        manager = nil
        connection = .idle
    }

    func requestSync() {
        socket?.emit("request-sync")
    }


    func leaveRoom() {
        socket?.emit("leave-room")
    }


    func submitAnswer(qIndex: Int, optionId: String) async -> Bool {
        guard let socket else { return false }
        return await withCheckedContinuation { continuation in
            socket
                .emitWithAck("submit-answer", ["qIndex": qIndex, "optionId": optionId])
                .timingOut(after: 5) { data in
                    let ack = Self.decode(SubmitAnswerAck.self, from: data)
                    continuation.resume(returning: ack?.accepted ?? false)
                }
        }
    }



    func setLocalSelection(_ optionId: String?) {
        selectedOptionId = optionId
    }



    private func handleStateSync(_ data: [Any]) {
        guard let payload = Self.decode(StateSyncPayload.self, from: data) else { return }
        onMain { service in
            service.phase = payload.phase
            service.mode = payload.mode
            service.qIndex = payload.qIndex
            service.qCount = payload.qCount
            service.question = payload.question
            service.reveal = payload.reveal
            service.players = payload.players
            service.you = payload.you
            if let you = payload.you, you.answered {
                service.selectedOptionId = you.optionId
            }
            if let leaderboard = payload.leaderboard {
                service.leaderboard = leaderboard
            }
            if payload.phase == .question, let remainingMs = payload.remainingMs {
                service.deadline = Date().addingTimeInterval(Double(remainingMs) / 1000)
            } else {
                service.deadline = nil
            }
        }
    }


    private func resetLiveState() {
        phase = .lobby
        mode = "classic"
        qIndex = 0
        qCount = 0
        question = nil
        reveal = nil
        players = []
        you = nil
        leaderboard = []
        finalEntries = []
        gameOverResultId = nil
        isFinalLeaderboard = false
        lastError = nil
        selectedOptionId = nil
        correctCount = 0
        answeredCount = 0
        gameStartedAt = nil
        deadline = nil
    }


    private func onMain(_ block: @escaping @MainActor (GameSocketService) -> Void) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            block(self)
        }
    }


    nonisolated private static func decode<T: Decodable>(_ type: T.Type, from data: [Any]) -> T? {
        guard let first = data.first, JSONSerialization.isValidJSONObject(first) else {
            return nil
        }
        guard let json = try? JSONSerialization.data(withJSONObject: first) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: json)
    }
}
