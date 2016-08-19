//
//  GTFSFileParser.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 8/19/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit


class GTFSFileParser {
	
	private let fileName: String
	
	init(fileName: String) {
		self.fileName = fileName
	}
	
	func parse<T>(andMapUsing mapper: ([String]) -> T) -> [T] {
		guard let fileURL = Bundle.main.url(forResource: fileName,
		                                    withExtension: "txt")
			else {
				fatalError("couldnt find file \(fileName)")
		}
		
		let fileAsString = try! NSString(contentsOf: fileURL, encoding: String.Encoding.utf8.rawValue)
		var lines = fileAsString.components(separatedBy: "\n")
		
		_ = lines.removeFirst()
		
		let c = CharacterSet(charactersIn: "\"")
		return lines.map {
			let j = $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: c) } 
			return mapper(j)
		}
		
	}
	
	
}
