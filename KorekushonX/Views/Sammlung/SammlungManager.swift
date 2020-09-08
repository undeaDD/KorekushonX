import UIKit

class SammlungManager {
    var filtered: [Manga] = []
    let store = FilesStore<Manga>(uniqueIdentifier: Constants.Keys.managerMangas.rawValue)

    let formatter: DateFormatter = {
        let temp = DateFormatter()
        temp.dateStyle = .medium
        temp.timeStyle = .none
        temp.locale = NSLocale.current
        return temp
    }()

    static let shared = SammlungManager()

    private init() {}

    func isFilterActive() -> Bool {
        return UserDefaults.standard.integer(forKey: Constants.Keys.mangaFilter.rawValue) != 0
    }

    func getFilterImage() -> UIImage? {
        return UIImage(named: isFilterActive() ? Constants.Images.filterOn.rawValue : Constants.Images.filterOff.rawValue)
    }

    func rawCount() -> Int {
        return store.objectsCount
    }

    func enableButtons() -> Bool {
        return rawCount() > 0
    }

    func shareManga(_ manga: Manga, _ viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [manga.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)!, manga.title], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }

    func removeManga(_ manga: Manga) {
        let tempStore = FilesStore<Book>(uniqueIdentifier: Constants.Keys.managerBooks.rawValue).allObjects().filter { $0.mangaId == manga.id }.map { $0.id }
        try? FilesStore<Book>(uniqueIdentifier: Constants.Keys.managerBooks.rawValue).delete(withIds: tempStore)
        try? self.store.delete(withId: manga.id)
        UserDefaults.standard.set(true, forKey: Constants.Keys.booksReload.rawValue)
    }

    func reloadIfNeccessary(_ tableView: UITableView? = nil, _ collectionView: UICollectionView? = nil, _ force: Bool = false) {
        filtered = store.allObjects()

        switch UserDefaults.standard.integer(forKey: Constants.Keys.mangaFilter.rawValue) {
        case 1:
            filtered.sort { $0.title.lowercased() < $1.title.lowercased() }
        case 2:
            filtered.sort { $0.author.lowercased() < $1.author.lowercased() }
        case 3:
            filtered.sort { $0.publisher.lowercased() < $1.publisher.lowercased() }
        case 4:
            filtered = filtered.filter { $0.completed }
        case 5:
            filtered = filtered.filter { !$0.completed }
        default:
            break
        }

        if let search = UserDefaults.standard.string(forKey: Constants.Keys.mangaSearch.rawValue) {
            filtered = filtered.filter { $0.title.lowercased().contains(search) || $0.author.lowercased().contains(search) || $0.publisher.lowercased().contains(search) }
        }

        if force || UserDefaults.standard.bool(forKey: Constants.Keys.mangaReload.rawValue) {
            UserDefaults.standard.set(false, forKey: Constants.Keys.mangaReload.rawValue)
            if let tableView = tableView {
                UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { tableView.reloadData() })
            } else if let collectionView = collectionView {
                UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: { collectionView.reloadData() })
            }
        }
    }

    func repairAll(_ completion: () -> Void) {
        for var parent in store.allObjects() {
            let children: Set<Int> = FilesStore<Book>(uniqueIdentifier: Constants.Keys.managerBooks.rawValue).allObjects().filter { $0.mangaId == parent.id }.reduce(into: Set<Int>()) { $0.insert($1.number) }
            parent.completed = children.count == parent.countAll

            if let img = parent.cover?.img(), img != UIImage(named: Constants.Images.default.rawValue), let color = img.averageColor {
                parent.coverColor = CoverColor(color: color)
            }

            try? store.save(parent)
        }

        UserDefaults.standard.set(true, forKey: Constants.Keys.mangaReload.rawValue)
        completion()
    }
}
