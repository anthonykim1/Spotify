//
//  SearchViewController.swift
//  Spotify
//
//  Created by Anthony Kim on 3/15/21.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    
    
    // to get the search bar we are going to leverage search controller
    
    let searchController: UISearchController = {
        // not only gives you the nice search bar at the top but also lets you
        // plum your actual search results into your search result controller

        let vc = UISearchController(searchResultsController: SearchResultsViewController())
        vc.searchBar.placeholder = "Songs, Artists, Albums"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    private let collectionView: UICollectionView =
        UICollectionView(frame: .zero,
                         collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
                            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                 heightDimension: .fractionalHeight(1)))
                            item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                                         leading: 7,
                                                                         bottom: 2,
                                                                         trailing: 7)
                            
                            // we are going to have single group which is horizontal
                            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                              heightDimension: .absolute(150)),
                                                                           subitem: item,
                                                                           count: 2)
                            
                            // add some content insets on the group as well
                            group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                            
                            return NSCollectionLayoutSection(group: group)
                         }))
    
    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        view.addSubview(collectionView)
        collectionView.register(GenreCollectionViewCell.self, forCellWithReuseIdentifier: GenreCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        //fetch our category
        APICaller.shared.getCategories { [weak self] result in
            
            DispatchQueue.main.async { // update ui, particularly collection once we get there
                switch result {
                case .success(let models):
                    let first = models.first!
                    APICaller.shared.getCategoryPlaylists(category: first) { foo in
                        
                    }
                case .failure(let error): break
                    
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        // resultsController.update(with: results)
        print(query)
        // perform search
//        APICaller.shared.search
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCollectionViewCell.identifier, for: indexPath) as?
                GenreCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: "Rock")
        return cell
    }
}
