//
//  SemifinalistsVC.swift
//  XCE-FACTOR
//
//  Created by Sergey Desenko on 13.09.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol SemifinalVCProtocol: AnyObject {}

protocol SemifinalVCDelegate {
    /// Метод срабатывает при нажатии на на иконку профиля
    func profileTapped(for id: Int?)
}

final class SemifinalVC: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var battlesCollectionView: UICollectionView!

    // MARK: - Private Properties
    
    //    var videoNames: [String] = ["uc2tkchr.xmy.mp4", "i12f0lo3.zrn.mp4", "jo3havh0.oux.mp4","33uy1qaf.wvu.mp4","xcin0ja5.nna.mp4","c3tze0ul.a3s.mp4"]

    private let router: SemifinalRouterProtocol
    private let interactor: SemifinalInteractorProtocol
    private let semifinalManager: SemifinalManagerProtocol
    private let profileManager: ProfileServicesManagerProtocol

    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(),
                                                           type: .circleStrokeSpin,
                                                           color: .systemPurple,
                                                           padding: 8.0)
    private var battles: [BattleModel]?

    // MARK: - Init

    init(interactor: SemifinalInteractorProtocol,
         router: SemifinalRouterProtocol,
         semifinalManager: SemifinalManagerProtocol,
         profileManager: ProfileServicesManagerProtocol) {
        self.interactor = interactor
        self.router = router
        self.semifinalManager = semifinalManager
        self.profileManager = profileManager

        super.init(nibName: "SemifinalVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Полуфинал"

        configureCustomNavBar()
        configureCollectionView()
        updateSemifinalists()
        loadingIndicator.enableCentered(in: view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playVideo()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pauseVideo()
    }
}

// MARK: - SemifinalVCProtocol

extension SemifinalVC: SemifinalVCProtocol {}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension SemifinalVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return battles?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BattleCell", for: indexPath) as! BattleCell
        cell.updateCell(battle: battles![indexPath.row], delegate: self)
        cell.reloadStories()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let battleCell = cell as? BattleCell else { return }

        updateBattle(forCell: battleCell, with: indexPath)
        battleCell.pauseVideo()
    }
}

// MARK: - SemifinalVCDelegate

extension SemifinalVC: SemifinalVCDelegate {
    func profileTapped(for id: Int?) {
        profileManager.getUserData(for: id) { result in
            switch result {
            case .success(let userProfile):
                self.router.routeToProfileVC(for: userProfile)
            case .failure: break
                // Handle Error
            }
        }
    }
}

// MARK: - Private Methods

private extension SemifinalVC {
    ///   Debug and test:
    //    func setvideos(){
    //        for i in 0...5{
    //            battles![0].battleParticipants![i].semifinalist!.videoName = videoNames[i]
    //        }
    //    }

    func playVideo() {
        guard let battleCell = battlesCollectionView.visibleCells.first as? BattleCell else { return }
        battleCell.playVideo()
    }

    func pauseVideo() {
        guard let battleCell = battlesCollectionView.visibleCells.first as? BattleCell else { return }
        battleCell.pauseVideo()
    }

    func configureCollectionView() {
        battlesCollectionView.register(UINib(nibName: "BattleCell", bundle: nil),
                                       forCellWithReuseIdentifier: "BattleCell")
        battlesCollectionView.collectionViewLayout = createLayout()
        battlesCollectionView.delegate = self
        battlesCollectionView.dataSource = self
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(CGFloat(layoutEnvironment.container.effectiveContentSize.height) * CGFloat(self.battles?.count ?? 5)))
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: self.battles?.count ?? 5)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
        return layout
    }

    func updateSemifinalists() {
        semifinalManager.fetchSemifinalBattles { result in
            switch result {
            case .success(let battleModels):
                self.battles = battleModels
                self.battlesCollectionView.reloadData()
                self.loadingIndicator.stopAnimating()
            case .failure: break
                // TODO: Handle error
            }
        }
    }
    
    func updateBattle(forCell cell: BattleCell, with indexPath: IndexPath) {
        guard battles != nil else { return }

        battles?[indexPath.row].battleParticipants = cell.battleParticipants
        battles?[indexPath.row].totalVotesNumber = cell.totalVotesNumber
    }
}