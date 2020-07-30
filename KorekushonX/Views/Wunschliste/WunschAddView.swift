import UIKit

class WunschAddView: UITableViewController {
    @IBOutlet private var titleField: UITextField!
    @IBOutlet private var image: UIImageView!
    var editWunsch: Wunsch?

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

        if let wunsch = editWunsch {
            navigationItem.title = "Bearbeiten"
            titleField.text = wunsch.title
            image.image = wunsch.cover?.img() ?? UIImage(named: "default")
        }

        imagePicker.delegate = self
        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }

    @IBAction private func save2() {
        save(true)
    }

    @IBAction private func save(_ keepOpen: Bool = false) {
        self.view.endEditing(true)

        let img = image.image == UIImage(named: "default") ? nil : image.image?.cover()
        let temp = Wunsch(id: editWunsch != nil ? editWunsch!.id : UUID(),
                      title: titleField.text.trim(),
                       cover: img)

         try! manager.store.save(temp)
         UserDefaults.standard.set(true, forKey: "WunschNeedsUpdating")

         if keepOpen {
             let alert = UIAlertController(title: "Gespeichert", message: "Manga wurde erfolgreich gespeichert", preferredStyle: .alert)
             self.present(alert, animated: true) {
                 DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
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

extension WunschAddView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.image.image = UIImage(named: "default")
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.image.image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true)
    }
}
