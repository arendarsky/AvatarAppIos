//
//  SemifinalistsVC.swift
//  XCE-FACTOR
//
//  Created by user on 13.09.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SemifinalVC: XceFactorViewController {

    var battles: [Battle]?
//    var videoNames: [String] = ["uc2tkchr.xmy.mp4", "i12f0lo3.zrn.mp4", "jo3havh0.oux.mp4","33uy1qaf.wvu.mp4","xcin0ja5.nna.mp4","c3tze0ul.a3s.mp4"]
    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(), type: .circleStrokeSpin, color: .systemPurple, padding: 8.0)
    var profile = UserProfile()
    @IBOutlet weak var semifinalView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavBar()
        self.battlesCollectionView.collectionViewLayout = self.createLayout()
        self.battlesCollectionView.delegate = self
        self.battlesCollectionView.dataSource = self
        updateSemifinalists()
        loadingIndicator.enableCentered(in: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBOutlet weak var battlesCollectionView: UICollectionView!
    
    
    private func updateSemifinalists() {
        Semifinal.getBattlesData() { (sessionResult) in
                switch sessionResult {
                case let .error(error):
                    print("Error: \(error)")
                case let .results(data):
                    print("Successfully recieved battles data from server")
                    self.battles = data
//                    self.setvideos()
                    self.battlesCollectionView.reloadData()
                    self.loadingIndicator.stopAnimating()
                    print("battles \(self.battles?.count ?? 25)")
                }
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile from Semifinal" {
            let vc = segue.destination as! ProfileViewController
            vc.userData = profile
            vc.isPublic = true
           }
    }
    
    
    // MARK: Debug and test
//    func setvideos(){
//        for i in 0...5{
//            battles![0].battleParticipants![i].semifinalist!.videoName = videoNames[i]
//        }
//
//    }
    func updateBattle(forCell cell: BattleCell, with indexPath: IndexPath){
        if battles != nil {
            battles![indexPath.row].battleParticipants = cell.battleParticipants
            battles![indexPath.row].totalVotesNumber = cell.totalVotesNumber
        } else {
            return
        }
    }

    
    
}

extension SemifinalVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return battles?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BattleCell", for: indexPath) as! BattleCell
        cell.updateCell(battle: battles![indexPath.row], parent: self)
        cell.profilesCollectionView.reloadData()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let battleCell = cell as? BattleCell else{
            return
        }
        updateBattle(forCell: battleCell, with: indexPath)
        battleCell.videoPlayerView.pause()
    }
}
extension SemifinalVC{
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let ItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .fractionalHeight(1.0))
            let Item = NSCollectionLayoutItem(layoutSize: ItemSize)
            Item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(CGFloat(layoutEnvironment.container.effectiveContentSize.height) * CGFloat(self.battles?.count ?? 5)))
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: Item, count: self.battles?.count ?? 5)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            return section
        }
        return layout
    }
}
