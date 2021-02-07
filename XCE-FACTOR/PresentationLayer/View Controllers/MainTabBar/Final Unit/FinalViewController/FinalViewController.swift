//
//  FinalViewController.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit

protocol FinalViewControllerProtocol: AnyObject {
    func display(cellsModels: [FinalistTableCellModel])
}

final class FinalViewController: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var videoPlayerView: VideoPlayerView!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Private Properties

    private let interactor: FinalInteractorProtocol
    private var finalistsCellsModels: [FinalistTableCellModel]

    // MARK: - Init

    init(interactor: FinalInteractorProtocol) {
        self.interactor = interactor
        self.finalistsCellsModels = []
        super.init(nibName: "FinalViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureVideoPlayer()
        configureTableView()
        interactor.setupInitialData()
    }
}

// MARK: - FinalViewControllerProtocol

extension FinalViewController: FinalViewControllerProtocol {
    func display(cellsModels: [FinalistTableCellModel]) {
//        if let videoURL = URL(string: "https://vk.com/video_ext.php?oid=-182191338&id=456239464&hash=e0d018b5e535304f") {
//            let request = URLRequest(url: videoURL)
//            videoPlayerView.load(request)
//        }
        finalistsCellsModels = cellsModels
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension FinalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        finalistsCellsModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FinalistTableCell", for: indexPath) as! FinalistTableCell
        cell.set(viewModel: finalistsCellsModels[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FinalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}

// MARK: - WKUIDelegate

//extension FinalViewController: WKUIDelegate {
//
//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        let webConfiguration = WKWebViewConfiguration()
//        webConfiguration.allowsInlineMediaPlayback = true
//
//        return WKWebView(frame: webView.frame, configuration: webConfiguration)
//    }
//}

// MARK: - Private Methods

private extension FinalViewController {

    func configureVideoPlayer() {
//        videoPlayerView.uiDelegate = self
//        videoPlayerView.layer.masksToBounds = true
//        videoPlayerView.layer.cornerRadius = 15
//        videoPlayerView.layer.borderWidth = 1
//        videoPlayerView.layer.borderColor = UIColor(red: 224/255, green: 12/255, blue: 220/255, alpha: 1).cgColor
//
//        // add activity
//        //        videoPlayerView.addSubview(self.Activity)
//        //        self.Activity.startAnimating()
//        //        videoPlayerView.navigationDelegate = self
//        //        self.Activity.hidesWhenStopped = true
    }

    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}
