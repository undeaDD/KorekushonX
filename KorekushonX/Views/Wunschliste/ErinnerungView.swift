import UIKit

class ErinnerungView: UIViewController {
    @IBOutlet private var tableView: UITableView!
    let manager = ErinnerungManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gesture.minimumPressDuration = 0.5
        gesture.delaysTouchesBegan = true
        tableView.addGestureRecognizer(gesture)

        manager.reloadIfNeccessary(tableView, true)
        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }

    @objc
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began { return }
        let loc = gesture.location(in: tableView)

        if let indexPath = tableView.indexPathForRow(at: loc) {
            AlertManager.shared.optionMinimal(self) { _ in
                self.manager.removeErinnerung(self.manager.list[indexPath.row])
                self.manager.reloadIfNeccessary(self.tableView, true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.reloadIfNeccessary(tableView)

        let enabled = UserDefaults.standard.bool(forKey: Constants.Keys.reminderActive.rawValue)
        self.navigationItem.rightBarButtonItem?.isEnabled = enabled
        if !enabled {
            AlertManager.shared.notificationError(self)
            self.tabBarController?.selectedIndex = 0
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.settings.rawValue, let nav = segue.destination as? NavigationController {
            nav.presentationController?.delegate = self
        }
    }
}

extension ErinnerungView: UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 70 }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 70 }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 0 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        navigationController?.tabBarItem.badgeValue = String(manager.rawCount())
        return manager.list.count
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .destructive, title: Constants.Keys.trash.locale) { _, _, completion in
            self.manager.removeErinnerung(self.manager.list[indexPath.row])
            self.manager.reloadIfNeccessary(self.tableView, true)
            completion(true)
        }
        remove.image = UIImage(named: Constants.Images.trash.rawValue)
        remove.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [remove])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: Constants.Keys.remindCell.rawValue) as! ErinnerungCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let erinnerung = manager.list[indexPath.row]
        let date = manager.formatter.string(from: Date(timeIntervalSince1970: erinnerung.date))
        (cell as! ErinnerungCell).setUp(erinnerung, date)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AlertManager.shared.optionMinimal(self) { _ in
            self.manager.removeErinnerung(self.manager.list[indexPath.row])
            self.manager.reloadIfNeccessary(self.tableView, true)
        }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }
}
