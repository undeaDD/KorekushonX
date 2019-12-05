import UIKit

struct Manga: Codable, Identifiable {
    static let idKey = \id
    var id: UUID
    var title: String
    var author: String
    var cover: Cover
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
        self.data = image.jpegData(compressionQuality: 0.8)!
    }
}

extension UIImage {
    func cover() -> Cover {
        return Cover(image: self)
    }
}

class SammlungCell: UITableViewCell {
    @IBOutlet private var imageField: UIImageView!
    @IBOutlet private var titleField: UILabel!
    @IBOutlet private var subtitleField: UILabel!
    @IBOutlet private var stateField: UIImageView!
    @IBOutlet private var completeField: UIImageView!

    func setUp(_ manga: Manga) {
        titleField.text = manga.title
        subtitleField.text = "Autor: \(manga.author)"
        imageField.image = manga.cover.img()
        completeField.isHidden = !manga.completed
        completeField.tintColor = .systemPurple
        stateField.tintColor = manga.available ? .systemGreen : .systemRed
    }
}
