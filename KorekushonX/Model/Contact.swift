import UIKit

struct Contact: Codable, Identifiable {
    static let idKey = \Contact.id
    var id: UUID

    var name: String
    var link: String?
    var rating: Int
}

class ContactCell: UITableViewCell {
    @IBOutlet private var nameField: UILabel!
    static let reuseIdentifier = "contactCell"

    func setUp(_ contact: Contact) { }
}
