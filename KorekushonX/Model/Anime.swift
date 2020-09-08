import UIKit

struct Anime: Codable, Identifiable {
    static let idKey = \Anime.id
    var id: UUID

    var title: String
    var cover: Cover?
    var coverColor: CoverColor?
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
        imageField.image = anime.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)
        titleField.text = anime.title

        switch anime.category {
        case 0:
            categoryField.image = UIImage(named: "play")
        case 1:
            categoryField.image = UIImage(named: "wait")
        case 2:
            categoryField.image = UIImage(named: "done")
        default:
            categoryField.image = nil
        }

        episodeField.text = "Ep: \(anime.episode)"

        if UserDefaults.standard.bool(forKey: Constants.Keys.calculateColors.rawValue), let color = anime.coverColor?.color {
            backgroundColor = color
            if color.isDarkColor {
                titleField.textColor = .white
                episodeField.textColor = .white
                categoryField.tintColor = .white
            } else {
                titleField.textColor = .black
                episodeField.textColor = .black
                categoryField.tintColor = .black
            }
        } else {
            if #available(iOS 13.0, *) {
                backgroundColor = .tertiarySystemBackground
            } else {
                backgroundColor = .white
            }

            titleField.textColor = .black
            episodeField.textColor = .systemOrange
            categoryField.tintColor = .systemOrange
        }
    }
}
