import UIKit

class GekauftView: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var filterButton: UIBarButtonItem!

    let searchController = UISearchController(searchResultsController: nil)
    let manager = GekauftManager.shared

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
        searchController.searchBar.placeholder = Constants.Strings.search.locale
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
            AlertManager.shared.optionMinimal(self, true) { index in
                switch index {
                case 0:
                    self.performSegue(withIdentifier: Constants.Segues.edit.rawValue, sender: manga)
                case 1:
                    self.manager.removeBook(manga)
                    self.manager.reloadIfNeccessary(self.tableView, nil, true)
                default:
                    return
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.edit.rawValue, let dest = segue.destination as? GekauftAddView, let book = sender as? Book {
            dest.editBook = book
        } else if segue.identifier == Constants.Segues.detail.rawValue, let dest = segue.destination as? SammlungDetailView {
            if let indexPath = sender as? IndexPath {
                let manga = manager.mangaStore.object(withId: manager.filtered[indexPath.row].mangaId)
                dest.manga = manga
            } else {
                dest.manga = (sender as! Manga)
            }
        } else if segue.identifier == Constants.Segues.settings.rawValue, let nav = segue.destination as? NavigationController {
            nav.presentationController?.delegate = self
        }
    }

    @IBAction private func filterSammlung() {
        AlertManager.shared.filterGekaufte(self) {
            self.manager.reloadIfNeccessary(self.tableView, nil, true)
            self.filterButton.image = self.manager.getFilterImage()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.reloadIfNeccessary(tableView)
        self.navigationItem.rightBarButtonItem?.isEnabled = GekauftManager.shared.mangaStore.objectsCount > 0
    }
}

extension GekauftView: UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIAdaptivePresentationControllerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 60 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 13, *) {
            return searchController.isActive ? 18 : 0
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterButton.isEnabled = manager.enableButtons()
        navigationItem.rightBarButtonItems?.last?.isEnabled = manager.enableButtons()
        navigationController?.tabBarItem.badgeValue = String(manager.rawCount())
        return manager.filtered.count
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: Constants.Strings.edit.locale) { _, _, completion in
            self.performSegue(withIdentifier: Constants.Segues.edit.rawValue, sender: self.manager.filtered[indexPath.row])
            completion(true)
        }
        edit.image = UIImage(named: Constants.Images.edit.rawValue)
        edit.backgroundColor = .systemPurple
        return UISwipeActionsConfiguration(actions: [edit])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .destructive, title: Constants.Strings.trash.locale) { _, _, completion in
            self.manager.removeBook(self.manager.filtered[indexPath.row])
            self.manager.reloadIfNeccessary(self.tableView, nil, true)
            completion(true)
        }
        remove.image = UIImage(named: Constants.Images.trash.rawValue)
        remove.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [remove])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: GekauftCell.reuseIdentifier) as! GekauftCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let book = manager.filtered[indexPath.row]
        let date: String? = book.date == 0 ? nil : manager.formatter.string(from: Date(timeIntervalSince1970: book.date))
        (cell as! GekauftCell).setUp(book, date)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Segues.detail.rawValue, sender: indexPath)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }

    func updateSearchResults(for searchController: UISearchController) {
        navigationController?.navigationBar.prefersLargeTitles = !self.searchController.isActive
        if searchController.isActive, let text = searchController.searchBar.text, !text.isEmpty {
            UserDefaults.standard.set(text.lowercased(), forKey: Constants.Keys.booksSearch.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.Keys.booksSearch.rawValue)
        }
        manager.reloadIfNeccessary(tableView, nil, true)
    }
}
