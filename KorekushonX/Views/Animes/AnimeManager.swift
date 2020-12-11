import UIKit

class AnimeManager {
    var filtered: [Anime] = []
    let store = FilesStore<Anime>(uniqueIdentifier: Constants.Keys.managerAnime.rawValue)

    let formatter: DateFormatter = {
        let temp = DateFormatter()
        temp.dateStyle = .medium
        temp.timeStyle = .none
        temp.locale = NSLocale.current
        return temp
    }()

    static let shared = AnimeManager()

    private init() {}

    func isFilterActive() -> Bool {
        return UserDefaults.standard.integer(forKey: Constants.Keys.animeFilter.rawValue) != 0
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

    func shareAnime(_ anime: Anime, _ viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [anime.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)!, anime.title], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }

    func removeAnime(_ anime: Anime) {
        try? self.store.delete(withId: anime.id)
        UserDefaults.standard.set(true, forKey: Constants.Keys.animeReload.rawValue)
    }

    func updateAnime(_ anime: Anime, _ op: ((Int, Int) -> Int)? = nil, _ category: Int?) {
        var anime = anime
        if let category = category {
            anime.category = category
        } else if let op = op {
            anime.episode = op(anime.episode, 1)
        }
        try? store.save(anime)
        UserDefaults.standard.set(true, forKey: Constants.Keys.animeReload.rawValue)
    }

    func reloadIfNeccessary(_ tableView: UITableView? = nil, _ collectionView: UICollectionView? = nil, _ force: Bool = false) {
        filtered = store.allObjects()

        switch UserDefaults.standard.integer(forKey: Constants.Keys.animeFilter.rawValue) {
        case 1:
            filtered = filtered.filter { $0.category == 0 }
        case 2:
            filtered = filtered.filter { $0.category == 1 }
        case 3:
            filtered = filtered.filter { $0.category == 2 }
        default:
            break
        }

        filtered.sort { $0.title.lowercased() < $1.title.lowercased() }
        if let search = UserDefaults.standard.string(forKey: Constants.Keys.animeSearch.rawValue) {
            filtered = filtered.filter { $0.title.lowercased().contains(search) }
        }

        if force || UserDefaults.standard.bool(forKey: Constants.Keys.animeReload.rawValue) {
            UserDefaults.standard.set(false, forKey: Constants.Keys.animeReload.rawValue)
            if let tableView = tableView {
                UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { tableView.reloadData() })
            } else if let collectionView = collectionView {
                UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: { collectionView.reloadData() })
            }
        }
    }

    func repairAll(_ completion: () -> Void) {
        for var parent in store.allObjects() {
            if let img = parent.cover?.img(), img != UIImage(named: Constants.Images.default.rawValue), let color = img.averageColor {
                parent.coverColor = CoverColor(color: color)
            }

            try? store.save(parent)
        }

        UserDefaults.standard.set(true, forKey: Constants.Keys.animeReload.rawValue)
        completion()
    }
}
