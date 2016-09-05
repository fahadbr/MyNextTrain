//
//  GTFSFileLoader.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/21/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSFileLoader {
    
    static let instance = GTFSFileLoader()
    
    private static let files: [GTFSFile] = [.routes, .stops, .trips, .calendar_dates, .stop_times]
	
    
    func loadAllFiles() {
		let loadingGroup = DispatchGroup()
		
		
        for file in GTFSFileLoader.files {
			
            switch file {
            case .routes:
                loadAsync(file: file, type: RouteImpl.self, dispatchGroup: loadingGroup)
            case .stops:
                loadAsync(file: file, type: StopImpl.self, dispatchGroup: loadingGroup)
            case .trips:
                loadAsync(file: file, type: TripImpl.self, dispatchGroup: loadingGroup)
            case .calendar_dates:
                loadAsync(file: file, type: CalendarDateImpl.self, dispatchGroup: loadingGroup)
            case .stop_times:
                loadAsync(file: file, type: StopTimeImpl.self, dispatchGroup: loadingGroup)
            }
        }
		
		loadingGroup.notify(queue: DispatchQueue.main) {
			Logger.debug("done loading all files")
		}
        
    }
    
	private func loadAsync<T: Object>(file: GTFSFile,
	                       type: T.Type,
	                       dispatchGroup: DispatchGroup) {
        
		DispatchQueue.global(qos: .default).async(group: dispatchGroup) {
			self.load(file: file, type: type)
			Logger.debug("done mapping file \(file)")
        }
        
    }
	
	private func load<T: Object>(file: GTFSFile, type: T.Type) {
		let quotationCharacterSet = CharacterSet(charactersIn: "\"")
		
		func lineComponents(from line: String) -> [String] {
			return line.components(separatedBy: ",").map { $0.trimmingCharacters(in: quotationCharacterSet) }
		}
		do {
			let realm = try Realm()
			
			guard realm.allObjects(ofType: type).isEmpty else {
				Logger.debug("files have already been loaded")
				return
			}
		
			guard let fileURL = Bundle.main.url(forResource: file.rawValue, withExtension: "txt") else {
				fatalError("couldnt find file \(file.rawValue)")
			}
			
			let fileAsString = try NSString(contentsOf: fileURL, encoding: String.Encoding.utf8.rawValue)
			var lines = fileAsString.components(separatedBy: "\n")
			
			let columns = lineComponents(from: lines[0])
			
			let realmObject = lines[1..<lines.count].lazy
				.filter { !$0.isEmpty }
				.map { line -> T in
					let result = T()
					(result as? GTFSFileEntry)?.apply(row: GTFSFileRow(names: columns, values: lineComponents(from: line)))
					return result
			}
			
			
			try realm.write {
				realmObject.forEach { realm.add($0) }
			}
			
		} catch let error {
			Logger.error("error loading file \(file)", error: error)
		}
		
	}
	
}
