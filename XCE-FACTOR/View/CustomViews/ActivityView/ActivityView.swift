//
//MARK:  ActivityView.swift
//  XCE-FACTOR
//
//  Created by Владислав on 23.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ActivityView: UIView {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var supplementaryLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    //MARK:- Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xibSetup()
    }
    
    convenience init(frame: CGRect, title: String?, supplementaryText: String?) {
        self.init(frame: frame)
        self.title = title
        self.supplementaryText = supplementaryText
        
    }
    
    //MARK:- Configure
    func configure() {
        layer.masksToBounds = true
        layer.cornerRadius = 12
        
        guard let parentView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: frame.height),
            widthAnchor.constraint(equalToConstant: frame.width),
            centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
            centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
        ])
    }
    
    //MARK:- Xib Setup
    private func xibSetup() {
        Bundle.main.loadNibNamed("ActivityView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.isHidden = true
    }
    
    override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set {
            super.isHidden = newValue
            contentView.isHidden = newValue
            newValue ?
                activityIndicator.stopAnimating() :
            activityIndicator.startAnimating()
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            super.backgroundColor = newValue
            contentView.backgroundColor = newValue
        }
    }
    
    
    //MARK:- Public Properties
    ///
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            self.titleLabel.text = newValue
        }
    }
    
    var supplementaryText: String? {
        get {
            return supplementaryLabel.text
        }
        set {
            self.supplementaryLabel.text = newValue
        }
    }

}
