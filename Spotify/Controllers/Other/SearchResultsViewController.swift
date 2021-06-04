//
//  SearchResultsViewController.swift
//  Spotify
//
//  Created by Anthony Kim on 3/15/21.
//

import UIKit
//for time being
struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private var sections: [SearchSection] = []

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped) // make it look nicer
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // want the tableview to be hidden by default
        // only going to show it if there is valid search result
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with results: [SearchResult]) {
        // filter out various types of results
        let artists = results.filter({
            switch $0 {
            case .artist:
                return true
            default:
                return false
            }
        })
        let albums = results.filter({
            switch $0 {
            case .album:
                return true
            default:
                return false
            }
        })
        let tracks = results.filter({
            switch $0 {
            case .track:
                return true
            default:
                return false
            }
        })
        let playlists = results.filter({
            switch $0 {
            case .playlist:
                return true
            default:
                return false
            }
        })
        self.sections = [
            SearchSection(title: "Songs", results: tracks),
            SearchSection(title: "Artists", results: artists),
            SearchSection(title: "Playlists", results: playlists),
            SearchSection(title: "Albums", results: albums)
        ]
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch result {
        case .artist(let model):
            cell.textLabel?.text = model.name
        case .album(let model):
            cell.textLabel?.text = model.name
        case .track(let model):
            cell.textLabel?.text = model.name
        case .playlist(let model):
            cell.textLabel?.text = model.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // to be able to tap into these need to implement this method
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

}