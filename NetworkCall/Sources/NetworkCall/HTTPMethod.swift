//
//  HTTPMethod.swift
//  
//
//  Created by Skywinds on 10/13/20.
//

import Foundation

public enum HTTPMethod {
    case get
    case post
    case put
    case delete
    case other(String)
    
    var name: String {
        switch self {
        case .get:
            return "GET"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        case .post:
            return "POST"
        case .other(let method):
            return method.uppercased()
        }
    }
}
