//
//  StopPairingDTO.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/10/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation

public struct StopPairingDTO: StopPairing {
    public let fromStop: Stop
    public let toStop: Stop

    public init(fromStop: Stop, toStop: Stop) {
        self.fromStop = fromStop
        self.toStop = toStop
    }

}

extension StopPairingDTO {
    
    public init(_ stopPairing: StopPairing) {
        self.fromStop = StopDTO(stop: stopPairing.fromStop)
        self.toStop   = StopDTO(stop: stopPairing.toStop)
    }
}
