import UIKit

class GekauftSelectView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet private var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var dataDictionary = [String: [Manga]]()
    var dataSectionTitles = [String]()
    var mangas: [Manga] = []
    var filtered: [Manga]?
    var selected: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        reload()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Suchen"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.largeTitleDisplayMode = .automatic
    }

    func reload() {
        let items = filtered == nil ? mangas : filtered!
        dataDictionary = [:]
        dataSectionTitles = []

        for item in items {
            let itemKey = String(item.title.prefix(1))
            if var dataValues = dataDictionary[itemKey] {
                dataValues.append(item)
                dataDictionary[itemKey] = dataValues
            } else {
                dataDictionary[itemKey] = [item]
            }
        }

        dataSectionTitles = [String](dataDictionary.keys).sorted(by: { $0 < $1 })
        tableView.reloadData()
    }

    @IBAction private func gotoNewMangaView(_ sender: UIBarButtonItem) {
        (self.tabBarController as? TabBarController)?.addManga()
    }

    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive, let search = searchController.searchBar.text?.lowercased(), !search.isEmpty {
            filtered = mangas.filter {
            $0.title.lowercased().contains(search) || $0.author.lowercased().contains(search) || $0.publisher.lowercased().contains(search)
            }
        } else {
            filtered = nil
        }
        reload()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDictionary[dataSectionTitles[section]]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemKey = dataSectionTitles[indexPath.section]
        if let item = dataDictionary[itemKey]?[indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mangaCell", for: indexPath)
            cell.textLabel?.text = item.title
            cell.accessoryType = cell.textLabel?.text?.lowercased() == selected?.lowercased() ? .checkmark : .none
            return cell
        }
        fatalError("invalid cell dequeued")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        let itemKey = dataSectionTitles[indexPath.section]
        if let item = dataDictionary[itemKey]?[indexPath.row] {
            let vc = navigationController?.viewControllers.last as? GekauftAddView
            vc?.mangaField.text = item.title
            vc?.index = vc?.mangas.firstIndex(where: { $0.id == item.id }) ?? 0
        } else {
            fatalError("invalid cell clicked")
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSectionTitles[section]
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataSectionTitles
    }
}
