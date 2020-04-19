import UIKit

class GekauftManager {
    let formatter: DateFormatter = {
        let temp = DateFormatter()
        temp.dateFormat = "dd.MM.yy"
        return temp
    }()

    var filtered: [Book] = []
    let store = FilesStore<Book>(uniqueIdentifier: "books")
    let mangaStore = FilesStore<Manga>(uniqueIdentifier: "mangas")

    static let shared = GekauftManager()

    private init() {}

    func isFilterActive() -> Bool {
        return UserDefaults.standard.integer(forKey: "GekauftFilter") != 0
    }

    func getFilterImage() -> UIImage? {
        return UIImage(named: isFilterActive() ? "filterOn" : "filterOff")
    }

    func rawCount() -> Int {
        return store.objectsCount
    }

    func enableButtons() -> Bool {
        return rawCount() > 0
    }

    func removeBook(_ book: Book) {
        try? self.store.delete(withId: book.id)
        UserDefaults.standard.set(true, forKey: "SammlungNeedsUpdating")
        checkMangaForCompletion(book.mangaId)
    }

    func checkMangaForCompletion(_ id: UUID) {
        let tempStore = FilesStore<Manga>(uniqueIdentifier: "mangas")
        if var parent = tempStore.object(withId: id) {
            let children = FilesStore<Book>(uniqueIdentifier: "books").allObjects().filter { $0.mangaId == id }.reduce(into: Set<Int>()) { $0.insert($1.number) }
            parent.completed = children.count == parent.countAll
            try? tempStore.save(parent)
            UserDefaults.standard.set(true, forKey: "SammlungNeedsUpdating")
        }
    }

    func getMangaCount(_ id: UUID, _ completion: @escaping (Int) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            completion(
                FilesStore<Book>(uniqueIdentifier: "books").allObjects().filter { $0.mangaId == id }
                .reduce(into: Set<Int>()) { $0.insert($1.number) }.count
            )
        }
    }

    func reloadIfNeccessary(_ tableView: UITableView, _ force: Bool = false) {
        filtered = store.allObjects()

        switch UserDefaults.standard.integer(forKey: "GekauftFilter") {
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

        if let search = UserDefaults.standard.string(forKey: "GekauftSearch") {
            filtered = filtered.filter { $0.title?.lowercased().contains(search) ?? false || search.contains(String($0.number)) || $0.place.lowercased().contains(search) }
        }

        if force || UserDefaults.standard.bool(forKey: "BooksNeedsUpdating") {
            UserDefaults.standard.set(false, forKey: "BooksNeedsUpdating")
            UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { tableView.reloadData() })
        }
    }
}
