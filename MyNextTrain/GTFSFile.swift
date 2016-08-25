//
//  GTFSFile.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/21/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

enum GTFSFile: String {
    
    case routes, trips, stops, stop_times, calendar_dates
    
    func readFile<T: GTFSFileEntry>() -> [T] {
        let quotationCharacterSet = CharacterSet(charactersIn: "\"")
        
        func lineComponents(from line: String) -> [String] {
            return line.components(separatedBy: ",").map { $0.trimmingCharacters(in: quotationCharacterSet) }
        }
        
        guard let fileURL = Bundle.main.url(forResource: self.rawValue, withExtension: "txt") else {
            fatalError("couldnt find file \(self.rawValue)")
        }
        
        let fileAsString = try! NSString(contentsOf: fileURL, encoding: String.Encoding.utf8.rawValue)
        var lines = fileAsString.components(separatedBy: "\n")
        
        let columns = lineComponents(from: lines.removeFirst())
        
        var results = [T]()
		results.reserveCapacity(lines.count)
        for line in lines {
            guard !line.isEmpty else { continue }
            
            var columnMap = [String : String]()
            lineComponents(from: line).enumerated().forEach {
                columnMap[columns[$0.offset]] = $0.element
            }
            
            let result = T()
			result.apply(columnMap: columnMap)
			results.append(result)
        }
        return results
        
    }
}
