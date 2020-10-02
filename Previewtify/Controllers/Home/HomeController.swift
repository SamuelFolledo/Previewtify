//
//  HomeController.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/18/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import SnapKit
import Spartan

class HomeController: UIViewController {
    
    //MARK: Properties
    var artists: [Artist] = []
    var offset: Int = 0
    
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
        table.register(ArtistCell.self, forCellReuseIdentifier: String(describing: ArtistCell.self))
        return table
    }()
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchTopArtists()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        offset = 0
    }
    
    //MARK: Private Methods
    
    fileprivate func setupViews() {
        navigationItem.backButtonTitle = "Artists"
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        setupBackground()
    }
    
    fileprivate func setupBackground() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.title = "Top 50 Artists"
        view.backgroundColor = .systemBackground
    }
    
    func fetchTopArtists() {
        NetworkManager.refreshAcessToken { (result) in
            switch result {
            case .failure(let error):
                self.presentAlert(title: "Error Refreshing token", message: error.localizedDescription)
            case .success(let spotifyAuth):
                print(spotifyAuth.accessToken)
                _ = Spartan.getMyTopArtists(limit: 50, offset: self.offset, timeRange: .longTerm, success: { (pagingObject) in
                    // Get the artists via pagingObject.items
                    guard let fetchedArtists = pagingObject.items else { return }
                    self.artists = fetchedArtists
                    self.offset = self.artists.count - 1
                    self.tableView.reloadData()
                }, failure: { (error) in
                    print(error)
                })
            }
        }
    }
    
    //MARK: Helpers
}

//MARK: Extensions

extension HomeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! ArtistCell
        let artist = artists[indexPath.row]
        let vc = ArtistTrackController()
        vc.artist = artist
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArtistCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ArtistCell.self), for: indexPath) as! ArtistCell
        DispatchQueue.global(qos: .userInteractive).async {
            let artist = self.artists[indexPath.row]
            DispatchQueue.main.async {
                cell.populateViews(artist: artist, rank: indexPath.row + 1)
                cell.layoutSubviews()
            }
        }
        return cell
    }
}
