import UIKit

struct Erinnerung: Codable, Identifiable {
    static let idKey = \Erinnerung.id
    var id: String

    var title: String
    var date: Double
}

class ErinnerungCell: UITableViewCell {
    @IBOutlet private var titleField: UILabel!
    @IBOutlet private var subtitleField: UILabel!

    func setUp(_ errinnerung: Erinnerung, _ date: String) {
        let temp = errinnerung.title.components(separatedBy: " | ")
        titleField.text = String(temp.count > 1 ? temp[1] : "-")
        subtitleField.text = "\(String(temp[0])) | Datum: \(date)"
    }
}
