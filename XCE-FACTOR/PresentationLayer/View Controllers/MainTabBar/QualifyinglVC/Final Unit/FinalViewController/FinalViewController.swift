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
    func setupStreaming(videoURL: URL)

    func display(timerText: String, timerTime: Date, cellsModels: [FinalistTableCellModel])

    func setProfileImage(_ image: UIImage, at index: Int)

    func changeVoiceStatus(numberOfVoices: Int)

    func cancelVoice(id: Int)

    func showError()
}

final class FinalViewController: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var streamingVideo: WKWebView!
    @IBOutlet private weak var timerLabel: TimerLabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var voteTitle: UILabel!
    
    // MARK: - Private Properties

    private let interactor: FinalInteractorProtocol
    private var finalistsCellsModels: [FinalistTableCellModel]
    private var numberOfVoices: Int

    // MARK: - Init

    init(interactor: FinalInteractorProtocol) {
        self.interactor = interactor
        self.finalistsCellsModels = []
        self.numberOfVoices = 0
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
        configureRefrechControl()
        configureVideoPlayer()
        configureTableView()

        interactor.setupInitialData()
    }
}

// MARK: - FinalViewControllerProtocol

extension FinalViewController: FinalViewControllerProtocol {
    func showError() {
        hideLoadingActivity()
    }

    func cancelVoice(id: Int) {
        guard var model = finalistsCellsModels.first(where: { $0.id == id }),
              let modelIndex = finalistsCellsModels.firstIndex(where: { $0.id == id })
              else { return }

        model.voted = !model.voted
        tableView.reloadRows(at: [IndexPath(row: modelIndex, section: 0)], with: .none)
    }


    func setupStreaming(videoURL: URL) {
        let request = URLRequest(url: videoURL)
        streamingVideo.load(request)
    }
    func display(timerText: String, timerTime: Date, cellsModels: [FinalistTableCellModel]) {
        voteTitle.text = timerText
        timerLabel.setupTimer(endDate: timerTime)

        hideLoadingActivity()

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

    func changeVoiceStatus(numberOfVoices: Int) {
//        customButton.title = "Выбери \(numberOfVoices) победителей"

        for (i, cellModel) in finalistsCellsModels.enumerated() {
            let indexPath = IndexPath(row: i, section: 0)
            var enabled = numberOfVoices != 0
            if cellModel.voted { enabled = true }

            finalistsCellsModels[i].isEnabled = enabled

            if let cell = tableView.cellForRow(at: indexPath) as? FinalistTableCell {
                cell.set(enabled: enabled)
            }
        }
    }
}

// MARK: - FinalistDelegate

extension FinalViewController: FinalistDelegate {
    func imageTapped(id: Int) {
        interactor.processTransitionToProfile(in: id)
    }
    
    func voteButtonTapped(id: Int) {
        guard let index = finalistsCellsModels.firstIndex(where: { $0.id == id }) else { return }
        finalistsCellsModels[index].voted = !finalistsCellsModels[index].voted
        interactor.sendVote(for: id)
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
        print(indexPath.row)
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

    func configureRefrechControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    func hideLoadingActivity() {
        tableView.refreshControl?.endRefreshing()
    }

    @objc func handleRefreshControl() {
        interactor.refreshData()
    }
}
