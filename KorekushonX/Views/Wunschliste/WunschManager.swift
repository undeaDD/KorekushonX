import UIKit

class WunschManager {
    let store = FilesStore<Wunsch>(uniqueIdentifier: Constants.Keys.managerWishes.rawValue)
    static let shared = WunschManager()
    var list: [Wunsch] = []

    private init() {}

    func rawCount() -> Int {
        return store.objectsCount
    }

    func shareManga(_ wunsch: Wunsch, _ viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [wunsch.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)!, wunsch.title], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }

    func removeManga(_ wunsch: Wunsch) {
        try? self.store.delete(withId: wunsch.id)
        UserDefaults.standard.set(true, forKey: Constants.Keys.wishesReload.rawValue)
    }

    func reloadIfNeccessary(_ collectionView: UICollectionView, _ force: Bool = false) {
        list = store.allObjects()
        if force || UserDefaults.standard.bool(forKey: Constants.Keys.wishesReload.rawValue) {
            UserDefaults.standard.set(false, forKey: Constants.Keys.wishesReload.rawValue)
            UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: { collectionView.reloadData() })
        }
    }
}
