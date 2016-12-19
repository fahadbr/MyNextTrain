//
//  GTFSFileLoader.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/21/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import RealmSwift

public class GTFSFileLoader {
    
    public static let instance = GTFSFileLoader()
    static let doneLoadingFiles = Notification.Name("doneLoadingFiles")
    
    private typealias This = GTFSFileLoader
    private static let files: [GTFSFile] = [.routes, .stops, .trips, .calendar_dates, .stop_times]
    lazy var updateService = AppContainer.updateService
    
    public func loadAllFiles() {
		let loadingGroup = DispatchGroup()
        
        if AppContainer.overrideReload, let realm = try? Realm(), !realm.isEmpty{
            try? realm.write {
                realm.deleteAll()
            }
        }
        
        func loadAsync<T: Object>(file: GTFSFile,
                               type: T.Type,
                               generator: @escaping () -> T) {
            
            DispatchQueue.global(qos: .default).async(group: loadingGroup) {
                self.load(file: file, type: type, generator: generator)
                Logger.debug("done mapping file \(file)")
            }
            
        }
        
        for file in This.files {
			
            switch file {
            case .routes:
                loadAsync(file: file, type: RouteImpl.self, generator: { RouteImpl() } )
            case .stops:
                loadAsync(file: file, type: StopImpl.self, generator: { StopImpl() } )
            case .trips:
                loadAsync(file: file, type: TripImpl.self, generator: { TripImpl() } )
            case .calendar_dates:
                loadAsync(file: file, type: CalendarDateImpl.self, generator: { CalendarDateImpl() } )
            case .stop_times:
                loadAsync(file: file, type: StopTimeImpl.self, generator: { StopTimeImpl() } )
            }
        }
		
		loadingGroup.notify(queue: DispatchQueue.global(qos: .default)) {
			Logger.debug("done loading all files")
            self.updateService.setUpObjectLinks()
            Logger.debug("done setting up object links")
            DispatchQueue.main.async {
                let ref = AppContainer.overrideReloadReference
                UserDefaults.standard.set(ref.value, forKey: ref.name)
                
                let notification = Notification(name: This.doneLoadingFiles, object: self, userInfo: nil)
                NotificationCenter.default.post(notification)
            }
            
		}
        
    }
    
//	private func loadAsync<T: Object>(file: GTFSFile,
//	                       type: T.Type,
//	                       dispatchGroup: DispatchGroup) {
//        
//		DispatchQueue.global(qos: .default).async(group: dispatchGroup) {
//			self.load(file: file, type: type)
//			Logger.debug("done mapping file \(file)")
//        }
//        
//    }
	
    private func load<T: Object>(file: GTFSFile, type: T.Type, generator: @escaping () -> T) {
		let quotationCharacterSet = CharacterSet(charactersIn: "\"")
		
		func lineComponents(from line: String) -> [String] {
			return line.components(separatedBy: ",").map { $0.trimmingCharacters(in: quotationCharacterSet) }
		}
        
		do {
			let realm = try Realm()
			
			guard realm.objects(type).isEmpty || AppContainer.overrideReload else {
				Logger.debug("file \(file) has already been loaded")
				return
			}
		
			guard let fileURL = Bundle.main.url(forResource: file.rawValue, withExtension: "txt") else {
				fatalError("couldnt find file \(file.rawValue)")
			}
			
			let fileAsString = try NSString(contentsOf: fileURL, encoding: String.Encoding.utf8.rawValue)
			var lines = fileAsString.components(separatedBy: "\n")
			
			let columns = lineComponents(from: lines[0])
			
			let realmObjects = lines[1..<lines.count].lazy
				.filter { !$0.isEmpty }
				.map { line -> T in
					let result = generator()
                    let values = lineComponents(from: line)
                    let row = GTFSFileRow(names: columns, values: values)
					(result as? GTFSFileEntry)?.apply(row: row)
					return result
			}
			
			
			try realm.write {
				realm.add(realmObjects)
			}
			
		} catch let error {
			Logger.error("error loading file \(file)", error: error)
		}
		
	}
	
}
