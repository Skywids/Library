//
//  MockAPICall.swift
//  
//
//  Created by Skywinds on 10/10/20.
//

import Foundation

// USer Mock to test

enum UserEndPoint {
    case all
    case get(userId: Int)
}

extension UserEndPoint: EndPoint {
    var headers: [String : String] {
        return [:]
    }
    
    var host: String {
        return ""
    }
    
    var body: HTTPBody? {
        return nil
    }
    
    
    var request: URLRequest? {
        switch self {
        case .all, .get(_):
            return request(forEndpoint: "/api/users")
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .all, .get( _):
            return .get
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .all:
            return nil
        case .get(let userId):
            return [URLQueryItem(name: "userId", value: String(userId))]
        }
    }
}


private class MockAPICall {
    
    // User

    struct User: Codable {
        let id: Int
        let username: String
        let email: String
    }

    
    let api = NetworkAPIManager()

    func getAllUsers() {
        api.apiRequest(endpoint: UserEndPoint.all) { (result: ApiResult<User>) in
            
            switch result {
            case .success(model: let user):
                print(user)
            case .error(error: let errMsg):
                print(errMsg.localString)
            }
            
        }

    }
    
    func getUser(for userId: String) {
        api.apiRequest(endpoint: UserEndPoint.get(userId: 1)) { (result: ApiResult<User>) in
            switch result {
            case .error(let error):
                print(error.localString)
            case .success(let users):
                print(users)
            }
        }
    }
    
    
}
