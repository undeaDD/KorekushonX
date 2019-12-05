import UIKit

struct Wunsch: Codable, Identifiable {
    static let idKey = \id
    var id: UUID
    var number: Int
    var cover: Cover
}

class WunschCell: UICollectionViewCell {
    @IBOutlet private var imageField: UIImageView!
    @IBOutlet private var numberField: UILabel!

    func setUp(_ wunsch: Wunsch) {
        numberField.text = "Band: \(wunsch.number)"
        imageField.image = wunsch.cover.img()
    }
}
