//
//  APIModels.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation



struct CreatePlayerRequest: Encodable {
    let username: String
    let profile: String
}

struct CreatePlayerResponse: Decodable {
    let playerId: String
    let accessToken: String
}

struct UpdatePlayerNameRequest: Encodable {
    let playerId: String
    let username: String
}

struct UpdatePlayerNameResponse: Decodable {
    let playerId: String
    let name: String
}


struct PlayerDTO: Decodable {
    let id: String
    let name: String
    let profilePic: String?
    let gameId: String?
}



struct JoinRoomRequest: Encodable {
    let gameCode: String
}

struct JoinRoomResponse: Decodable {
    let roomId: String
    let playerId: String
}



struct PlayerPlayPayload: Decodable {
    let player: PlayerDTO
    let game: PlayerPlayGame?
}

struct PlayerPlayGame: Decodable {
    let id: String
    let gameCode: String
}
