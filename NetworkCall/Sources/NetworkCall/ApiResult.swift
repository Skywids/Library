//
//  ApiResult.swift
//  
//
//  Created by Skywinds on 10/10/20.
//

import Foundation

public enum ApiResult<T> {
    case success(model: T)
    case error(error: ApiErrorMessage)
}
