//
//  LibraryAlbumsViewController.swift
//  Spotify
//
//  Created by Anthony Kim on 6/8/21.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    
    
    var albums = [Album]()
    private let noAlbumsView = ActionLabelView()
    
    // create instance for table view
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    // observe for the notificaiton.
    // object to hold onto the observer
    private var observer: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        setUpNoAlbumsView()
        fetchData()
        observer = NotificationCenter.default.addObserver(forName: .albumSavedNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.fetchData()
        })
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: (view.width-150)/2, y: (view.height-150)/2, width: 150, height: 150)
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
    }
    
    private func setUpNoAlbumsView() {
        view.addSubview(noAlbumsView)
        noAlbumsView.delegate = self
        noAlbumsView.configure(with: ActionLabelViewViewModel(text: "You have not saved any albums yet", actionTitle: "Browse"))
    }
    
    
    private func fetchData() {
        albums.removeAll()
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async { // put on main thread bc we are going to use stuff on the main thread.
                switch result {
                case .success(let albums):
                    // hold onto playlist
                    
                    self?.albums = albums
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    // if you have playlist we probably want to lay it out in like a tableview
    private func updateUI() {
        if albums.isEmpty {
            // Show label
            
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        } else {
            // show table of actaul playlist
            // reload table view?
            tableView.reloadData()
            noAlbumsView.isHidden = true
            tableView.isHidden = false
        }
    }
    
}

extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        // when the user taps on this
        tabBarController?.selectedIndex = 0 // so we will switch the user back to the browse tab
    }
}

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as?
                SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row] // album at the given position
        
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.name,
                                                                        subtitle: album.artists.first?.name ?? "-",
                                                                        imageURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    // at the moment, nothing happens when we press on the playlsit created so
    // lets bring in the delegate function for the tableview
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // unhighlight
        let album = albums[indexPath.row] // get the nth playlist
    
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
