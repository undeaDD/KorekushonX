import UIKit

class WunschAddView: UITableViewController {
    @IBOutlet private var titleField: UITextField!
    @IBOutlet private var image: UIImageView!

    let manager = WunschManager.shared
    let imagePicker: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        return pickerController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }

    @IBAction private func save2() {
        save(true)
    }

    @IBAction private func save(_ keepOpen: Bool = false) {
        self.view.endEditing(true)

        let temp = Wunsch(id: UUID(),
                      title: titleField.text.trim(),
                       cover: image.image?.cover() ?? UIImage(named: "default")!.cover())

         try! manager.store.save(temp)
         UserDefaults.standard.set(true, forKey: "WunschNeedsUpdating")

         if keepOpen {
             let alert = UIAlertController(title: "Gespeichert", message: "Manga wurde erfolgreich gespeichert", preferredStyle: .alert)
             self.present(alert, animated: true) {
                 DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
                     alert.dismiss(animated: true)
                 }
             }
         } else {
             self.navigationController?.popToRootViewController(animated: true)
         }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            sheet.addAction(UIAlertAction(title: "Automatisch (via API)", style: .default, handler: { _ in
                let alertController = UIAlertController(title: "Suchbegriff", message: "Nach dem Bild suchen\n(Manga Titel)", preferredStyle: .alert)
                alertController.addTextField { textField in textField.placeholder = "Kiss of the Fox" }
                alertController.addAction(UIAlertAction(title: "Suchen", style: .default) { [weak alertController] _ in
                    guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
                    self.image.image = WebImage.apiImage(textField.text.trim())
                })
                alertController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }))

            sheet.addAction(UIAlertAction(title: "Fotoalbum", style: .default, handler: { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true)
            }))

            sheet.addAction(UIAlertAction(title: "Kamera", style: .default, handler: { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true)
            }))

            sheet.addAction(UIAlertAction(title: "Kein Cover nutzen", style: .cancel, handler: { _ in
                self.image.image = UIImage(named: "default")
            }))

            self.present(sheet, animated: true)
        }
    }

}
