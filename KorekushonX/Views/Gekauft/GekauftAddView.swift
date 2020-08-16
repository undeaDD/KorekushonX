import UIKit

class GekauftAddView: UITableViewController {
    let manager = GekauftManager.shared
    let mangas: [Manga] = GekauftManager.shared.mangaStore.allObjects().sorted { $0.title < $1.title }
    let datePickerView = UIDatePicker()

    @IBOutlet var mangaField: UITextField!
    @IBOutlet private var numberField: UITextField!
    @IBOutlet private var priceField: UITextField!
    @IBOutlet private var dateField: UITextField!
    @IBOutlet private var placeField: UITextField!
    @IBOutlet private var stateField: UISegmentedControl!
    @IBOutlet private var extrasField: UITextField!

    var numberPickerView: UIPickerView?
    var editBook: Book?
    var index = 0

    @IBAction private func save2() {
        save(true)
    }

    @IBAction private func save(_ keepOpen: Bool = false) {
        self.view.endEditing(true)

        let manga = mangas[index]
        var date = datePickerView.date.timeIntervalSince1970
        if dateField.text == nil || dateField.text?.isEmpty ?? true {
            date = 0
        }

        let temp = Book(id: editBook != nil ? editBook!.id : UUID(),
                   mangaId: manga.id,
                     title: manga.title,
                    number: Int(numberField.text ?? "") ?? 1,
                     price: Float(priceField.text?.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0.0,
                      date: date,
                     place: placeField.text.trim(),
                     state: stateField.selectedSegmentIndex,
                    extras: extrasField.text.trim())

        try? manager.store.save(temp)
        UserDefaults.standard.set(true, forKey: "BooksNeedsUpdating")
        manager.checkMangaForCompletion(manga.id)

        if keepOpen {
            AlertManager.shared.savedInfo(self, "Band")
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectManga" {
            let dest = segue.destination as? GekauftSelectView
            dest?.selected = mangaField.text
            dest?.mangas = mangas
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        numberPickerView = UIPickerView()
        numberPickerView!.tag = 1
        numberPickerView!.delegate = self
        numberPickerView!.dataSource = self
        numberField.inputView = numberPickerView

        datePickerView.datePickerMode = .date
        dateField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(onChange(_:)), for: .valueChanged)

        if let book = editBook {
            navigationItem.title = "Bearbeiten"
            mangaField.text = book.title
            numberField.text = String(book.number)
            priceField.text = String(format: "%.2f", book.price)
            if book.date != 0 {
                dateField.text = manager.formatter.string(from: Date(timeIntervalSince1970: book.date))
            } else {
                dateField.text = nil
            }
            placeField.text = book.place
            stateField.selectedSegmentIndex = book.state
            extrasField.text = book.extras

            datePickerView.date = book.date == 0 ? Date() : Date(timeIntervalSince1970: book.date)
            index = (mangas.enumerated().first { $0.element.id == book.mangaId })?.offset ?? 0
            //mangaPickerView?.selectRow(index, inComponent: 0, animated: false)
        } else {
            self.navigationItem.title = "Hinzufügen"
            mangaField.text = mangas[index].title
            dateField.text = nil
            numberField.text = "1"
            mangaField.becomeFirstResponder()
        }

        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }

    @objc
    func onChange(_ sender: UIDatePicker) {
        dateField.text = GekauftManager.shared.formatter.string(from: datePickerView.date)
    }
}

extension GekauftAddView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (pickerView.tag, component) {
        case (1, 0):
            return mangas[index].countAll
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .destructive, title: "Löschen") { _, _, completion in
            self.dateField.text = nil
            completion(true)
        }
        remove.image = UIImage(named: "müll")
        remove.backgroundColor = .systemPurple
        return indexPath.row == 3 ? UISwipeActionsConfiguration(actions: [remove]) : nil
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch (pickerView.tag, component) {
        case (1, 0):
            return String(row + 1)
        case (1, 1):
            return "von"
        case (1, 2):
            return "\(mangas[index].countAll)"
        default:
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numberField.text = String(numberPickerView!.selectedRow(inComponent: 0) + 1)
    }
}
