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
    var artists: [Artist] = [] {
        didSet { tableView.reloadData() }
    }
    
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
    }
    
    //MARK: Private Methods
    
    fileprivate func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        setupBackground()
        fetchTopArtists()
    }
    
    fileprivate func setupBackground() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Top 50 Artists"
        view.backgroundColor = .systemBackground
    }
    
    func fetchTopArtists() {
        NetworkManager.refreshAcessToken { (result) in
            switch result {
            case .failure(let error):
                self.presentAlert(title: "Error Refreshing token", message: error.localizedDescription)
            case .success(let spotifyAuth):
                print(spotifyAuth.accessToken)
                _ = Spartan.getMyTopArtists(limit: 50, offset: 0, timeRange: .mediumTerm, success: { (pagingObject) in
                    // Get the artists via pagingObject.items
                    guard let fetchedArtists = pagingObject.items else { return }
                    for artist in fetchedArtists {
                        print("Adding \(artist.name)")
                        self.artists.append(artist)
                    }
                }, failure: { (error) in
                    print(error)
                })
            }
        }
    }
    
    //MARK: Helpers
}

//MARK: Extensions

extension HomeController: UITableViewDelegate {}

extension HomeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ArtistCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ArtistCell.self), for: indexPath) as! ArtistCell
        let artist = artists[indexPath.row]
        cell.artist = artist
        return cell
    }
}
