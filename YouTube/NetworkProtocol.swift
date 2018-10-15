//
//  NetworkProtocol.swift
//  IMQAMpmAgent
//
//  Created by Theodore Cha on 2018. 9. 3..
//  Copyright © 2018년 Theodore Cha. All rights reserved.
//

import Foundation

@objc class NetworkProtocol: URLProtocol {
    var connection: NSURLConnection?
    var model: HTTPModel?
    var session: URLSession?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return canServeRequest(request)
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else { return false }
        return canServeRequest(request)
    }
    
    fileprivate class func canServeRequest(_ request: URLRequest) -> Bool {
        
        if !NetworkCollector.sharedInstance().isEnabled() {
            return false
        }
        
        if let url = request.url {
            if !(url.absoluteString.hasPrefix("http")) && !(url.absoluteString.hasPrefix("https")) {
                return false
            }
            
            for ignoredURL in NetworkCollector.sharedInstance().getIgnoredURLs() {
                if url.absoluteString.hasPrefix(ignoredURL) {
                    return false
                }
            }
        } else {
            return false
        }
        
        if URLProtocol.property(forKey: "IMQAInternal", in: request) != nil {
            return false
        }
        
        return true
    }
    
    override open func startLoading() {
        self.model = HTTPModel()
        
        var req: NSMutableURLRequest
        req = (NetworkProtocol.canonicalRequest(for: request) as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        
        self.model?.saveRequest(req as URLRequest)
        
        URLProtocol.setProperty("1", forKey: "IMQAInternal", in: req)
        
        if session == nil {
            session = URLSession(configuration: URLSessionConfiguration.default, delegate: self as? URLSessionDelegate, delegateQueue: nil)
        }
        
        session!.dataTask(with: req as URLRequest, completionHandler: {data, response, error in
            
            if let error = error {
                self.model?.saveErrorResponse()
                self.loaded()
                self.client?.urlProtocol(self, didFailWithError: error)
                
            } else {
                if let data = data {
                    self.model?.saveResponse(response!, data: data)
                }
                self.loaded()
            }
            
            if let response = response, let client = self.client {
                client.urlProtocol(self, didReceive: response, cacheStoragePolicy: NetworkCollector.swiftSharedInstance.cacheStoragePolicy)
            }
            
            if let data = data {
                self.client!.urlProtocol(self, didLoad: data)
            }
            
            if let client = self.client {
                client.urlProtocolDidFinishLoading(self)
            }
        }).resume()
    }
    
    override open func stopLoading() {
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    func loaded(){
        
        
        UserDefaults(suiteName: "io.imqa.mpm.request")?
            .setValue(self.model!.getInfoStringFromObject(), forKey: "\(self.model!.dateKey)")
        
        
        
        
//        if (self.model != nil) {
//            NFXHTTPModelManager.sharedInstance.add(self.model!)
//        }
        
//        NotificationCenter.default.post(name: Notification.Name.NFXReloadData, object: nil)
    }
}
