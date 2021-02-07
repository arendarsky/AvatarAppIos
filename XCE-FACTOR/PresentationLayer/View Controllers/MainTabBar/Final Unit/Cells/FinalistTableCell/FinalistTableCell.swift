//
//  FinalistTableCell.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

final class FinalistTableCell: UITableViewCell {

    // MARK: - Constans

    struct Constans {
        static let wideButtonWidth: CGFloat = 131
        static let narrowButtonWidth: CGFloat = 81
        /// TODO: Вынести все цвета в одну фабрику
        static let wideButtonColor = UIColor(red: 20/255, green: 21/255, blue: 22/255, alpha: 1)
        static let narrowButtonColor = UIColor(red: 224/255, green: 12/255, blue: 220/255, alpha: 1)
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var voiceButton: UIButton!

    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Public Methods

    func set(viewModel: FinalistTableCellModel) {
        profileImage.image = viewModel.image
        nameLabel.text = viewModel.name
        setButtonSelected(viewModel.voted, animated: false)
    }
}

// MARK: - Private Methods

private extension FinalistTableCell {

    func setButtonSelected(_ selected: Bool, animated: Bool) {
        let actionBlock = {
            self.buttonWidthConstraint.constant = selected
                ? Constans.narrowButtonWidth
                : Constans.wideButtonWidth

            self.voiceButton.backgroundColor = selected
                ? Constans.narrowButtonColor
                : Constans.wideButtonColor

            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.3) {
                actionBlock()
            }
        } else {
            actionBlock()
        }
    }
}
