import UIKit

class ContactsManager {
    var filtered: [Contact] = []
    let store = FilesStore<Contact>(uniqueIdentifier: Constants.Keys.managerContacts.rawValue)

    static let shared = ContactsManager()
    private init() {}

    func rawCount() -> Int {
        return store.objectsCount
    }

    func shareContact(_ contact: Contact, _ viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [contact], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }

    func removeContact(_ contact: Contact) {
        try? self.store.delete(withId: contact.id)
        UserDefaults.standard.set(true, forKey: Constants.Keys.contactReload.rawValue)
    }

    func updateAnime(_ contact: Contact) {
        try? store.save(contact)
        UserDefaults.standard.set(true, forKey: Constants.Keys.contactReload.rawValue)
    }

    func reloadIfNeccessary(_ tableView: UITableView? = nil, _ collectionView: UICollectionView? = nil, _ force: Bool = false) {
        filtered = store.allObjects()

        filtered.sort { $0.name.lowercased() < $1.name.lowercased() }
        if let search = UserDefaults.standard.string(forKey: Constants.Keys.contactSearch.rawValue) {
            filtered = filtered.filter { $0.name.lowercased().contains(search) }
        }

        if force || UserDefaults.standard.bool(forKey: Constants.Keys.contactReload.rawValue) {
            UserDefaults.standard.set(false, forKey: Constants.Keys.contactReload.rawValue)
            if let tableView = tableView {
                UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { tableView.reloadData() })
            } else if let collectionView = collectionView {
                UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: { collectionView.reloadData() })
            }
        }
    }

    func repairAll(_ completion: () -> Void) {
        UserDefaults.standard.set(true, forKey: Constants.Keys.contactReload.rawValue)
        completion()
    }
}
