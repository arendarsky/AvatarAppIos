//
//  FinalistTableCell.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

protocol FinalistDelegate {
    func imageTapped(index: Int)

    func voteButtonTapped(index: Int)
}

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

    @IBOutlet private weak var profileButton: ResizableButton!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var voiceButton: UIButton!

    @IBOutlet private weak var buttonWidthConstraint: NSLayoutConstraint!

    // MARK: - Priavate Properties

    private var delegate: FinalistDelegate?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileButton.setImage(nil, for: .normal)
        nameLabel.text = ""
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        makeCircleProfileImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        makeCircleProfileImage()
    }

    // MARK: - Public Methods

    func set(viewModel: FinalistTableCellModel, delegate: FinalistDelegate) {
        tag = viewModel.id
        profileButton.setImage(viewModel.image, for: .normal)
        nameLabel.text = viewModel.name
        setButtonSelected(viewModel.voted, animated: false)
        self.delegate = delegate
    }

    func set(image: UIImage) {
        profileButton.setImage(image, for: .normal)
    }
}

// MARK: - Private Methods

private extension FinalistTableCell {

    func configureViews() {
        profileButton.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(voiceButtonTapped), for: .touchUpInside)
    }

    func setButtonSelected(_ selected: Bool, animated: Bool) {
        let actionBlock = {
            self.buttonWidthConstraint.constant = selected
                ? Constans.narrowButtonWidth
                : Constans.wideButtonWidth

            self.voiceButton.backgroundColor = selected
                ? Constans.narrowButtonColor
                : Constans.wideButtonColor

            self.voiceButton.setTitle(selected ? "Выбрать" : "Готово", for: .normal)

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

    func makeCircleProfileImage() {
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
    }

    @objc func imageTapped() {
        delegate?.imageTapped(index: tag)
    }

    @objc func voiceButtonTapped() {
        delegate?.voteButtonTapped(index: tag)
    }
}
