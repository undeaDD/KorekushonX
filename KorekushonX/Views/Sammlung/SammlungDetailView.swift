import UIKit

class SammlungDetailView: UIViewController {
    @IBOutlet private var tableView: UITableView!
    let manager = SammlungManager.shared
    var scrollToRow: Int?
    var editAction: (() -> Void)?
    var removeAction: (() -> Void)?
    var shareAction: (() -> Void)?
    var books: [Book] = []
    var manga: Manga?

    override func viewDidLoad() {
        super.viewDidLoad()
        books = FilesStore<Book>(uniqueIdentifier: "books").allObjects().filter { $0.mangaId == manga!.id }.sorted { $0.number < $1.number }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let row = scrollToRow {
            let indexPath = IndexPath(row: row, section: 1)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
            tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit", let dest = segue.destination as? SammlungAddView {
            dest.editManga = (sender as! Manga)
        }
    }

    @IBAction private func shareManga() {
        manager.shareManga(manga!, self)
    }

    @IBAction private func editManga() {
        performSegue(withIdentifier: "edit", sender: manga!)
    }

    override var previewActionItems: [UIPreviewActionItem] {
        let edit = UIPreviewAction(title: "Bearbeiten", style: .default, handler: { _, _ in
            self.editAction?()
        })

        let share = UIPreviewAction(title: "Teilen", style: .default, handler: { _, _ in
            self.shareAction?()
        })

        let remove = UIPreviewAction(title: "Löschen", style: .destructive) { _, _ in
            self.removeAction?()
        }

        return [share, edit, remove]
    }
}

extension SammlungDetailView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let details = UserDefaults.standard.bool(forKey: "settingsSammlungShowCover") ? 2 : 1
        return section == 0 ? details : books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if UserDefaults.standard.bool(forKey: "settingsSammlungShowCover") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "coverCell") as! CoverCell
                cell.cover.image = manga?.cover?.img() ?? UIImage(named: "default")
                return cell
            }
            fallthrough
        case (0, 1):
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") as! DetailCell
            cell.titleField.text = manga?.title ?? "-"
                cell.subtitleField.text = "Autor:  \(manga?.author ?? "-")\nVerlag: \(manga?.publisher ?? "-")"

            if manga?.countAll ?? 1 == 1 {
                cell.countField.text = "One Shot"
            } else {
                cell.countField.text = "\(manga!.countAll) Bände"
            }

            return cell
        case (1, let index):
            let cell = tableView.dequeueReusableCell(withIdentifier: "gekauftCell") as! GekauftCell
            let book = books[index]
            let attributed = NSMutableAttributedString(string: "\(book.number)", attributes: [.foregroundColor: UIColor.systemPurple])
            attributed.append(NSAttributedString(string: " | \(manga?.title ?? "-")"))
            cell.titleField.attributedText = attributed

            var date = manager.formatter.string(from: Date(timeIntervalSince1970: book.date))
            if book.date == 0 { date = "-" }

            cell.subtitleField.text = "Extras: \(book.extras)\nKaufdatum: \(date)\n\(book.place)"
            cell.priceField.text = String(format: "%.2f", book.price) + " € " + book.emote()
            cell.accessoryType = scrollToRow == index ? .checkmark : .none
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section, indexPath.row) == (0, 0) ? UITableView.automaticDimension : 80
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Gekaufte Mangas" : nil
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
