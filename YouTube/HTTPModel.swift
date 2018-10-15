//
//  NetworkModel.swift
//  IMQAMpmAgent
//
//  Created by Theodore Cha on 2018. 9. 3..
//  Copyright © 2018년 Theodore Cha. All rights reserved.
//

import Foundation

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

@objc public class HTTPModel: NSObject {
    
    @objc var dateKey: Int = Int(Date().timeIntervalSince1970 * 10000)
    
    @objc public var requestURL: String?
    @objc public var requestMethod: String?
    @objc public var requestCachePolicy: String?
    @objc public var requestDate: String?
    @objc public var requestTime: String?
    @objc public var requestTimeout: String?
    @objc public var requestHeaders: [AnyHashable: Any]?
    public var requestBodyLength: Int?
    @objc public var requestType: String?
    
    public var responseStatus: Int?
    @objc public var responseType: String?
    @objc public var responseDate: String?
    @objc public var responseTime: String?
    @objc public var responseHeaders: [AnyHashable: Any]?
    public var responseBodyLength: Int?
    
    public var timeInterval: Float?
    
    @objc public var randomHash: NSString?
    
    @objc public var shortType: NSString = HTTPModelShortType.OTHER.rawValue as NSString
    
    @objc public var noResponse: Bool = true
    
    func saveRequest(_ request: URLRequest) {
        self.requestDate = "\(Int(NSDate().timeIntervalSince1970 * 1000))"
        self.requestTime = getTimeFromDate(Date())
        self.requestURL = request.getIMQAURL()
        self.requestMethod = request.getIMQAMethod()
        self.requestCachePolicy = request.getIMQACachePolicy()
        self.requestTimeout = request.getIMQATimeout()
        self.requestHeaders = request.getIMQAHeaders()
        self.requestType = requestHeaders?["Content-Type"] as! String?
    }
    
    func saveErrorResponse() {
        self.responseDate = "\(Int(NSDate().timeIntervalSince1970 * 1000))"
    }
    
    func saveResponse(_ response: URLResponse, data: Data) {
        self.noResponse = false
        
        self.responseDate = "\(Int(NSDate().timeIntervalSince1970 * 1000))"
        self.responseTime = getTimeFromDate(Date())
        self.responseStatus = response.getIMQAStatus()
        self.responseHeaders = response.getIMQAHeaders()
        
        let headers = response.getIMQAHeaders()
        
        if let contentType = headers["Content-Type"] as? String {
            self.responseType = contentType.components(separatedBy: ";")[0]
            self.shortType = getShortTypeFrom(self.responseType!).rawValue as NSString
        }
        
        self.timeInterval = 0.0
        
    }
    
    func getInfoStringFromObject() -> [String:String] {
        
        var requestDictionary: [String:String] = [:]
        
        var interval = 0
        
        if let request_time = self.requestDate{
            requestDictionary.updateValue(request_time, forKey: "request_time")
        } else {
            requestDictionary.updateValue("0", forKey: "request_time")
        }
        
        if !(self.noResponse) {
            if let response_time = self.responseDate {
                interval = Int(self.responseDate!)! - Int(self.requestDate!)!
                requestDictionary.updateValue(response_time, forKey: "response_time")
            }
            
            if let status = self.responseStatus {
                requestDictionary.updateValue("\(status)", forKey: "status")
            }
        } else {
            
            requestDictionary.updateValue("\(Int(NSDate().timeIntervalSince1970 * 1000))", forKey: "response_time")
        }
        //let vc_name_arr = vc_name.split { $0 == "." }.map(String.init)
        
        if self.requestURL!.range(of:"//") != nil{
            let url: String = self.requestURL!
            let url_arr = url.split { $0 == ":" }.map(String.init)
            
            if url_arr[0] == "https" {
                requestDictionary.updateValue("https", forKey: "protocol")
                requestDictionary.updateValue("443", forKey: "port")
            } else {
                requestDictionary.updateValue("http", forKey: "protocol")
                requestDictionary.updateValue("80", forKey: "port")
            }
            
            let temp_arr = url_arr[1].split { $0 == "/" }.map(String.init)
            
            if temp_arr[0].range(of: ":") != nil {
                let in_port_arr = temp_arr[0].split { $0 == ":" }.map(String.init)
                requestDictionary.updateValue(in_port_arr[0], forKey: "host")
                requestDictionary.updateValue(in_port_arr[1], forKey: "port")
            } else {
                requestDictionary.updateValue(temp_arr[0], forKey: "host")
            }
            
            if temp_arr.count > 1 {
                
                let url_temp_arr = url.split { $0 == "/" }.map(String.init)
                
                if url_temp_arr.count > 3 {
                    let front = url_temp_arr[0].count + 2 + url_temp_arr[1].count
                    let range = String.Index(encodedOffset: front)
                    
                    let path_name = String(url[range...])
                    requestDictionary.updateValue(path_name, forKey: "path_name")
                } else {
                    requestDictionary.updateValue("/", forKey: "path_name")
                }
            }
        }
        
        if let method = self.requestMethod {
            requestDictionary.updateValue(method, forKey: "method")
        }
        
        print("Network Monitoring \t | \(self.requestMethod ?? "") \t | \(self.requestURL ?? "") \t | Time Interval : \(interval)ms")
        
        return requestDictionary
    }
    
