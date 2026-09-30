//
//  APIError.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation


enum APIError: Error, LocalizedError {
    case invalidURL
    case transport(Error)
    case decoding(Error)
    case server(status: Int, message: String?)


    var userMessage: String {
        switch self {
        case .invalidURL:
            return "Something went wrong building the request."
        case .transport:
            return "Couldn't reach the server. Check your connection and try again."
        case .decoding:
            return "The server sent an unexpected response."
        case let .server(_, message):
            return message ?? "The server rejected the request."
        }
    }

    var errorDescription: String? { userMessage }
}
