import UIKit

class WunschAddView: UITableViewController {
    @IBOutlet private var titleField: UITextField!
    @IBOutlet private var image: UIImageView!
    var editWunsch: Wunsch?

    let manager = WunschManager.shared
    let imagePicker: ImagePickerView = {
        let pickerController = ImagePickerView()
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        return pickerController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let wunsch = editWunsch {
            navigationItem.rightBarButtonItems?.removeFirst()
            navigationItem.title = Constants.Strings.edit.locale
            titleField.text = wunsch.title
            image.image = wunsch.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)
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

        let img = image.image == UIImage(named: Constants.Images.default.rawValue) ? nil : Cover(image: image!.image)
        let temp = Wunsch(id: editWunsch != nil ? editWunsch!.id : UUID(),
                      title: titleField.text.trim(),
                       cover: img)

         try? manager.store.save(temp)
        UserDefaults.standard.set(true, forKey: Constants.Keys.wishesReload.rawValue)

         if keepOpen {
            AlertManager.shared.savedInfo(self, Constants.Strings.reihe.locale)
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
                    self.image.image = UIImage(named: Constants.Images.default.rawValue)
                }
            }
        }
    }
}

extension WunschAddView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.image.image = UIImage(named: Constants.Images.default.rawValue)
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage, let cg = image.cgImage {
            if image.imageOrientation == .up {
                self.image.image = UIImage(cgImage: cg, scale: 1.0, orientation: .left)
            } else if image.imageOrientation == .down {
                self.image.image = UIImage(cgImage: cg, scale: 1.0, orientation: .right)
            } else {
                self.image.image = image
            }
        }
        picker.dismiss(animated: true)
    }
}
