//
//  ApiErrorMessage.swift
//  
//
//  Created by Skywinds on 10/10/20.
//

import Foundation

public enum ApiErrorMessage: Error {
    case noInternet
    case invalidRequest
    case invalidData
    case other(String)
    
    var localString: String {
        switch self {
        case .invalidData:
            return "invalidData"
        case .invalidRequest:
            return "invalidRequest"
        case .noInternet:
            return "NoNetworkMSG"
        case .other(let err):
            return err
        }
    }
}
