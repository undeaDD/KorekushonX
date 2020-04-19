import UIKit

class WunschView: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    let screenSize = (UIScreen.main.bounds.width - 40) / 2.0
    let manager = WunschManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        manager.reloadIfNeccessary(collectionView, true)
        if #available(iOS 13, *) {} else {
            collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
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
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let wunsch = manager.list[indexPath.row]
        sheet.addAction(UIAlertAction(title: "Teilen", style: .default, handler: { _ in
            self.manager.shareManga(wunsch, self)
        }))
        sheet.addAction(UIAlertAction(title: "Bearbeiten", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "edit", sender: wunsch)
        }))
        sheet.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: { _ in
            self.manager.removeManga(wunsch)
            self.manager.reloadIfNeccessary(self.collectionView, true)
        }))
        sheet.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        present(sheet, animated: true)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.viewWillAppear(false)
    }

    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let wunsch = manager.list[indexPath.row]
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil, actionProvider: { _ in
            let share = UIAction(title: "Teilen", image: UIImage(named: "teilen")) { _ in
                self.manager.shareManga(wunsch, self)
            }

            let edit = UIAction(title: "Bearbeiten", image: UIImage(named: "editieren")) { _ in
                self.performSegue(withIdentifier: "edit", sender: wunsch)
            }

            let remove = UIAction(title: "Löschen", image: UIImage(named: "müll"), attributes: .destructive) { _ in
                self.manager.removeManga(wunsch)
                self.manager.reloadIfNeccessary(self.collectionView, true)
            }

            return UIMenu(title: "", children: [share, edit, remove])
        })
    }
}
