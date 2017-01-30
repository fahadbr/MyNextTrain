//
//  ContainerConfig.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/24/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import Foundation
import Dip
import MyNextTrainCore

class AppContainerConfig {

    
    static func configureAll() throws -> RootVC {

        let coreContainer = CoreContainerProxy.container
        GTFSFileLoader.instance.loadAllFiles()

        viewModelContainer.collaborate(with: coreContainer, vcContainer, dipFactoryContainer)
        vcContainer.collaborate(with: coreContainer, viewModelContainer, dipFactoryContainer)

        try coreContainer.bootstrap()
        try DependencyContainer.bootstrapAll()
        return VcFactory().rootVC()
    }

}