    @objc public func getTimeFromDate(_ date: Date) -> String? {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour, .minute], from: date)
        guard let hour = components.hour, let minutes = components.minute else {
            return nil
        }
        if minutes < 10 {
            return "\(hour):0\(minutes)"
        } else {
            return "\(hour):\(minutes)"
        }
    }
    
    public func getShortTypeFrom(_ contentType: String) -> HTTPModelShortType {
        if NSPredicate(format: "SELF MATCHES %@",
                       "^application/(vnd\\.(.*)\\+)?json$").evaluate(with: contentType) {
            return .JSON
        }
        
        if (contentType == "application/xml") || (contentType == "text/xml")  {
            return .XML
        }
        
        if contentType == "text/html" {
            return .HTML
        }
        
        if contentType.hasPrefix("image/") {
            return .IMAGE
        }
        
        return .OTHER
    }
    
    @objc public func isSuccessful() -> Bool {
        if (self.responseStatus != nil) && (self.responseStatus < 400) {
            return true
        } else {
            return false
        }
    }
    
    @objc public func formattedRequestLogEntry() -> String {
        var log = String()
        
        if let requestURL = self.requestURL {
            log.append("-------START REQUEST -  \(requestURL) -------\n")
        }
        
        if let requestMethod = self.requestMethod {
            log.append("[Request Method] \(requestMethod)\n")
        }
        
        if let requestDate = self.requestDate {
            log.append("[Request Date] \(requestDate)\n")
        }
        
        if let requestTime = self.requestTime {
            log.append("[Request Time] \(requestTime)\n")
        }
        
        if let requestType = self.requestType {
            log.append("[Request Type] \(requestType)\n")
        }
        
        if let requestTimeout = self.requestTimeout {
            log.append("[Request Timeout] \(requestTimeout)\n")
        }
        
        if let requestHeaders = self.requestHeaders {
            log.append("[Request Headers]\n\(requestHeaders)\n")
        }
        
        if let requestURL = self.requestURL {
            log.append("-------END REQUEST - \(requestURL) -------\n\n")
        }
        
        return log;
    }
    
    @objc public func formattedResponseLogEntry() -> String {
        var log = String()
        
        if let requestURL = self.requestURL {
            log.append("-------START RESPONSE -  \(requestURL) -------\n")
        }
        
        if let responseStatus = self.responseStatus {
            log.append("[Response Status] \(responseStatus)\n")
        }
        
        if let responseType = self.responseType {
            log.append("[Response Type] \(responseType)\n")
        }
        
        if let responseDate = self.responseDate {
            log.append("[Response Date] \(responseDate)\n")
        }
        
        if let responseTime = self.responseTime {
            log.append("[Response Time] \(responseTime)\n")
        }
        
        if let responseHeaders = self.responseHeaders {
            log.append("[Response Headers]\n\(responseHeaders)\n\n")
        }
        
        if let requestURL = self.requestURL {
            log.append("-------END RESPONSE - \(requestURL) -------\n\n")
        }
        
        return log;
    }
    
}
