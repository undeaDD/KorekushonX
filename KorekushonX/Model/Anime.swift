import UIKit

struct Anime: Codable, Identifiable {
    static let idKey = \Anime.id
    var id: UUID

    var title: String
    var cover: Cover?
    var category: Int
    var episode: Int
}

class AnimeCell: UICollectionViewCell {
    @IBOutlet private var imageField: UIImageView!
    @IBOutlet private var categoryField: UIImageView!
    @IBOutlet private var titleField: UILabel!
    @IBOutlet private var episodeField: UILabel!
    static let reuseIdentifier = "animeCell"

    func setUp(_ anime: Anime) {
        //numberField.text = wunsch.title
        //imageField.image = wunsch.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)
    }
}
