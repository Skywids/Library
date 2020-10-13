//
//  HTTPBody.swift
//
//
//  Created by Skywinds on 10/13/20.
//

import Foundation

public protocol HTTPBody {
    var isEmpty: Bool { get }
    var additionalHeaders: [String: String] { get }
    func encode() throws -> Data
}

public extension HTTPBody {
    var isEmpty: Bool { return false }
    var additionalHeaders: [String: String] { return [:] }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

public struct DataBody: HTTPBody {
    private let data: Data
    
    public var isEmpty: Bool { data.isEmpty }
    public var additionalHeaders: [String: String]
    
    public init(_ data: Data, additionalHeaders: [String: String] = [:]) {
        self.data = data
        self.additionalHeaders = additionalHeaders
    }
    
    public func encode() throws -> Data { data }
}

public struct JSONBody: HTTPBody {
    public let isEmpty: Bool = false
    public var additionalHeaders = [
        "Content-Type": "application/json; charset=utf-8"
    ]
    
    private let _encode: () throws -> Data
    
    public init<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) {
        self._encode = { try encoder.encode(value) }
    }
    
    public func encode() throws -> Data { return try _encode() }
}

public struct FormBody: HTTPBody {
    public var isEmpty: Bool { values.isEmpty }
    public let additionalHeaders = [
        "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
    ]
    
    private let values: [URLQueryItem]
    
    public init(_ values: [URLQueryItem]) {
        self.values = values
    }
    
    public init(_ values: [String: String]) {
        let queryItems = values.map { URLQueryItem(name: $0.key, value: $0.value) }
        self.init(queryItems)
    }
    
    public func encode() throws -> Data {
        let pieces = values.map(self.urlEncode)
        let bodyString = pieces.joined(separator: "&")
        return Data(bodyString.utf8)
    }

    private func urlEncode(_ queryItem: URLQueryItem) -> String {
        let name = urlEncode(queryItem.name)
        let value = urlEncode(queryItem.value ?? "")
        return "\(name)=\(value)"
    }

    private func urlEncode(_ string: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""
    }
}

public struct MultiFormFileData {
    let fileName: String
    let mimeType: String?
    let fileData: Data
}

public struct MultiFormBody: HTTPBody {
    public var isEmpty: Bool { values.isEmpty }
    public var additionalHeaders: [String : String] {
      return ["Content-Type": "multipart/form-data; boundary=\(self.boundary)" ]
    }
    
    private let values: [URLQueryItem]
    private let fileData: [MultiFormFileData]
    private let boundary = "Boundary-\(UUID().uuidString)"
    
    public init(_ values: [URLQueryItem], fileData: [MultiFormFileData]) {
        self.values = values
        self.fileData = fileData
    }
    
    public init(_ values: [String: String], fileData: [MultiFormFileData]) {
        let queryItems = values.map { URLQueryItem(name: $0.key, value: $0.value) }
        self.init(queryItems, fileData: fileData)
    }
    
    public func encode() throws -> Data {
        return getBody()
    }

    private func getBody() -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for item in self.values {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(item.name)\"\r\n\r\n")
            body.appendString("\(item.value ?? "")\r\n")
        }
        
        for file in self.fileData {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(file.fileName)\"\r\n")
            body.appendString("Content-Type: \(file.mimeType ?? "content-type header")\r\n\r\n")
            body.append(file.fileData)
            body.appendString("\r\n")
        }
        
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    
}
