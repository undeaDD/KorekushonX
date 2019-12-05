import UIKit

class WunschManager {
    let store = FilesStore<Wunsch>(uniqueIdentifier: "wishes")
    static let shared = WunschManager()
    var list: [Wunsch] = []

    private init() {}

    func rawCount() -> Int {
        return store.objectsCount
    }

    func shareManga(_ wunsch: Wunsch, _ viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [wunsch.cover.img()], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }

    func removeManga(_ wunsch: Wunsch) {
        try? self.store.delete(withId: wunsch.id)
        UserDefaults.standard.set(true, forKey: "WunschNeedsUpdating")
    }

    func reloadIfNeccessary(_ collectionView: UICollectionView, _ force: Bool = false) {
        list = store.allObjects()
        if force || UserDefaults.standard.bool(forKey: "WunschNeedsUpdating") {
            UserDefaults.standard.set(false, forKey: "WunschNeedsUpdating")
            UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve, animations: { collectionView.reloadData() })
        }
    }
}
