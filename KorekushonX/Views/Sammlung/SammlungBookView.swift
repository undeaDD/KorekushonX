import UIKit

class SammlungBookView: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var filterButton: UIBarButtonItem!

    let searchController = UISearchController(searchResultsController: nil)
    let manager = SammlungManager.shared
    let books = GekauftManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

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

    @objc
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began { return }
        let loc = gesture.location(in: collectionView)

        if let indexPath = collectionView.indexPathForItem(at: loc) {
            let manga = self.manager.filtered[indexPath.row]
            AlertManager.shared.options(self) { index in
                switch index {
                case 0:
                    self.manager.shareManga(manga, self)
                case 1:
                    self.performSegue(withIdentifier: Constants.Segues.edit.rawValue, sender: manga)
                default:
                    self.manager.removeManga(manga)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.reloadIfNeccessary(nil, collectionView)
    }

    @IBAction private func filterSammlung() {
        AlertManager.shared.filterSammlung(self) {
            self.manager.reloadIfNeccessary(nil, self.collectionView, true)
            self.filterButton.image = self.manager.getFilterImage()
        }
    }
}

extension SammlungBookView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, UIAdaptivePresentationControllerDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filterButton.isEnabled = manager.enableButtons()
        navigationController?.tabBarItem.badgeValue = String(manager.rawCount())
        return manager.filtered.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.reuseIdentifier, for: indexPath)
    }

    func updateSearchResults(for searchController: UISearchController) {
        collectionView.contentInset.top = self.searchController.isActive ? 20 : 0
        navigationController?.navigationBar.prefersLargeTitles = !self.searchController.isActive
        if searchController.isActive, let text = searchController.searchBar.text, !text.isEmpty {
            UserDefaults.standard.set(text.lowercased(), forKey: Constants.Keys.mangaSearch.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Keys.mangaSearch.rawValue)
        }
        manager.reloadIfNeccessary(nil, collectionView, true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 110, height: collectionView.frame.height - 40)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! BookCell).setUp(manager.filtered[indexPath.row], books)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Segues.detail.rawValue, sender: manager.filtered[indexPath.row])
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }
}
