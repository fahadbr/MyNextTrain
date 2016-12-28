//
//  FavoritePairCell.swift
//  MyNextTrain
//
//  Created by Fahad Riaz on 12/17/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

open class RxCell: UITableViewCell {

    private (set) public var reuseDisposeBag = DisposeBag()

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
