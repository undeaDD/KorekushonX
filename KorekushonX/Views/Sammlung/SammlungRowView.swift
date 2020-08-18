import UIKit

class SammlungRowView: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var filterButton: UIBarButtonItem!

    let searchController = UISearchController(searchResultsController: nil)
    let manager = SammlungManager.shared
    let books = GekauftManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gesture.minimumPressDuration = 0.5
        gesture.delaysTouchesBegan = true
        tableView.addGestureRecognizer(gesture)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = Constants.Keys.search.locale
        navigationItem.searchController = searchController

        filterButton.image = manager.getFilterImage()
        manager.reloadIfNeccessary(tableView, nil, true)
        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }

    @objc
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began { return }
        let loc = gesture.location(in: tableView)

        if let indexPath = tableView.indexPathForRow(at: loc) {
            let manga = self.manager.filtered[indexPath.row]
            AlertManager.shared.options(self) { index in
                switch index {
                case 0:
                    self.manager.shareManga(manga, self)
                case 1:
                    self.performSegue(withIdentifier: Constants.Segues.edit.rawValue, sender: manga)
                default:
                    self.manager.removeManga(manga)
                    self.manager.reloadIfNeccessary(self.tableView, nil, true)
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
        manager.reloadIfNeccessary(tableView)
    }

    @IBAction private func filterSammlung() {
        AlertManager.shared.filterSammlung(self) {
            self.manager.reloadIfNeccessary(self.tableView, nil, true)
            self.filterButton.image = self.manager.getFilterImage()
        }
    }
}

extension SammlungRowView: UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIAdaptivePresentationControllerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 70 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 70 }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 13, *) {
            return searchController.isActive ? 18 : 0
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterButton.isEnabled = manager.enableButtons()
        navigationController?.tabBarItem.badgeValue = String(manager.rawCount())
        return manager.filtered.count
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: Constants.Keys.edit.locale) { _, _, completion in
            self.performSegue(withIdentifier: Constants.Segues.edit.rawValue, sender: self.manager.filtered[indexPath.row])
            completion(true)
        }
        edit.image = UIImage(named: Constants.Images.edit.rawValue)
        edit.backgroundColor = .systemPurple
        return UISwipeActionsConfiguration(actions: [edit])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = UIContextualAction(style: .normal, title: Constants.Keys.share.locale) { _, _, completion in
            self.manager.shareManga(self.manager.filtered[indexPath.row], self)
            completion(true)
        }
        share.image = UIImage(named: Constants.Images.share.rawValue)
        share.backgroundColor = .systemPurple

        let remove = UIContextualAction(style: .destructive, title: Constants.Keys.trash.locale) { _, _, completion in
            self.manager.removeManga(self.manager.filtered[indexPath.row])
            self.manager.reloadIfNeccessary(self.tableView, nil, true)
            completion(true)
        }
        remove.image = UIImage(named: Constants.Images.trash.rawValue)
        remove.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [remove, share])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: RowCell.reuseIdentifier) as! RowCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! RowCell).setUp(manager.filtered[indexPath.row], books)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Segues.detail.rawValue, sender: manager.filtered[indexPath.row])
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }

    func updateSearchResults(for searchController: UISearchController) {
        navigationController?.navigationBar.prefersLargeTitles = !self.searchController.isActive
        if searchController.isActive, let text = searchController.searchBar.text, !text.isEmpty {
            UserDefaults.standard.set(text.lowercased(), forKey: Constants.Keys.mangaSearch.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Keys.mangaSearch.rawValue)
        }
        manager.reloadIfNeccessary(tableView, nil, true)
    }
}
