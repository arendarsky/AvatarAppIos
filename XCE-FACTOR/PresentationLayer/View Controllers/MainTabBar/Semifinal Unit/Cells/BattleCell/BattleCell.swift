//
//  BattleCell.swift
//  XCE-FACTOR
//
//  Created by Sergey Desenko on 14.09.2020.
//  Copyright © 2020 Сергей. All rights reserved.
//

import UIKit

// TODO: По-хорошему здесь нужно переписывать все...
// 0) !! Вынести большую часть логики и реализаций в Clean Module, ячейка столько делать не должна !!
// 1) Убрать forceUnwrap
// 2) Убрать сервисы и тп.

final class BattleCell: UICollectionViewCell {

    // MARK: - IBOutlets

    @IBOutlet private weak var profilesCollectionView: UICollectionView!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var likedTalentsLabel: UILabel!
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var videoPlayerView: VideoPlayerView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var profilePhotoImageView: UIImageView!
    @IBOutlet private weak var videoLikesLabel: UILabel!

    // MARK: - Public Properties

    var battleParticipants: [BattleParticipant] = []
    var totalVotesNumber: Int?

    // MARK: - Private Properties

    private var numberOfLikedTalents = 0
    private var id: Int?
    private var endDate: Date?
    private var winnersNumber: Int?
    private var cachedProfileImages = [Int: UIImage?]()
    private var currentParticipant = 0
    private var timer: Timer?

    private let tapRecForImageView = UITapGestureRecognizer()
    private let tapRecForNameLabel = UITapGestureRecognizer()
    private var delegate: SemifinalVCDelegate? = nil

    private var timeIntervalToEnd: DateComponents {
        get {
            let calendar = Calendar(identifier: .gregorian)
            let components: Set<Calendar.Component> = [.day, .hour, .minute]
            let interval = calendar.dateComponents(components, from: Date(), to: endDate ?? Date())
            return interval
        }
    }

    private lazy var dateFormatter = DateFormatter()

    // MARK: - Init

