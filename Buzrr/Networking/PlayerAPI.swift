//
//  PlayerAPI.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation


final class PlayerAPI {
    static let shared = PlayerAPI()

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }


    func createPlayer(username: String, profile: String) async throws -> CreatePlayerResponse {
        try await client.send(
            .post,
            "players",
            body: CreatePlayerRequest(username: username, profile: profile)
        )
    }


    func updateName(playerId: String, username: String) async throws -> UpdatePlayerNameResponse {
        try await client.send(
            .patch,
            "players/name",
            body: UpdatePlayerNameRequest(playerId: playerId, username: username)
        )
    }


    func getPlayer(id: String) async throws -> PlayerDTO {
        try await client.send(.get, "players/\(id)")
    }


    @discardableResult
    func clearGame(id: String) async throws -> PlayerDTO {
        try await client.send(.patch, "players/\(id)/clear-game")
    }


    func joinRoom(gameCode: String, token: String) async throws -> JoinRoomResponse {
        try await client.send(
            .post,
            "game-sessions/join",
            body: JoinRoomRequest(gameCode: gameCode),
            token: token
        )
    }


    func playerPlay(playerId: String) async throws -> PlayerPlayPayload {
        try await client.send(.get, "game-sessions/player-play/\(playerId)")
    }
}
