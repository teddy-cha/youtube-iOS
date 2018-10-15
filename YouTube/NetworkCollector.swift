//
//  NetworkCollector.swift
//  IMQAMpmAgent
//
//  Created by Theodore Cha on 2018. 9. 3..
//  Copyright © 2018년 Theodore Cha. All rights reserved.
//

import Foundation
import UIKit

@objc
class NetworkCollector: NSObject {
    
    class var swiftSharedInstance: NetworkCollector {
        struct Singleton {
            static let instance = NetworkCollector()
        }
        return Singleton.instance
    }
    
    @objc class func sharedInstance() -> NetworkCollector {
        return NetworkCollector.swiftSharedInstance
    }
    
    fileprivate var started: Bool = false
    fileprivate var enabled: Bool = false
    fileprivate var ignoredURLs = [String]()
    internal var cacheStoragePolicy = URLCache.StoragePolicy.notAllowed
    
    @objc func start() {
        guard !self.started else {
            print("Already started IMQA Network Module")
            return
        }
        
        self.started = true
        
         register()
         enable()
    }
    
    @objc func stop() {
        self.started = false
        
        unregister()
        disable()
    }
    
    fileprivate func register() {
        URLProtocol.registerClass(NetworkProtocol.self)
    }
    
    fileprivate func unregister() {
        URLProtocol.registerClass(NetworkProtocol.self)
    }
    
    internal func isEnabled() -> Bool {
        return self.enabled
    }
    
    internal func enable() {
        self.enabled = true
    }
    
    internal func disable() {
        self.enabled = false
    }
    
    @objc func ignoreURL(_ url: String) {
        self.ignoredURLs.append(url)
    }
    
    func getIgnoredURLs() -> [String] {
        return self.ignoredURLs
    }
    
    @objc open func setCachePolicy(_ policy: URLCache.StoragePolicy) {
        cacheStoragePolicy = policy
    }
}
