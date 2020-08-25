import UIKit

class SammlungDetailView: UIViewController {
    @IBOutlet private var tableView: UITableView!
    let manager = SammlungManager.shared
    var editAction: (() -> Void)?
    var removeAction: (() -> Void)?
    var shareAction: (() -> Void)?
    var books: [Book] = []
    var manga: Manga?

    override func viewDidLoad() {
        super.viewDidLoad()
        books = FilesStore<Book>(uniqueIdentifier: Constants.Keys.managerBooks.rawValue).allObjects().filter { $0.mangaId == manga!.id }.sorted { $0.number < $1.number }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.edit.rawValue, let dest = segue.destination as? SammlungAddView {
            dest.editManga = (sender as! Manga)
        }
    }

    @IBAction private func shareManga() {
        manager.shareManga(manga!, self)
    }

    @IBAction private func editManga() {
        performSegue(withIdentifier: Constants.Segues.edit.rawValue, sender: manga!)
    }
}

extension SammlungDetailView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let details = UserDefaults.standard.bool(forKey: Constants.Keys.showCover.rawValue) ? 2 : 1
        return section == 0 ? details : books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if UserDefaults.standard.bool(forKey: Constants.Keys.showCover.rawValue) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "coverCell") as! CoverCell
                cell.cover.image = manga?.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)
                return cell
            }
            fallthrough
        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") as! DetailCell
            cell.titleField.text = manga?.title ?? "-"
            cell.subtitleField.text = "\(Constants.Strings.author.locale): \(manga?.author ?? "-")\n\(Constants.Strings.publisher.locale): \(manga?.publisher ?? "-")"

            if manga?.countAll ?? 1 == 1 {
                cell.countField.text = Constants.Strings.oneShot.locale
            } else {
                cell.countField.text = "\(manga!.countAll) \(Constants.Strings.books.locale)"
            }

            return cell
        case (1, let index):
            let cell = tableView.dequeueReusableCell(withIdentifier: "gekauftCell") as! GekauftCell
            let book = books[index]
            let attributed = NSMutableAttributedString(string: "\(book.number). ", attributes: [.foregroundColor: UIColor.systemPurple])
            attributed.append(NSAttributedString(string: manga?.title ?? "-"))
            cell.titleField.attributedText = attributed

            var date = manager.formatter.string(from: Date(timeIntervalSince1970: book.date))
            if book.date == 0 { date = "-" }

            cell.subtitleField.text = "\(Constants.Strings.boughtDay.locale): \(date)\n\(Constants.Strings.extras.locale): \(book.extras)\n\(book.place)"
            cell.priceField.text = Constants.Strings.dollar.locale + String(format: "%.2f", book.price) + Constants.Strings.euro.locale + " " + book.emote()
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section, indexPath.row) == (0, 0) ? UITableView.automaticDimension : 80
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? Constants.Strings.boughtMangas.locale : nil
    }
}

public class CoverCell: UITableViewCell {
    @IBOutlet public var cover: UIImageView!
}

public class DetailCell: UITableViewCell {
    @IBOutlet public var titleField: UILabel!
    @IBOutlet public var subtitleField: UILabel!
    @IBOutlet public var countField: UILabel!
}
