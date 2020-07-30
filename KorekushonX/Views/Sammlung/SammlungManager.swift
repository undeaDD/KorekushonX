import UIKit

class SammlungManager {
    var filtered: [Manga] = []
    let store = FilesStore<Manga>(uniqueIdentifier: "mangas")

    let formatter: DateFormatter = {
        let temp = DateFormatter()
        temp.dateFormat = "dd.MM.yy"
        return temp
    }()

    static let shared = SammlungManager()

    private init() {}

    func isFilterActive() -> Bool {
        return UserDefaults.standard.integer(forKey: "SammlungFilter") != 0
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

    func shareManga(_ manga: Manga, _ viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [manga.cover?.img() ?? UIImage(named: "default")!, manga.title], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }

    func removeManga(_ manga: Manga) {
        let tempStore = FilesStore<Book>(uniqueIdentifier: "books").allObjects().filter { $0.mangaId == manga.id }.map { $0.id }
        try? FilesStore<Book>(uniqueIdentifier: "books").delete(withIds: tempStore)
        try? self.store.delete(withId: manga.id)
        UserDefaults.standard.set(true, forKey: "BooksNeedsUpdating")
    }

    func reloadIfNeccessary(_ tableView: UITableView, _ force: Bool = false) {
        filtered = store.allObjects()

        switch UserDefaults.standard.integer(forKey: "SammlungFilter") {
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

        if let search = UserDefaults.standard.string(forKey: "SammlungSearch") {
            filtered = filtered.filter { $0.title.lowercased().contains(search) || $0.author.lowercased().contains(search) || $0.publisher.lowercased().contains(search) }
        }

        if force || UserDefaults.standard.bool(forKey: "SammlungNeedsUpdating") {
            UserDefaults.standard.set(false, forKey: "SammlungNeedsUpdating")
            UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { tableView.reloadData() })
        }
    }

    func repairAll() {
        for var parent in store.allObjects() {
            let children: Set<Int> = FilesStore<Book>(uniqueIdentifier: "books").allObjects().filter { $0.mangaId == parent.id }.reduce(into: Set<Int>()) { $0.insert($1.number) }
            parent.completed = children.count == parent.countAll
            try? store.save(parent)
        }
        UserDefaults.standard.set(true, forKey: "SammlungNeedsUpdating")
    }
}
