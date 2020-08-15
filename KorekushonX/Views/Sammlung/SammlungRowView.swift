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

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Suchen"
        navigationItem.searchController = searchController

        filterButton.image = manager.getFilterImage()
        manager.reloadIfNeccessary(tableView, nil, true)
        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
            registerForPreviewing(with: self, sourceView: tableView)
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
        manager.reloadIfNeccessary(tableView)
    }

    @IBAction private func filterSammlung() {
        let sheet = UIAlertController(title: "Sammlung filtern", message: nil, preferredStyle: .actionSheet)

        for elem in ["Nicht Filtern", "Nach Titel A-Z", "Nach Autor A-Z", "Nach Verlag A-Z", "Nur Vollständige", "Nur nicht Vollständige"].enumerated() {
            let temp = UIAlertAction(title: elem.element, style: elem.offset == 0 ? .cancel : .default, handler: { _ in
                UserDefaults.standard.set(elem.offset, forKey: "SammlungFilter")
                self.manager.reloadIfNeccessary(self.tableView, nil, true)
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

extension SammlungRowView: UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UIAdaptivePresentationControllerDelegate, UIViewControllerPreviewingDelegate {
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
        let edit = UIContextualAction(style: .normal, title: "Bearbeiten") { _, _, completion in
            self.performSegue(withIdentifier: "edit", sender: self.manager.filtered[indexPath.row])
            completion(true)
        }
        edit.image = UIImage(named: "editieren")
        edit.backgroundColor = .systemPurple
        return UISwipeActionsConfiguration(actions: [edit])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = UIContextualAction(style: .normal, title: "Teilen") { _, _, completion in
            self.manager.shareManga(self.manager.filtered[indexPath.row], self)
            completion(true)
        }
        share.image = UIImage(named: "teilen")
        share.backgroundColor = .systemPurple

        let remove = UIContextualAction(style: .destructive, title: "Löschen") { _, _, completion in
            self.manager.removeManga(self.manager.filtered[indexPath.row])
            self.manager.reloadIfNeccessary(self.tableView, nil, true)
            completion(true)
        }
        remove.image = UIImage(named: "müll")
        remove.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [remove, share])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "sammlungCell") as! RowCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! RowCell).setUp(manager.filtered[indexPath.row], books)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: manager.filtered[indexPath.row])
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }

    func updateSearchResults(for searchController: UISearchController) {
        navigationController?.navigationBar.prefersLargeTitles = !self.searchController.isActive
        if searchController.isActive, let text = searchController.searchBar.text, !text.isEmpty {
            UserDefaults.standard.set(text.lowercased(), forKey: "SammlungSearch")
        } else {
            UserDefaults.standard.removeObject(forKey: "SammlungSearch")
        }
        manager.reloadIfNeccessary(tableView, nil, true)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            let dest = storyboard?.instantiateViewController(withIdentifier: "detailView") as! SammlungDetailView
            dest.manga = manager.filtered[indexPath.row]
            dest.editAction = {
                self.performSegue(withIdentifier: "edit", sender: dest.manga!)
            }
            dest.shareAction = {
                self.manager.shareManga(dest.manga!, self)
            }
            dest.removeAction = {
                self.manager.removeManga(dest.manga!)
                self.manager.reloadIfNeccessary(self.tableView, nil, true)
            }
            return dest
        }

        return nil
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let manga = self.manager.filtered[indexPath.row]
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil, actionProvider: { _ in
            let share = UIAction(title: "Teilen", image: UIImage(named: "teilen")) { _ in
                self.manager.shareManga(manga, self)
            }

            let edit = UIAction(title: "Bearbeiten", image: UIImage(named: "editieren")) { _ in
                self.performSegue(withIdentifier: "edit", sender: manga)
            }

            let remove = UIAction(title: "Löschen", image: UIImage(named: "müll"), attributes: .destructive) { _ in
                self.manager.removeManga(manga)
                self.manager.reloadIfNeccessary(self.tableView, nil, true)
            }

            return UIMenu(title: "", children: [share, edit, remove])
        })
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            let dest = self.storyboard?.instantiateViewController(withIdentifier: "detailView") as! SammlungDetailView
            dest.manga = self.manager.filtered[(configuration.identifier as! IndexPath).row]
            self.show(dest, sender: self)
        }
    }
}
