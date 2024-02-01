//
//  NetworkMonitor.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import Foundation
import Network
class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknow
    private init() {
        monitor =  NWPathMonitor()
    }
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknow
    }
    
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            self.isConected = path.status == .satisfied
            self.getConnectionType(path)
            print(path)
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath){
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknow
        }
    }
}
