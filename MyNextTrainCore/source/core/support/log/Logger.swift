//
//  Logger.swift
//  Kyooz
//
//  Created by FAHAD RIAZ on 5/3/15.
//  Copyright (c) 2015 FAHAD RIAZ. All rights reserved.
//

import Foundation

public final class Logger {
    
    static let loggerQueue = DispatchQueue(label: "com.riaz.fahad.Logger")
    
    static let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy hh:mm:ss:SSS a"
        return formatter
    }()
	
    private static let debugEnabled = true
    
    
    private static var threadName:String {
        var t =  OperationQueue.current?.name ?? "null"
		if let range = t.range(of: "") {
			t.removeSubrange(range)
		}
        return t
    }
    
    public static func debug(_ messageBlock: @autoclosure ()->String) {
        guard debugEnabled else { return }
        
        let date = Date()
        let threadId = threadName
        let message = messageBlock()
//        loggerQueue.async {
            let dateString = dateFormatter.string(from: date)
            print("\(dateString) DEBUG [\(threadId)]: \(message)")
//        }
    }
    
	public static func error(_ message:String, error: Error? = nil) {
        let date = Date()
        let threadId = threadName
        loggerQueue.async {
            let dateString = dateFormatter.string(from: date)
            let message = "\(dateString) ERROR [\(threadId)]: [\(error?.description ?? "") \(message)]"
            print(message)
        }
    }
	
	
}
