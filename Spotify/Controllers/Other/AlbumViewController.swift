//
//  AlbumViewController.swift
//  Spotify
//
//  Created by Anthony Kim on 5/27/21.
//

import UIKit
// responsible for rendering out things related to one album
// it should own property for the given album
class AlbumViewController: UIViewController {
    
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
    
 
    
    private var viewModels = [AlbumCollectionViewCellViewModel]()
    
    private let album: Album
    
    // custom initializer
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        
        
        view.addSubview(collectionView)
        collectionView.register(AlbumTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // as soon as viewdidload is called we arae going to start fetching data
        APICaller.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    
                    self?.viewModels = model.tracks.items.compactMap({
                        AlbumCollectionViewCellViewModel(name: $0.name,
                                                      artistName: $0.artists.first?.name ?? "-")
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    // give the collection view a frame
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTrackCollectionViewCell.identifier, for: indexPath) as?
                AlbumTrackCollectionViewCell else {
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
        let headerViewModel = PlaylistHeaderViewModel(name: album.name,
                                                      ownerName: album.artists.first?.name,
                                                      description: "Release Date: \(String.formattedDate(string: album.release_date))",
                                                      artworkURL: URL(string: album.images.first?.url ?? ""))

        // pass it to the view to be configured
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // play song
    }
}

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        // start play list play in queue
        print("Playing all")
    }
}
