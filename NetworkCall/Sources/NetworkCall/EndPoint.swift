//
//  EndPoint.swift
//  
//
//  Created by Skywinds on 10/10/20.
//

import Foundation

public protocol EndPoint {
    var request: URLRequest? { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String:String] { get }
    var queryItems: [URLQueryItem]? { get }
    var scheme: String { get }
    var host: String { get }
    var body: HTTPBody? { get }
}

public extension EndPoint {
    func request(forEndpoint endpoint: String) -> URLRequest? {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = endpoint
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return nil }
        var urlRequest = URLRequest(url: url)
        
        for header in self.headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        if self.body != nil, self.body!.isEmpty == false {
            // if our body defines additional headers, add them
            for (header, value) in self.body!.additionalHeaders {
                urlRequest.addValue(value, forHTTPHeaderField: header)
            }
                    
            do {
                urlRequest.httpBody = try self.body!.encode()
            } catch {
                // error in encoding
                return nil
            }
        }
        
        return urlRequest
    }
}

public extension EndPoint {
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var scheme: String {
        return "https"
    }

    var queryItems: [URLQueryItem]? {
        return nil
    }
}
