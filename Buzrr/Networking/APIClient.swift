//
//  APIClient.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}


final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }



    func send<Response: Decodable>(
        _ method: HTTPMethod,
        _ path: String,
        token: String? = nil
    ) async throws -> Response {
        try await perform(method, path, body: Optional<EmptyBody>.none, token: token)
    }



    func send<Body: Encodable, Response: Decodable>(
        _ method: HTTPMethod,
        _ path: String,
        body: Body,
        token: String? = nil
    ) async throws -> Response {
        try await perform(method, path, body: body, token: token)
    }



    private func perform<Body: Encodable, Response: Decodable>(
        _ method: HTTPMethod,
        _ path: String,
        body: Body?,
        token: String?
    ) async throws -> Response {
        let request = try makeRequest(method, path, body: body, token: token)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.server(status: -1, message: nil)
        }

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.server(
                status: http.statusCode,
                message: Self.errorMessage(from: data)
            )
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func makeRequest<Body: Encodable>(
        _ method: HTTPMethod,
        _ path: String,
        body: Body?,
        token: String?
    ) throws -> URLRequest {
        let url = APIConfiguration.restBaseURL.appending(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.decoding(error)
            }
        }

        return request
    }



    private static func errorMessage(from data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }

        if let message = object["message"] as? String {
            return message
        }
        if let messages = object["message"] as? [String] {
            return messages.joined(separator: "\n")
        }
        return object["error"] as? String
    }
}


private struct EmptyBody: Encodable {}
