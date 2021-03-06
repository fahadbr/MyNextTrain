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

open class RxSubtitleCell: RxCell {

    private let disposeBag = DisposeBag()

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.detailTextLabel?.rx.observe(NSAttributedString.self, "attributedText").bindNext({[weak self] _ in
            self?.setNeedsLayout()
        }).addDisposableTo(disposeBag)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
