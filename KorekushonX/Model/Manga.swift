import UIKit

struct Manga: Codable, Identifiable {
    static let idKey = \Manga.id
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
    @IBOutlet private var titleField: UILabel?
    @IBOutlet private var countField: UILabel!

    func setUp(_ manga: Manga, _ bookStore: GekauftManager) {
        imageField.image = manga.cover?.img() ?? UIImage(named: "default")
        countField.text = ".../\(manga.countAll)"
        let attributed = NSMutableAttributedString(string: manga.title + "\n", attributes: [.foregroundColor: UIColor.systemPurple, .font: UIFont.systemFont(ofSize: 18, weight: .semibold)])
        attributed.append(NSAttributedString(string: manga.author, attributes: [.foregroundColor: UIColor.gray, .font: UIFont.systemFont(ofSize: 15, weight: .semibold)]))
        titleField?.attributedText = attributed

        bookStore.getMangaCount(manga.id) { count in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.countField.text = "\(count)/\(manga.countAll)"
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: -(CGFloat.pi / 2))
        titleField?.transform = transform
        titleField?.frame = CGRect(x: 0, y: 10, width: 90, height: frame.height - 170)
    }
}
