//
//  GTFSFileLoader.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/21/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

class GTFSFileLoader {
    
    static let instance = GTFSFileLoader()
    
    private static let files: [GTFSFile] = [.routes, .stops, .trips, .calendar_dates, .stop_times]
    
    
    
    var routeMap = [AnyHashable : [RouteDTO]]()
    var stopMap = [AnyHashable : [StopDTO]]()
    var tripMap = [AnyHashable : [TripDTO]]()
    var calendarMap = [AnyHashable : [CalendarDateDTO]]()
    var stopTimeMap = [AnyHashable : [StopTimeDTO]]()
    
    
    func loadAllFiles() {
        
        for file in GTFSFileLoader.files {
            
            switch file {
            case .routes:
                load(file: file) {
                    self.routeMap = $0
                }
            case .stops:
                load(file: file) {
                    self.stopMap = $0
                }
            case .trips:
                load(file: file) {
                    self.tripMap = $0
                }
            case .calendar_dates:
                load(file: file) {
                    self.calendarMap = $0
                }
            case .stop_times:
                load(file: file) {
                    self.stopTimeMap = $0
                }
            }
        }
        
    }
    
    private func load<T: GTFSFileEntry>(file: GTFSFile,
                        completion: @escaping ([AnyHashable : [T]])->()) {
        
        DispatchQueue.global(qos: .default).async {
            let results: [AnyHashable : [T]] = file.readFile()
            DispatchQueue.main.async {
                completion(results)
            }
        }
        
    }
    
}
