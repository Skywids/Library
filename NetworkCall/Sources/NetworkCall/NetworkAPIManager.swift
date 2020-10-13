//
//  NetworkAPIManager.swift
//  
//
//  Created by Skywinds on 10/10/20.
//

import Foundation

public class NetworkAPIManager: NetworkAPIProtocol {
    
    private let urlSession: URLSession

    public init(urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.urlSession = urlSession
    }
    
    public func apiRequest<T: Codable>(endpoint: EndPoint, completionHandler: @escaping ResultClosure<T>) {
        
        guard let request = endpoint.request else {
            DispatchQueue.main.async {
                completionHandler(.error(error: ApiErrorMessage.invalidRequest))
            }
            return
        }
        
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(.error(error: ApiErrorMessage.other(error.localizedDescription)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(.error(error: ApiErrorMessage.invalidData))
                }
                return
            }
            
            do {
                let result = try T(from: data)
                DispatchQueue.main.async {
                    completionHandler(.success(model: result))
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(.error(error: ApiErrorMessage.invalidData))
                }
            }
        }
        
        task.resume()
    }
    
}

