import UIKit

class AnimeManager {
    var filtered: [Anime] = []
    let store = FilesStore<Anime>(uniqueIdentifier: Constants.Keys.managerAnime.rawValue)

    let formatter: DateFormatter = {
        let temp = DateFormatter()
        temp.dateFormat = Constants.Keys.dateFormat.locale
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

    func reloadIfNeccessary(_ tableView: UITableView? = nil, _ collectionView: UICollectionView? = nil, _ force: Bool = false) {
        filtered = store.allObjects()

        switch UserDefaults.standard.integer(forKey: Constants.Keys.animeFilter.rawValue) {
        case 1:
            filtered = filtered.filter { $0.category == 1 }
        case 2:
            filtered = filtered.filter { $0.category == 2 }
        case 3:
            filtered = filtered.filter { $0.category == 3 }
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
}
