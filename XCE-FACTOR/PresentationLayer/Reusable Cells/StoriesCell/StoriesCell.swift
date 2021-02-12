//
//  StoriesCell.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 31.01.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

final class StoriesCell: UICollectionViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var percentLabel: UILabel!
    @IBOutlet private weak var likesLabel: UILabel!
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        makeCircleImageView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        makeCircleImageView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        percentLabel.text = ""
        likesLabel.text = ""
        profileImageView.image = nil
    }
   
    // MARK: - Public Methods

    func set(viewModel: StoriesCellModel) {
        setupCell(to: viewModel.stroriesCellType,
                  image: viewModel.profileImage,
                  name: viewModel.name)
    }

    func setImage(_ image: UIImage?) {
        profileImageView.image = image ?? IconsManager.getIcon(.personCircleFill)
    }
}

// MARK: - Private Methods

private extension StoriesCell {
    
    func configureCell() {
        profileImageView.image = IconsManager.getIcon(.personCircleFill)
        profileImageView.tintColor = .systemPurple
        profileImageView.layer.borderColor = UIColor.systemPurple.cgColor
        profileImageView.layer.borderWidth = 2.5
        profileImageView.isUserInteractionEnabled = true
    }

    func makeCircleImageView() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }

    func setupCell(to type: StroriesCellType, image: UIImage?, name: String) {
        nameLabel.text = name

        if let image = image {
            profileImageView.image = image
        }

        switch type {
        case .likes(let number):
            percentLabel.isHidden = true

            if let likesNumber = number {
                likesLabel.text = "♥ \(likesNumber.formattedToLikes(.shortForm))"
                likesLabel.isHidden = false
            } else {
                likesLabel.isHidden = true
            }
        case let .percent(totalVotesNumber, votesNumber, liked):
            likesLabel.isHidden = true

            if let votesNumber = votesNumber, totalVotesNumber != 0 {
                percentLabel.text = "\(votesNumber * 100 / totalVotesNumber!)%"
                percentLabel.isHidden = false
            } else {
                percentLabel.isHidden = true
            }

            profileImageView.layer.borderColor = liked == true
                ? UIColor.systemPurple.cgColor
                : UIColor.darkGray.cgColor
        }
    }
}
