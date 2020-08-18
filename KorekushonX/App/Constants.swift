import Foundation

public enum Constants {
    public enum Keys: String {
        case calculateColors = "settingsCalculateColors"
        case showAnimeView = "settingsShowAnimeView"
        case selectedSammlungView = "settingsSammlungView"
        case showCover = "settingsSammlungShowCover"
        case appStyle = "settingsAppStyle"
        case reminderActive = "ErinnerungActive"
        case areaAverage = "CIAreaAverage"
        case selectManga = "selectManga"

        case managerAnime = "animes"
        case animeFilter = "AnimeFilter"
        case animeSearch = "AnimeSearch"
        case animeReload = "AnimeNeedsUpdating"

        case managerMangas = "mangas"
        case mangaFilter = "SammlungFilter"
        case mangaSearch = "SammlungSearch"
        case mangaReload = "SammlungNeedsUpdating"

        case managerBooks = "books"
        case booksFilter = "GekauftFilter"
        case booksSearch = "GekauftSearch"
        case booksMangaCell = "mangaCell"
        case booksReload = "BooksNeedsUpdating"

        case managerWishes = "wishes"
        case wishesReload = "WunschNeedsUpdating"

        case remindReload = "ErinnerungNeedsUpdating"
        case remindCell = "erinnerungCell"

        case sammlungView = "SammlungView"
        case rowView = "RowView"
        case bookView = "BookView"
        case compactView = "CompactView"

        case remindMe = "Erinnerung für"
        case date = "Date"
        case reihe = "Reihe"
        case book = "Book"
        case remind = "Erinnerung"
        case boughtAt = "Gekauft am"
        case generated = "Generiert"
        case euro = " EURO"
        case dollar = "DOLLAR "
        case search = "Search"
        case dateFormat = "DateFormat"
        case unknown = "-"
        case trash = "Löschen"
        case share = "Teilen"
        case edit = "Bearbeiten"
        case add = "HInzufügen"
        case of = "von"
        case version = "Version"

        var locale: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }

    public enum Segues: String {
        case edit
        case share
        case detail
        case settings
        case webView
    }

    public enum HTML: String {
        case imprint = "Impressum"
        case dataprotection = "Datenschutz"
        case licenses = "Lizenzen"
        case changelog = "Änderungen"
    }

    public enum Images: String {
        case selected = "selected"
        case unselected = "unselected"
        case `default` = "default"
        case chevronRight = "chevron.right"
        case filterOff = "filterOff"
        case filterOn = "filterOn"
        case trash = "müll"
        case share = "teilen"
        case edit = "editieren"
    }
}
