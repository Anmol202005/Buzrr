//
//  GameClient.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation
import Observation

@Observable
final class GameClient {
    let session: GuestSessionStore
    let socket: GameSocketService




    @ObservationIgnored private let api: PlayerAPI

    private(set) var isBusy = false
    private(set) var isSubmittingAnswer = false
    private(set) var errorMessage: String?

    private(set) var isRestoring = false

    private(set) var joinedGameCode: String?
    private(set) var roomId: String?

    init(
        session: GuestSessionStore = GuestSessionStore(),
        api: PlayerAPI = .shared,
        socket: GameSocketService = GameSocketService()
    ) {
        self.session = session
        self.api = api
        self.socket = socket
        self.isRestoring = session.hasIdentity

        socket.onRemoved = { [weak self] _ in

            self?.leaveRoomLocally(clearIdentity: false)
        }
        socket.onSessionEnded = { [weak self] in
            guard let self else { return }






            let playedOut = self.socket.gameOverResultId != nil || self.socket.gameStartedAt != nil
            if playedOut {

                self.socket.disconnect()
            } else {
                self.leaveRoomLocally(clearIdentity: true)
            }
        }
    }

    var isInRoom: Bool { joinedGameCode != nil }

    var shouldShowIntro: Bool { !session.hasSeenIntro }


    func markIntroSeen() {
        session.markIntroSeen()
    }




    @discardableResult
    func createGuest(name: String, profile: String) async -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Enter a display name."
            return false
        }

        isBusy = true
        defer { isBusy = false }
        do {
            let result = try await api.createPlayer(username: trimmed, profile: profile)
            session.save(
                playerId: result.playerId,
                token: result.accessToken,
                displayName: trimmed,
                profile: profile
            )
            errorMessage = nil
            return true
        } catch {
            errorMessage = Self.message(for: error)
            return false
        }
    }


    @discardableResult
    func updateName(_ name: String) async -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Enter a display name."
            return false
        }
        guard let playerId = session.playerId else {
            errorMessage = "Create a profile first."
            return false
        }

        isBusy = true
        defer { isBusy = false }
        do {
            let result = try await api.updateName(playerId: playerId, username: trimmed)
            session.updateDisplayName(result.name)
            errorMessage = nil
            return true
        } catch {
            errorMessage = Self.message(for: error)
            return false
        }
    }





    func restoreSession() async {
        guard isRestoring, let playerId = session.playerId, let token = session.token else {
            isRestoring = false
            return
        }

        do {
            let payload = try await api.playerPlay(playerId: playerId)
            if let game = payload.game {
                roomId = game.id
                joinedGameCode = game.gameCode
                socket.connect(gameCode: game.gameCode, token: token)
            }
        } catch {
            if case let APIError.server(status, _) = error, status == 404 {
                session.clear()
            }
        }
        isRestoring = false
    }




    @discardableResult
    func joinRoom(code: String) async -> Bool {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else {
            errorMessage = "Enter a game code."
            return false
        }
        guard let token = session.token else {
            errorMessage = "Create a profile first."
            return false
        }

        isBusy = true
        defer { isBusy = false }
        do {
            let result = try await api.joinRoom(gameCode: trimmed, token: token)
            roomId = result.roomId
            joinedGameCode = trimmed
            socket.connect(gameCode: trimmed, token: token)
            errorMessage = nil
            return true
        } catch {
            errorMessage = Self.message(for: error)
            return false
        }
    }


    @discardableResult
    func submitAnswer(optionId: String) async -> Bool {
        guard socket.phase == .question, !isSubmittingAnswer else { return false }
        isSubmittingAnswer = true


        socket.setLocalSelection(optionId)
        let accepted = await socket.submitAnswer(qIndex: socket.qIndex, optionId: optionId)
        isSubmittingAnswer = false
        if !accepted {
            socket.setLocalSelection(nil)
            errorMessage = "Your answer wasn't accepted. Try again."
        }
        return accepted
    }


    func finishSession() {
        leaveRoomLocally(clearIdentity: true)
    }

    func changeProfile() {
        leaveRoomLocally(clearIdentity: true)
    }


    func leaveRoom() {
        socket.leaveRoom()
        let playerId = session.playerId
        leaveRoomLocally(clearIdentity: false)
        if let playerId {
            Task { try? await api.clearGame(id: playerId) }
        }
    }

    func clearError() {
        errorMessage = nil
    }



    private func leaveRoomLocally(clearIdentity: Bool) {
        socket.disconnect()
        joinedGameCode = nil
        roomId = nil
        if clearIdentity {
            session.clear()
        }
    }

    private static func message(for error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.userMessage
        }
        return error.localizedDescription
    }
}
