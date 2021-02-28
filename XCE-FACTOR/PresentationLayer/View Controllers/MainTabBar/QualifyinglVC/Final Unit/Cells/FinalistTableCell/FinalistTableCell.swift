//
//  FinalistTableCell.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 05.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

protocol FinalistDelegate {
    func imageTapped(id: Int)

    func voteButtonTapped(id: Int)
}

final class FinalistTableCell: UITableViewCell {

    // MARK: - Constans

    struct Constans {
        static let wideButtonWidth: CGFloat = 101
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

    private var id: Int = 0
    private var isEnabled = true
    private var isButtonTapped = false
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
        
        set(enabled: isEnabled)
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
        id = viewModel.id
        profileButton.setImage(viewModel.image, for: .normal)
        nameLabel.text = viewModel.name
        setButtonSelected(viewModel.voted, animated: false)
        set(enabled: viewModel.isEnabled)
        self.delegate = delegate
    }

    func set(enabled: Bool) {
        isEnabled = enabled
        voiceButton.isHighlighted = !enabled
        voiceButton.isEnabled = enabled
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
        isButtonTapped = selected

        let actionBlock = {
            self.buttonWidthConstraint.constant = selected
                ? Constans.narrowButtonWidth
                : Constans.wideButtonWidth

            self.voiceButton.backgroundColor = selected
                ? Constans.narrowButtonColor
                : Constans.wideButtonColor

            self.voiceButton.setTitle(selected ? "Готово" : "Выбрать" , for: .normal)

            if animated {
                self.layoutIfNeeded()
            }
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0,
                           options: [.beginFromCurrentState],
                           animations: actionBlock, completion: nil)
        } else {
            actionBlock()
        }
    }

    func makeCircleProfileImage() {
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
    }

    @objc func imageTapped() {
        delegate?.imageTapped(id: id)
    }

    @objc func voiceButtonTapped() {
        setButtonSelected(!isButtonTapped, animated: true)
        delegate?.voteButtonTapped(id: id)
    }
}
