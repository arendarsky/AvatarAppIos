//
//  FinalViewController.swift
//  XCE-FACTOR
//
//  Created by Антон Шуплецов on 03.02.2021.
//  Copyright © 2021 Владислав. All rights reserved.
//

import UIKit
import WebKit

protocol FinalViewControllerProtocol: AnyObject {
    func setupStreaming(videoURL: URL, timer: Date)

    func display(cellsModels: [FinalistTableCellModel])

    func setProfileImage(_ image: UIImage, at index: Int)

    func showError()
}

final class FinalViewController: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var streamingVideo: WKWebView!
    @IBOutlet private weak var timerLabel: TimerLabel!
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

        configureCustomNavBar()
        configureNavBar()
        configureVideoPlayer()
        configureTableView()

        interactor.setupInitialData()
    }
}

// MARK: - FinalViewControllerProtocol

extension FinalViewController: FinalViewControllerProtocol {
    func showError() {
        //
    }
    

    func setupStreaming(videoURL: URL, timer: Date) {
        let request = URLRequest(url: videoURL)
        streamingVideo.load(request)

        timerLabel.setupTimer(endDate: timer)
    }

    func display(cellsModels: [FinalistTableCellModel]) {
        finalistsCellsModels = cellsModels
        tableView.reloadData()
    }
    
    func setProfileImage(_ image: UIImage, at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)

        finalistsCellsModels[index].image = image
        
        if let cell = tableView.cellForRow(at: indexPath) as? FinalistTableCell {
            cell.set(image: image)
        }
    }
}

// MARK: - FinalistDelegate

extension FinalViewController: FinalistDelegate {
    func imageTapped(index: Int) {
        interactor.processTransitionToProfile(in: index)
    }
    
    func voteButtonTapped(index: Int) {
        interactor.sendVote()
    }
}

// MARK: - UITableViewDataSource

extension FinalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        finalistsCellsModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FinalistTableCell", for: indexPath) as! FinalistTableCell
        cell.selectionStyle = .none
        cell.set(viewModel: finalistsCellsModels[indexPath.row], delegate: self)
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

extension FinalViewController: WKUIDelegate {

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true

        return WKWebView(frame: webView.frame, configuration: webConfiguration)
    }
}

// MARK: - Private Methods

private extension FinalViewController {

    func configureVideoPlayer() {
        streamingVideo.uiDelegate = self
        streamingVideo.layer.masksToBounds = true
        streamingVideo.layer.cornerRadius = 15
        streamingVideo.layer.borderWidth = 1
        streamingVideo.layer.borderColor = UIColor(red: 224/255, green: 12/255, blue: 220/255, alpha: 1).cgColor
    }

    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UINib(nibName: "FinalistTableCell", bundle: nil),
                           forCellReuseIdentifier: "FinalistTableCell")
    }

    func configureNavBar() {
        navigationItem.title = "Финал"
    }
}
