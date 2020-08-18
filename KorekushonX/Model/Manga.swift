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
    var coverColor: CoverColor?
}

public struct Cover: Codable {
    public let data: Data

    public func img() -> UIImage {
        return UIImage(data: data) ?? UIImage(named: Constants.Images.default.rawValue)!
    }

    public init(image: UIImage) {
        self.data = image.pngData()!
    }
}

class RowCell: UITableViewCell {
    @IBOutlet private var imageField: UIImageView!
    @IBOutlet private var titleField: UILabel!
    @IBOutlet private var subtitleField: UILabel!
    @IBOutlet private var countField: UILabel!
    static let reuseIdentifier = "sammlungCell"

    func setUp(_ manga: Manga, _ bookStore: GekauftManager) {
        titleField.text = manga.title
        subtitleField.text = manga.author
        countField.text = ".../\(manga.countAll)"
        imageField.image = manga.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)

        if UserDefaults.standard.bool(forKey: Constants.Keys.calculateColors.rawValue), let color = manga.coverColor?.color {
            backgroundColor = color
            if color.isDarkColor {
                titleField.textColor = .white
                subtitleField.textColor = .lightGray
                countField.textColor = .white
            } else {
                titleField.textColor = .black
                subtitleField.textColor = .darkGray
                countField.textColor = .black
            }
        } else {
            if #available(iOS 13.0, *) {
                backgroundColor = .tertiarySystemBackground
            } else {
                backgroundColor = .white
            }

            titleField.textColor = .systemPurple
            subtitleField.textColor = .gray
            countField.textColor = .systemPurple
        }

        if #available(iOS 13.0, *) {
            let image = UIImageView(image: UIImage(systemName: Constants.Images.chevronRight.rawValue)?.withRenderingMode(.alwaysTemplate))
            image.tintColor = subtitleField.textColor
            accessoryView = image
        }

        bookStore.getMangaCount(manga.id) { count in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.countField.text = "\(count)/\(manga.countAll)"
            }
        }
    }
}

class BookCell: UICollectionViewCell {
    @IBOutlet private var imageField: UIImageView!
    @IBOutlet private var titleField: UILabel?
    @IBOutlet private var countField: UILabel!
    static let reuseIdentifier = "bookCell"

    func setUp(_ manga: Manga, _ bookStore: GekauftManager) {
        imageField.image = manga.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)
        countField.text = ".../\(manga.countAll)"
        let bgView = contentView.subviews.first

        if UserDefaults.standard.bool(forKey: Constants.Keys.calculateColors.rawValue), let img = manga.cover?.img(), img != UIImage(named: Constants.Images.default.rawValue) {
            let color = img.averageColor
            bgView?.backgroundColor = color

            if color?.isDarkColor ?? false {
                let attributed = NSMutableAttributedString(string: manga.title + "\n", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .semibold)])
                attributed.append(NSAttributedString(string: manga.author, attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 17, weight: .semibold)]))
                titleField?.attributedText = attributed
                countField.textColor = .white
            } else {
                let attributed = NSMutableAttributedString(string: manga.title + "\n", attributes: [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20, weight: .semibold)])
                attributed.append(NSAttributedString(string: manga.author, attributes: [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 17, weight: .semibold)]))
                titleField?.attributedText = attributed
                countField.textColor = .black
            }
        } else {
            if #available(iOS 13.0, *) {
                bgView?.backgroundColor = .tertiarySystemBackground
            } else {
                bgView?.backgroundColor = .white
            }

            let attributed = NSMutableAttributedString(string: manga.title + "\n", attributes: [.foregroundColor: UIColor.systemPurple, .font: UIFont.systemFont(ofSize: 20, weight: .semibold)])
            attributed.append(NSAttributedString(string: manga.author, attributes: [.foregroundColor: UIColor.gray, .font: UIFont.systemFont(ofSize: 17, weight: .semibold)]))
            titleField?.attributedText = attributed
            countField.textColor = .systemPurple
        }

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
