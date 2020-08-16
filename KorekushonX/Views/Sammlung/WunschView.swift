import UIKit

class WunschView: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    let screenSize = (UIScreen.main.bounds.width - 40) / 2.0
    let manager = WunschManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gesture.minimumPressDuration = 0.5
        gesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(gesture)

        manager.reloadIfNeccessary(collectionView, true)
        if #available(iOS 13, *) {} else {
            collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        }
    }

    @objc
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began { return }
        let loc = gesture.location(in: collectionView)

        if let indexPath = collectionView.indexPathForItem(at: loc) {
            let manga = self.manager.list[indexPath.row]
            AlertManager.shared.options(self) { index in
                switch index {
                case 0:
                    self.manager.shareManga(manga, self)
                case 1:
                    self.performSegue(withIdentifier: "edit", sender: manga)
                default:
                    self.manager.removeManga(manga)
                    self.manager.reloadIfNeccessary(self.collectionView, true)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings", let nav = segue.destination as? NavigationController {
            nav.presentationController?.delegate = self
        } else if segue.identifier == "edit", let dest = segue.destination as? WunschAddView, let wunsch = sender as? Wunsch {
            dest.editWunsch = wunsch
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.reloadIfNeccessary(collectionView)
    }
}

extension WunschView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIAdaptivePresentationControllerDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 36, right: 15)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        navigationController?.tabBarItem.badgeValue = String(manager.rawCount())
        return manager.list.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenSize, height: screenSize * 1.5 + 30)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "wunschCell", for: indexPath) as! WunschCell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! WunschCell).setUp(manager.list[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wunsch = manager.list[indexPath.row]
        AlertManager.shared.options(self) { index in
            switch index {
            case 0:
                self.manager.shareManga(wunsch, self)
            case 1:
                self.performSegue(withIdentifier: "edit", sender: wunsch)
            default:
                self.manager.removeManga(wunsch)
                self.manager.reloadIfNeccessary(self.collectionView, true)
            }
        }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }
}
