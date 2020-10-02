//
//  FavoriteSongController.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/29/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Spartan

class FavoriteSongController: UIViewController {
    
    //MARK: Properties
    var artist: Artist!
    var tracks: [Track] = []
    var offset: Int = 0
    
    //MARK: Views
    //MARK: Views
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .grouped)
        table.sectionHeaderHeight = 40
        table.backgroundColor = .systemBackground
        table.rowHeight = 100
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.tableFooterView = UIView()
        table.allowsMultipleSelection = false
        table.register(TrackCell.self, forCellReuseIdentifier: String(describing: TrackCell.self))
        return table
    }()
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavoriteSongs()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        offset = 0
    }
    
    //MARK: Private Methods
    
    fileprivate func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        setupBackground()
    }
    
    fileprivate func setupBackground() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = "Favorite Songs"
        view.backgroundColor = .systemBackground
    }
    
    func fetchFavoriteSongs() {
        NetworkManager.refreshAcessToken { (result) in
            switch result {
            case .failure(let error):
                self.presentAlert(title: "Error Refreshing token", message: error.localizedDescription)
            case .success(_):
                Spartan.getMyTopTracks(limit: 50, offset: self.offset, timeRange: .longTerm) { (pagingObject) in
                    self.tracks = pagingObject.items
                    self.offset = self.tracks.count - 1
                    self.tableView.reloadData()
                } failure: { (error) in
                    self.presentAlert(title: "Error Fetching Tracks", message: error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: Helpers
}

//MARK: Extensions

extension FavoriteSongController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = collectionView.cellForItem(at: indexPath) as! ArtistCell
//        let track = tracks[indexPath.row]
//        let vc = ArtistTrackController()
//        vc.artist = artist
//        navigationController?.pushViewController(vc, animated: true)
    }
}

extension FavoriteSongController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackCell.self), for: indexPath) as! TrackCell
        DispatchQueue.global(qos: .userInteractive).async {
            let track = self.tracks[indexPath.row]
            DispatchQueue.main.async {
                cell.populateViews(track: track, rank: indexPath.row + 1)
                cell.layoutSubviews()
            }
        }
        return cell
    }
}
