import UIKit

class SammlungAddView: UITableViewController {
    let manager = SammlungManager.shared
    let imagePicker: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        return pickerController
    }()

    @IBOutlet private var titleField: UITextField!
    @IBOutlet private var authorField: UITextField!
    @IBOutlet private var publisherField: UITextField!
    @IBOutlet private var countField: UITextField!
    @IBOutlet private var image: UIImageView!

    var editManga: Manga?
    var haveCount = 0
    var maxCount = 1

    @IBAction private func save2() {
        save(true)
    }

    @IBAction private func save(_ keepOpen: Bool = false) {
        self.view.endEditing(true)

        var completed = false
        if editManga == nil {
            completed = haveCount == maxCount
        } else {
            completed = maxCount <= editManga!.countAll
        }

        let img = image.image == UIImage(named: "default") ? nil : image.image?.cover()
        let temp = Manga(id: editManga != nil ? editManga!.id : UUID(),
                      title: titleField.text.trim(),
                     author: authorField.text.trim(),
                      cover: img,
                  publisher: publisherField.text.trim(),
                   countAll: maxCount,
                  available: true,
                  completed: completed)

        if editManga == nil && manager.store.allObjects().contains(where: { stored -> Bool in
            stored.title.lowercased() == temp.title.lowercased()
        }) {
            let alert = UIAlertController(title: "Duplikat", message: "Manga konnte nicht in der Sammlung gespeichert werden.", preferredStyle: .alert)
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350)) {
                    self.titleField.text = nil
                    alert.dismiss(animated: true)
                }
            }
            return
        }

        try! manager.store.save(temp)
        UserDefaults.standard.set(true, forKey: "SammlungNeedsUpdating")

        if editManga == nil {
            createDummyEntries(temp.id, temp.title)
        } else {
            removeTooManyBooks(temp.id, maxCount)
        }

        if keepOpen {
            let alert = UIAlertController(title: "Gespeichert", message: "Manga wurde erfolgreich in der Sammlung gespeichert", preferredStyle: .alert)
            self.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                    alert.dismiss(animated: true)
                }
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    func removeTooManyBooks(_ mangaID: UUID, _ newMax: Int) {
        let books = FilesStore<Book>(uniqueIdentifier: "books")
        let toRemove = books.allObjects().filter { $0.mangaId == mangaID && $0.number > newMax }
        for item in toRemove {
            try? books.delete(withId: item.id)
        }
        UserDefaults.standard.set(true, forKey: "BooksNeedsUpdating")
    }

    func createDummyEntries(_ mangaID: UUID, _ mangaTitle: String) {
        if haveCount > 0 && editManga == nil {
            let tempStore = FilesStore<Book>(uniqueIdentifier: "books")
            for index in 1...haveCount {
                try? tempStore.save(Book(id: UUID(), mangaId: mangaID, title: mangaTitle, number: index, price: 0, date: 0, place: "-", state: 2, extras: "-"))
            }
            UserDefaults.standard.set(true, forKey: "BooksNeedsUpdating")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        countField.inputView = pickerView

        if let manga = editManga {
            navigationItem.title = "Bearbeiten"
            titleField.text = manga.title
            authorField.text = manga.author
            publisherField.text = manga.publisher
            countField.text = "? von \(String(manga.countAll))"
            maxCount = manga.countAll

            image.image = manga.cover?.img() ?? UIImage(named: "default")
            pickerView.selectRow(manga.countAll - 1, inComponent: 2, animated: false)
        } else {
            self.navigationItem.title = "Hinzufügen"
            countField.text = "0 von 1"
        }

        imagePicker.delegate = self
        titleField.becomeFirstResponder()
        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }
}

extension SammlungAddView: UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            sheet.addAction(UIAlertAction(title: "Automatisch (via API)", style: .default, handler: { _ in
                self.image.image = WebImage.apiImage(self.titleField.text.trim())
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

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return 1
        } else if component == 2 {
            return 100
        } else if editManga != nil {
            return 1
        } else {
            return 101
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return "von"
        } else if component == 2 {
            return String(row + 1)
        } else if editManga != nil {
            return "?"
        } else {
            return String(row)
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let max = pickerView.selectedRow(inComponent: 2)
            if row > max + 1 {
                pickerView.selectRow(max + 1, inComponent: 0, animated: false)
            }
        }
        if component == 2 {
            let oldValue = pickerView.selectedRow(inComponent: 0)
            if oldValue > row + 1 {
                pickerView.selectRow(oldValue - 1, inComponent: 2, animated: false)
            }
        }

        maxCount = pickerView.selectedRow(inComponent: 2) + 1
        if editManga != nil {
            countField.text = "? von \(maxCount)"
        } else {
            haveCount = pickerView.selectedRow(inComponent: 0)
            countField.text = "\(haveCount) von \(maxCount)"
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.image.image = UIImage(named: "default")
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.image.image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true)
    }
}
