import UIKit

struct Manga: Codable, Identifiable {
    static let idKey = \id
    var id: UUID
    var title: String
    var author: String
    var cover: Cover?
    var publisher: String
    var countAll: Int
    var available: Bool
    var completed: Bool
}

public struct Cover: Codable {
    public let data: Data

    public func img() -> UIImage {
        return UIImage(data: data) ?? UIImage(named: "default")!
    }

    public init(image: UIImage) {
        self.data = image.pngData()!
    }
}

extension UIImage {
    func cover() -> Cover {
        return Cover(image: self)
    }
}

class RowCell: UITableViewCell {
    @IBOutlet private var imageField: UIImageView!
    @IBOutlet private var titleField: UILabel!
    @IBOutlet private var subtitleField: UILabel!
    @IBOutlet private var countField: UILabel!

    func setUp(_ manga: Manga, _ bookStore: GekauftManager) {
        titleField.text = manga.title
        subtitleField.text = manga.author
        countField.text = ".../\(manga.countAll)"
        imageField.image = manga.cover?.img() ?? UIImage(named: "default")

        bookStore.getMangaCount(manga.id) { count in
            DispatchQueue.main.async {
                self.countField.text = "\(count)/\(manga.countAll)"
            }
        }
    }
}

class BookCell: UICollectionViewCell {
    @IBOutlet private var imageField: UIImageView!
    /*
    @IBOutlet private var titleField: UILabel!
    @IBOutlet private var subtitleField: UILabel!
    @IBOutlet private var countField: UILabel!
    */

    func setUp(_ manga: Manga, _ bookStore: GekauftManager) {
        imageField.image = manga.cover?.img() ?? UIImage(named: "default")
        /*
        titleField.text = manga.title
        subtitleField.text = manga.author
        countField.text = ".../\(manga.countAll)"
        

        bookStore.getMangaCount(manga.id) { count in
            DispatchQueue.main.async {
                self.countField.text = "\(count)/\(manga.countAll)"
            }
        }
        */
    }
}
