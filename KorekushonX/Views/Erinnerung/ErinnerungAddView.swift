import UIKit

class ErinnerungAddView: UITableViewController {
    @IBOutlet private var titleField: UITextField!
    @IBOutlet private var numberField: UITextField!
    @IBOutlet private var dateField: UIDatePicker!
    var numberPickerView: UIPickerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateField.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())

        numberPickerView = UIPickerView()
        numberPickerView?.selectRow(0, inComponent: 0, animated: false)
        numberPickerView!.tag = 1
        numberPickerView!.delegate = self
        numberPickerView!.dataSource = self
        numberField.inputView = numberPickerView

        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }

    @IBAction private func save2() {
        save(true)
    }

    @IBAction private func save(_ keepOpen: Bool = false) {
        self.view.endEditing(true)

        let title = "\(Constants.Keys.book.locale): \(numberField.text.trim()) | \(titleField.text.trim())"
        ErinnerungManager.shared.shedule(title, dateField.date) {
            UserDefaults.standard.set(true, forKey: Constants.Keys.remindReload.rawValue)

            if keepOpen {
                AlertManager.shared.savedInfo(self, Constants.Keys.remind.locale)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

extension ErinnerungAddView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 100 }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { String(row + 1) }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numberField.text = String(numberPickerView!.selectedRow(inComponent: 0) + 1)
    }
}
