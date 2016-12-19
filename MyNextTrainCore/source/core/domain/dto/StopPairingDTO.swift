//
//  StopPairingDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/10/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

struct StopPairingDTO: StopPairing {
    let fromStop: Stop
    let toStop: Stop
}
extension StopPairingDTO {
    
    init(_ stopPairing: StopPairing) {
        self.fromStop = StopDTO(stop: stopPairing.fromStop)
        self.toStop   = StopDTO(stop: stopPairing.toStop)
    }
}
