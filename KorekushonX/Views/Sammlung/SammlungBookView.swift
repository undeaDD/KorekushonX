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
        searchController.searchBar.placeholder = "Suchen"
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
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Sammlung Teilen", style: .default, handler: { _ in
                self.manager.shareManga(manga, self)
            }))

            alert.addAction(UIAlertAction(title: "Sammlung Bearbeiten", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "edit", sender: manga)
            }))

            alert.addAction(UIAlertAction(title: "Sammlung Löschen", style: .destructive, handler: { _ in
                self.manager.removeManga(manga)
                self.manager.reloadIfNeccessary(nil, self.collectionView, true)
            }))

            alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit", let dest = segue.destination as? SammlungAddView, let manga = sender as? Manga {
            dest.editManga = manga
        } else if segue.identifier == "detail", let dest = segue.destination as? SammlungDetailView, let manga = sender as? Manga {
            dest.manga = manga
        } else if segue.identifier == "settings", let nav = segue.destination as? NavigationController {
            nav.presentationController?.delegate = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.reloadIfNeccessary(nil, collectionView)
    }

    @IBAction private func filterSammlung() {
        let sheet = UIAlertController(title: "Sammlung filtern", message: nil, preferredStyle: .actionSheet)

        for elem in ["Nicht Filtern", "Nach Titel A-Z", "Nach Autor A-Z", "Nach Verlag A-Z", "Nur Vollständige", "Nur nicht Vollständige"].enumerated() {
            let temp = UIAlertAction(title: elem.element, style: elem.offset == 0 ? .cancel : .default, handler: { _ in
                UserDefaults.standard.set(elem.offset, forKey: "SammlungFilter")
                self.manager.reloadIfNeccessary(nil, self.collectionView, true)
                self.filterButton.image = self.manager.getFilterImage()
            })
            if elem.offset != 0 {
                temp.setValue(UserDefaults.standard.integer(forKey: "SammlungFilter") == elem.offset, forKey: "checked")
            }
            sheet.addAction(temp)
        }

        sheet.view.tintColor = .systemPurple
        self.present(sheet, animated: true)
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
        collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath)
    }

    func updateSearchResults(for searchController: UISearchController) {
        collectionView.contentInset.top = self.searchController.isActive ? 20 : 0
        navigationController?.navigationBar.prefersLargeTitles = !self.searchController.isActive
        if searchController.isActive, let text = searchController.searchBar.text, !text.isEmpty {
            UserDefaults.standard.set(text.lowercased(), forKey: "SammlungSearch")
        } else {
            UserDefaults.standard.removeObject(forKey: "SammlungSearch")
        }
        manager.reloadIfNeccessary(nil, collectionView, true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 90, height: collectionView.frame.height - 40)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! BookCell).setUp(manager.filtered[indexPath.row], books)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: manager.filtered[indexPath.row])
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }
}
