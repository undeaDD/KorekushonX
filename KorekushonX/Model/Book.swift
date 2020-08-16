import UIKit

struct Book: Codable, Identifiable {
    static let idKey = \Book.id
    var id: UUID
    var mangaId: UUID

    var title: String? // update title if nil :FFFF
    var number: Int
    var price: Float
    var date: Double
    var place: String
    var state: Int
    var extras: String

    func emote() -> String {
        switch state {
        case 1:
            return "😕"
        case 2:
            return "😶"
        case 3:
            return "🙂"
        case 4:
            return "🤩"
        default:
            return "🤮"
        }
    }
}

public class GekauftCell: UITableViewCell {
    @IBOutlet public var titleField: UILabel!
    @IBOutlet public var subtitleField: UILabel!
    @IBOutlet public var priceField: UILabel!

    func setUp(_ book: Book, _ date: String?) {
        titleField.text = book.title
        subtitleField.text = "Band: \(book.number) | \(date != nil ? "Gekauft am: " + date! : "Generiert")"
        priceField.text = String(format: "%.2f", book.price) + " €"
    }
}
