//
//  APIConfiguration.swift
//  Buzrr
//
//  Created by Anmol Sharma on 28/09/26.
//
import Foundation

enum APIConfiguration {

    static let baseURL = URL(string: "https://buzrr.onrender.com")!


    static let restBaseURL = baseURL.appending(path: "api")
}
