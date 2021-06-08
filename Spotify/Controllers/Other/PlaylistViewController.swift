//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by Anthony Kim on 3/15/21.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    
    private let playlist: Playlist
    
    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
                                                    
                                                    // item
                                                    let item = NSCollectionLayoutItem(
                                                        layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .fractionalHeight(1.0)
                                                        )
                                                    )
                                                    item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
                                                    
                                                    let group = NSCollectionLayoutGroup.vertical(
                                                        layoutSize: NSCollectionLayoutSize(
                                                            widthDimension: .fractionalWidth(1),
                                                            heightDimension: .absolute(60)
                                                        ),
                                                        subitem: item,
                                                        count: 1)
                                                    // section;;section is the nscollectionlayoutsection
                                                    let section = NSCollectionLayoutSection(group: group)
                                                    section.boundarySupplementaryItems = [
                                                        NSCollectionLayoutBoundarySupplementaryItem(
                                                            layoutSize: NSCollectionLayoutSize(
                                                                widthDimension: .fractionalWidth(1),
                                                                heightDimension: .fractionalWidth(1)),
                                                            elementKind: UICollectionView.elementKindSectionHeader,
                                                            alignment: .top)
                                                    ]
                                                    return section
                                                  }))
    
    // custom initializer
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.register(RecommendedTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        APICaller.shared.getPlaylistDetails(for: playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    // RecommendedTrackCellViewModel
                    self?.tracks = model.tracks.items.compactMap({ $0.track }) // self.track is now array of track that is now owned by the playlist
                    // set up view model for each of the tracks in this playlist
                    self?.viewModels = model.tracks.items.compactMap({
                        RecommendedTrackCellViewModel(name: $0.track.name,
                                                      artistName: $0.track.artists.first?.name ?? "-",
                                                      artworkURL: URL(string: $0.track.album?.images.first?.url ?? ""))
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(didTapShare))
    }
    
    @objc private func didTapShare() {
        
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        let vc = UIActivityViewController(activityItems: [url],
                                          applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    // give the collection view a frame
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as?
                RecommendedTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    // need to deque whenever we want tohat particular header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // we dont want to return anything for the footer
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
                                                                           for: indexPath
        ) as? PlaylistHeaderCollectionReusableView,
        kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        // lets create the viewmodel
        let headerViewModel = PlaylistHeaderViewModel(name: playlist.name,
                                                      ownerName: playlist.owner.display_name,
                                                      description: playlist.description,
                                                      artworkURL: URL(string: playlist.images.first?.url ?? ""))
        
        // pass it to the view to be configured
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let index = indexPath.row
        let track = tracks[index] // get the nth track at the index
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        // we want to send collection of tracks to the player presenter
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
}
