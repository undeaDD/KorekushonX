import UIKit

class GekauftManager {
    let formatter: DateFormatter = {
        let temp = DateFormatter()
        temp.dateFormat = Constants.Strings.dateFormat.locale
        return temp
    }()

    var filtered: [Book] = []
    let store = FilesStore<Book>(uniqueIdentifier: Constants.Keys.managerBooks.rawValue)
    let mangaStore = FilesStore<Manga>(uniqueIdentifier: Constants.Keys.managerMangas.rawValue)

    static let shared = GekauftManager()

    private init() {}

    func isFilterActive() -> Bool {
        return UserDefaults.standard.integer(forKey: Constants.Keys.booksFilter.rawValue) != 0
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

    func removeBook(_ book: Book) {
        try? self.store.delete(withId: book.id)
        UserDefaults.standard.set(true, forKey: Constants.Keys.mangaReload.rawValue)
        checkMangaForCompletion(book.mangaId)
    }

    func checkMangaForCompletion(_ id: UUID) {
        let tempStore = FilesStore<Manga>(uniqueIdentifier: Constants.Keys.managerMangas.rawValue)
        if var parent = tempStore.object(withId: id) {
            let children = FilesStore<Book>(uniqueIdentifier: Constants.Keys.managerBooks.rawValue).allObjects().filter { $0.mangaId == id }.reduce(into: Set<Int>()) { $0.insert($1.number) }
            parent.completed = children.count == parent.countAll
            try? tempStore.save(parent)
            UserDefaults.standard.set(true, forKey: Constants.Keys.mangaReload.rawValue)
        }
    }

    func getMangaCount(_ id: UUID, _ completion: @escaping (Int) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            completion(
                FilesStore<Book>(uniqueIdentifier: Constants.Keys.managerBooks.rawValue).allObjects().filter { $0.mangaId == id }
                .reduce(into: Set<Int>()) { $0.insert($1.number) }.count
            )
        }
    }

    func reloadIfNeccessary(_ tableView: UITableView? = nil, _ collectionView: UICollectionView? = nil, _ force: Bool = false) {
        filtered = store.allObjects()

        switch UserDefaults.standard.integer(forKey: Constants.Keys.booksFilter.rawValue) {
        case 1:
            filtered = filtered.filter { $0.date != 0 }
        case 2:
            filtered.sort { ($0.mangaId.uuidString, $0.date) >= ($1.mangaId.uuidString, $0.date) }
        case 3:
            filtered.sort { $0.price >= $1.price }
        case 4:
            filtered.sort { $0.price <= $1.price }
        default:
            filtered.sort { $0.date >= $1.date }
        }

        if let search = UserDefaults.standard.string(forKey: Constants.Keys.booksSearch.rawValue) {
            filtered = filtered.filter { $0.title?.lowercased().contains(search) ?? false || search.contains(String($0.number)) || $0.place.lowercased().contains(search) }
        }

        if force || UserDefaults.standard.bool(forKey: Constants.Keys.booksReload.rawValue) {
            UserDefaults.standard.set(false, forKey: Constants.Keys.booksReload.rawValue)
            if let tableView = tableView {
                UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { tableView.reloadData() })
            } else if let collectionView = collectionView {
                UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: { collectionView.reloadData() })
            }
        }
    }
}
