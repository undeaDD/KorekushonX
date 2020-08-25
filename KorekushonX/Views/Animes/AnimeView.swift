import UIKit

class AnimeView: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var filterButton: UIBarButtonItem!

    let searchController = UISearchController(searchResultsController: nil)
    let manager = AnimeManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 61.0) / 3.0, height: 200)
        collectionView.setCollectionViewLayout(layout, animated: false)

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gesture.minimumPressDuration = 0.5
        gesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(gesture)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = Constants.Strings.search.locale
        navigationItem.searchController = searchController

        filterButton.image = manager.getFilterImage()
        manager.reloadIfNeccessary(nil, collectionView, true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.tintColor = .systemOrange
        manager.reloadIfNeccessary(nil, collectionView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.tintColor = .systemPurple
    }

    @objc
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began { return }
        let loc = gesture.location(in: collectionView)

        if let indexPath = collectionView.indexPathForItem(at: loc) {
            let item = self.manager.filtered[indexPath.row]
            AlertManager.shared.options(self) { index in
                switch index {
                case 0:
                    self.manager.shareAnime(item, self)
                case 1:
                    self.performSegue(withIdentifier: Constants.Segues.edit.rawValue, sender: item)
                default:
                    self.manager.removeAnime(item)
                    self.manager.reloadIfNeccessary(nil, self.collectionView, true)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.edit.rawValue, let dest = segue.destination as? SammlungAddView, let manga = sender as? Manga {
            dest.editManga = manga
        } else if segue.identifier == Constants.Segues.detail.rawValue, let dest = segue.destination as? SammlungDetailView, let manga = sender as? Manga {
            dest.manga = manga
        } else if segue.identifier == Constants.Segues.settings.rawValue, let nav = segue.destination as? NavigationController {
            nav.presentationController?.delegate = self
        }
    }

    @IBAction private func filterSammlung() {
        AlertManager.shared.filterAnimes(self) {
            self.manager.reloadIfNeccessary(nil, self.collectionView, true)
            self.filterButton.image = self.manager.getFilterImage()
        }
    }
}

extension AnimeView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, UIAdaptivePresentationControllerDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterButton.isEnabled = manager.enableButtons()
        return manager.filtered.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimeCell.reuseIdentifier, for: indexPath) as! AnimeCell
        cell.setUp(manager.filtered[indexPath.row])
        return cell
    }

    func updateSearchResults(for searchController: UISearchController) {
        collectionView.contentInset.top = self.searchController.isActive ? 20 : 0
        navigationController?.navigationBar.prefersLargeTitles = !self.searchController.isActive
        if searchController.isActive, let text = searchController.searchBar.text, !text.isEmpty {
            UserDefaults.standard.set(text.lowercased(), forKey: Constants.Keys.animeSearch.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Keys.animeSearch.rawValue)
        }
        manager.reloadIfNeccessary(nil, collectionView, true)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Segues.detail.rawValue, sender: manager.filtered[indexPath.row])
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }
}
