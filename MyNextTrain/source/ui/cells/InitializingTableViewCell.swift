//
//  InitializingTableViewCell.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/5/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit

class InitializingTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    func initialize() {
        //no op
    }
    
}
