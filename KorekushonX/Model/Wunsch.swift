import UIKit

struct Wunsch: Codable, Identifiable {
    static let idKey = \Wunsch.id
    var id: UUID

    var title: String
    var cover: Cover?
}

class WunschCell: UICollectionViewCell {
    @IBOutlet private var imageField: UIImageView!
    @IBOutlet private var numberField: UILabel!

    func setUp(_ wunsch: Wunsch) {
        numberField.text = wunsch.title
        imageField.image = wunsch.cover?.img() ?? UIImage(named: "default")
    }
}
