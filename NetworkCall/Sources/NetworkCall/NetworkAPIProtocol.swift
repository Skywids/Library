//
//  NetworkAPIProtocol.swift
//
//
//  Created by Skywinds on 10/10/20.
//

import Foundation

public protocol NetworkAPIProtocol {
    typealias ResultClosure<T> = (_ result: ApiResult<T>) -> Void
    
    func apiRequest<T: Codable>(endpoint: EndPoint, completionHandler: @escaping ResultClosure<T>)
}
