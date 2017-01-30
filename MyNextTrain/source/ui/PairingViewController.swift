//
//  PairingViewController.swift
//  MyNextTrain
//
//  Created by FAHAD RIAZ on 9/10/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import MyNextTrainCore

class PairingViewController: UIViewController {
    
    
    private let fromStationButton = UIButton.withDefaults()
    private let toStationButton = UIButton.withDefaults()
    private let reverseDirectionButton = UIButton.withDefaults()
    
    private lazy var dividerPath: UIBezierPath = {
        let midY = self.stationStack.bounds.height/2
        let inset: CGFloat = 10
        $0.move(to: CGPoint(x: inset, y: midY))
        $0.addLine(to: CGPoint(x: self.stationStack.frame.width - inset, y: midY))
        return $0
    }(UIBezierPath())
    
    
    private let favoritePairDetails: FavoritePairDetails
    private let disposeBag = DisposeBag()

    private let stationStack = UIStackView()
    private let dividerPathLayer = CAShapeLayer()

    
    init(favoritePairDetails: FavoritePairDetails) {
        self.favoritePairDetails = favoritePairDetails
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoritePairDetails.fromStopName.drive(fromStationButton.rx.title(for: .normal)).addDisposableTo(disposeBag)
        favoritePairDetails.toStopName.drive(toStationButton.rx.title(for: .normal)).addDisposableTo(disposeBag)
        reverseDirectionButton.setTitle("↑↓", for: .normal)
        reverseDirectionButton.rx.controlEvent(.touchUpInside).bindNext { [weak self] in
            self?.favoritePairDetails.switch()
        }.addDisposableTo(disposeBag)
        
        stationStack.addArrangedSubview(fromStationButton)
        stationStack.addArrangedSubview(toStationButton)
        stationStack.axis = .vertical
        stationStack.distribution = .fillEqually
        
        dividerPathLayer.strokeColor = UIColor.black.cgColor
        dividerPathLayer.lineWidth = 0.5
        dividerPathLayer.lineCap = kCALineCapRound
        stationStack.layer.addSublayer(dividerPathLayer)
        
        func newLabel(text: String) -> UILabel {
            let l = UILabel()
            l.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            l.textColor = UIColor.black
            l.textAlignment = .right
            l.text = text
            return l
        }


        let fromToStack = UIStackView(arrangedSubviews: [newLabel(text: "from"), newLabel(text: "to")])
        fromToStack.axis = .vertical
        fromToStack.distribution = .fillEqually
        
        let mainStack = UIStackView(arrangedSubviews: [fromToStack, stationStack, reverseDirectionButton])
        mainStack.axis = .horizontal
        mainStack.distribution = .fillProportionally
        view.add(subView: mainStack, anchor: Anchor.standardAnchors)
        view.backgroundColor = UIColor.white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.cornerRadius = 10
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.dividerPathLayer.path = self.dividerPath.cgPath
            self.dividerPathLayer.frame = self.stationStack.bounds
        }
        
    }
    
    
}
