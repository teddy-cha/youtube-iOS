//
//  NetworkHelper.swift
//  IMQAMpmAgent
//
//  Created by Theodore Cha on 2018. 9. 3..
//  Copyright © 2018년 Theodore Cha. All rights reserved.
//

import Foundation

public enum HTTPModelShortType: String
{
    case JSON = "JSON"
    case XML = "XML"
    case HTML = "HTML"
    case IMAGE = "Image"
    case OTHER = "Other"
    
    static let allValues = [JSON, XML, HTML, IMAGE, OTHER]
}

extension URLRequest
{
    func getIMQAURL() -> String
    {
        if (url != nil) {
            return url!.absoluteString;
        } else {
            return "-"
        }
    }
    
    func getIMQAMethod() -> String
    {
        if (httpMethod != nil) {
            return httpMethod!
        } else {
            return "-"
        }
    }
    
    func getIMQACachePolicy() -> String
    {
        switch cachePolicy {
        case .useProtocolCachePolicy: return "UseProtocolCachePolicy"
        case .reloadIgnoringLocalCacheData: return "ReloadIgnoringLocalCacheData"
        case .reloadIgnoringLocalAndRemoteCacheData: return "ReloadIgnoringLocalAndRemoteCacheData"
        case .returnCacheDataElseLoad: return "ReturnCacheDataElseLoad"
        case .returnCacheDataDontLoad: return "ReturnCacheDataDontLoad"
        case .reloadRevalidatingCacheData: return "ReloadRevalidatingCacheData"
        }
        
    }
    
    func getIMQATimeout() -> String
    {
        return String(Double(timeoutInterval))
    }
    
    func getIMQAHeaders() -> [AnyHashable: Any]
    {
        if (allHTTPHeaderFields != nil) {
            return allHTTPHeaderFields!
        } else {
            return Dictionary()
        }
    }
}

extension URLResponse
{
    func getIMQAStatus() -> Int
    {
        return (self as? HTTPURLResponse)?.statusCode ?? 999
    }
    
    func getIMQAHeaders() -> [AnyHashable: Any]
    {
        return (self as? HTTPURLResponse)?.allHeaderFields ?? [:]
    }
}