    override func awakeFromNib() {
        super.awakeFromNib()

        profilesCollectionView.register(UINib(nibName: "StoriesCell", bundle: nil),
                                        forCellWithReuseIdentifier: "StoriesCell")
        profilesCollectionView.delegate = self
        profilesCollectionView.dataSource = self
        profilesCollectionView.collectionViewLayout = createLayout()

        videoView.layer.cornerRadius = 25
        videoView.layer.borderWidth = 2
        videoView.layer.borderColor = UIColor.systemPurple.cgColor
        videoPlayerView.layer.cornerRadius = 25

        updateLikesLabel()

        tapRecForImageView.addTarget(self, action: #selector(tappedView))
        tapRecForNameLabel.addTarget(self, action: #selector(tappedView))

        nameLabel.addGestureRecognizer(tapRecForNameLabel)
        profilePhotoImageView.addGestureRecognizer(tapRecForImageView)
    }

    // MARK: - Public Properties

    func updateCell(battle: BattleModel, delegate: SemifinalVC) {
        self.delegate = delegate
        videoPlayerView.configureVideoView(with: delegate)
        id = battle.id
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS"
        endDate = dateFormatter.date(from: battle.endDate)
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)

        updateTimerLabel()

        winnersNumber = battle.winnersNumber ?? 0
        totalVotesNumber = battle.totalVotesNumber ?? 0
        battleParticipants = battle.battleParticipants ?? []
        profilesCollectionView.reloadSections(IndexSet(arrayLiteral: 0))
        currentParticipant = 0

        if let isLikedByUser = battleParticipants[currentParticipant].semifinalist?.isLikedByUser, isLikedByUser {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }

        updateLikesLabel()
        updateVideoForParticipant(with: 0)
    }

    func reloadStories() {
        profilesCollectionView.reloadData()
    }

    func playVideo() {
        videoPlayerView.play()
    }

    func pauseVideo() {
        videoPlayerView.pause()
    }

    // MARK: - IBActions

    @IBAction func likeButtonWasTapped(_ sender: Any) {
        if let isLikedByUser = battleParticipants[currentParticipant].semifinalist?.isLikedByUser, isLikedByUser {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            battleParticipants[currentParticipant].semifinalist?.isLikedByUser = false
            battleParticipants[currentParticipant].semifinalist?.votesNumber! -= 1
            totalVotesNumber! -= 1
            profilesCollectionView.reloadData()

            // TODO: УБРАТЬ ИЗ ЯЧЕЙКИ!!!
            Semifinal.setOrCancelLikeOf(battleId: id!, semifinalistId: battleParticipants[currentParticipant].semifinalist!.id!, typeOfRequest: .cancel) { (serverResult) in
                switch serverResult {
                case .error(let error):
                    print("Error: \(error)")
                case .results(let responseCode):
                    if responseCode != 200 {
                        print("Response Code: \(responseCode)")
                    } else {
                        print("Succesfully cancelled like")
                    }
                }
            }
        } else if numberOfLikedTalents < 2 {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            battleParticipants[currentParticipant].semifinalist!.isLikedByUser! = true
            battleParticipants[currentParticipant].semifinalist!.votesNumber! += 1
            totalVotesNumber! += 1
            profilesCollectionView.reloadData()
            
            // TODO: УБРАТЬ ИЗ ЯЧЕЙКИ!!!
            Semifinal.setOrCancelLikeOf(battleId: id!, semifinalistId: battleParticipants[currentParticipant].semifinalist!.id!, typeOfRequest: .set) { (serverResult) in
                switch serverResult {
                case .error(let error):
                    print("Error: \(error)")
                case .results(let responseCode):
                    if responseCode != 200 {
                        print("Response Code: \(responseCode)")
                    } else {
                        print("Succesfully set like")
                    }
                }
            }
        }
        updateLikesLabel()
    }

    // MARK: - Actions
    
    @objc func tappedView() {
        delegate?.profileTapped(for: battleParticipants[currentParticipant].id)
    }

    @objc func fire() {
        updateTimerLabel()
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension BattleCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return battleParticipants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let storiesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell",
                                                             for: indexPath) as! StoriesCell

        let name = battleParticipants[indexPath.row].name ?? ""
        let votesNumber = battleParticipants[indexPath.row].semifinalist?.votesNumber
        let liked = battleParticipants[indexPath.row].semifinalist?.isLikedByUser

        storiesCell.setupCell(to: .percent(totalVotesNumber: totalVotesNumber,
                                           votesNumber: votesNumber,
                                           liked: liked),
                              image: nil,
                              name: name)
        
//        topCell.profileImageView.layer.cornerRadius = topCell.frame.width / 2

        loadProfileImage(for: storiesCell, indexPath: indexPath)
        
        return storiesCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentParticipant = indexPath.row
        updateVideoForParticipant(with: indexPath.row)

        if let isLikedByUser = battleParticipants[currentParticipant].semifinalist?.isLikedByUser, isLikedByUser {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
}

// MARK: - Private Methods

private extension BattleCell {
    
    func updateTimerLabel() {
        if timeIntervalToEnd.day! >= 0 && timeIntervalToEnd.hour! >= 0 && timeIntervalToEnd.minute! >= 0 {
            let day = timeIntervalToEnd.day! > 9 ? "\(timeIntervalToEnd.day!)" : "0\(timeIntervalToEnd.day!)"
            let hour = timeIntervalToEnd.hour! > 9 ? "\(timeIntervalToEnd.hour!)" : "0\(timeIntervalToEnd.hour!)"
            let minute = timeIntervalToEnd.minute! > 9 ? "\(timeIntervalToEnd.minute!)" : "0\(timeIntervalToEnd.minute!)"
            timerLabel.text = "\(day):\(hour):\(minute)"
        } else {
            timerLabel.text = "00:00:00"
        }
    }
    
    func updateVideoForParticipant(with index: Int) {
        let participant = battleParticipants[index]
        videoLikesLabel.text = String(participant.semifinalist?.votesNumber ?? 0)
        descriptionLabel.text = participant.description ?? ""
        nameLabel.text = participant.name ?? ""
        profilePhotoImageView.image = cachedProfileImages[participant.id!] ?? IconsManager.getIcon(.personCircleFill)!
        
        if let videoName = participant.semifinalist?.videoName {
             // TODO: Вынести взаимодействие с бэком из ячейки
            videoPlayerView.configureVideoPlayer(with: URL(string: "\(Globals.domain)/api/video/" + videoName))
        } else {
            // Handle ERROR
            print("No video name for participant with id \(String(describing: participant.id))")
        }
    }
    
    func updateLikesLabel(){
        var countLikes = 0

        for item in battleParticipants {
            if let isLikedByUser = item.semifinalist?.isLikedByUser, isLikedByUser {
                countLikes += 1
            }
        }

        switch countLikes {
        case 1:
            likedTalentsLabel.text = "Выбран 1 талант"
        case 2:
            likedTalentsLabel.text = "Выбрано 2 таланта"
        default:
            likedTalentsLabel.text = "Выбрано 0 талантов"
        }
    
        numberOfLikedTalents = countLikes
    }
    
    func loadProfileImage(for cell: StoriesCell, indexPath: IndexPath) {
        let user1 = battleParticipants[indexPath.row]
        guard let imageName = user1.profilePhoto else {
            print("no profile photo")
            return
        }

        if cachedProfileImages[user1.id!] != nil {
            let image = cachedProfileImages[user1.id!]!
            setProfileImage(image, for: cell, at: indexPath)
            print("set photo from cache")
        } else {
            // TODO: УБРАТЬ ИЗ ЯЧЕЙКИ!!!
            ProfileImage.getProfileImage(name: imageName) { (result) in
                switch result {
                case.error(let error):
                    print(error)
                    self.setProfileImage(nil, for: cell, at: indexPath)
                case.results(let image):
                    self.setProfileImage(image, for: cell, at: indexPath)
                    if indexPath.row == 0 && self.currentParticipant == 0 {
                        self.profilePhotoImageView.image = image
                    }
                    if image != nil && self.cachedProfileImages[user1.id!] == nil {
                        self.cachedProfileImages[user1.id!] = image
                        //updateVideo(forParticipantWithIndex: indexPath.row)
                    }
                }
            }
        }
    }
    
    func setProfileImage(_ image: UIImage?, for cell: StoriesCell, at indexPath: IndexPath) {
        cell.setImage(image)
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let topItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                                     heightDimension: .fractionalHeight(1.0))
            let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)
            topItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
            let contentWidth = layoutEnvironment.container.effectiveContentSize.width
            let itemsCount = contentWidth > 350 ? 5 : 4
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: topItem, count: itemsCount)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
        return layout
    }
}