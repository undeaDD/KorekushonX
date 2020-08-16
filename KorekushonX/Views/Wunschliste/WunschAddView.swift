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

         try? manager.store.save(temp)
         UserDefaults.standard.set(true, forKey: "WunschNeedsUpdating")

         if keepOpen {
            AlertManager.shared.savedInfo(self, "Reihe")
         } else {
             self.navigationController?.popToRootViewController(animated: true)
         }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            AlertManager.shared.selectImage(self) { index in
                switch index {
                case 0:
                    AlertManager.shared.manualImageSearch(self) { text in
                        self.image.image = WebImage.apiImage(text)
                    }
                case 1:
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true)
                case 2:
                    self.imagePicker.sourceType = .camera
                    self.present(self.imagePicker, animated: true)
                default:
                    self.image.image = UIImage(named: "default")
                }
            }
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
