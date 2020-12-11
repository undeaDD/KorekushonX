import Foundation

public enum Constants {
    public enum Keys: String {
        case calculateColors = "settingsCalculateColors"
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

        case managerContacts = "contacts"
        case contactSearch = "ContactSearch"
        case contactReload = "ContactNeedsUpdating"

        case managerWishes = "wishes"
        case wishesReload = "WunschNeedsUpdating"

        case remindReload = "ErinnerungNeedsUpdating"
        case remindCell = "erinnerungCell"

        case darkIcon = "Dark"
        case lightIcon = "Light"

        case sammlungView = "SammlungView"
        case rowView = "RowView"
        case bookView = "BookView"
        case compactView = "CompactView"
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
        case imageAPI = "api"
        case photoLibrary = "photoLibrary"
        case camera = "camera"
        case noImage = "noImage"
        case styleRow = "rows"
        case styleColumns = "columns"
        case styleCompact = "compact"
        case lightsOn = "lightsOn"
        case lightsOff = "lightsOff"
        case lightsAutomatic = "lightsAuto"
        case plus = "plus"
        case minus = "minus"
        case play = "play"
        case wait = "wait"
        case done = "done"
    }

    public enum Strings: String {
        case remindMe = "ReminderTitle"
        case date = "Date"
        case anime = "Anime"
        case reihe = "Manga"
        case book = "Book"
        case remind = "Reminder"
        case boughtAt = "BoughtAt"
        case generated = "Generated"
        case euro = "EuroSign"
        case dollar = "DollerSign"
        case search = "Search"
        case unknown = "Unknown"
        case trash = "Remove"
        case share = "Share"
        case edit = "Edit"
        case add = "AddNew"
        case of = "Of"
        case version = "Version"

        case filterCollection = "FilterCollection"
        case filterTitle = "FilterTitle"
        case filterAuthor = "FilterAuthor"
        case filterPublisher = "FilterPublisher"
        case filterComplete = "FilterComplete"
        case filterIncomplete = "FilterIncomplete"

        case filterAnimes = "FilterAnime"
        case filterCurrent = "FilterCurrent"
        case filterWatchlist = "FilterWatchlist"
        case filterWatched = "FilterWatched"

        case filterBooks = "FilterBooks"
        case filterGenerated = "filterGenerated"
        case sortByManga = "SortByManga"
        case sortByPriceDown = "SortPriceDown"
        case sortByPriceUp = "SortPriceUp"

        case imageChoose = "ChooseImage"
        case imageAPI = "ImageAPI"
        case photoLibrary = "PhotoLibrary"
        case camera = "Camera"
        case noImage = "NoImage"

        case styleCollection = "StyleCollection"
        case styleRow = "StyleRow"
        case styleColumns = "StyleColumns"
        case styleCompact = "StyleCompact"

        case appSymbol = "AppSymbol"
        case appSymbolLight = "AppSymbolLight"
        case appSymbolDark = "AppSymbolDark"

        case systemStyle = "SystemStyle"
        case systemStyleLight = "SystemStyleLight"
        case systemStyleAutomatic = "SystemStyleAuto"

        case repairTitle = "RepairTitle"
        case repairBody = "RepairBody"
        case repairWait = "RepairWaitTitle"
        case repairWaitBody = "RepairWaitBody"

        case removeAll = "RemoveAll"
        case removeBody = "RemoveBody"

        case searchTitle = "SearchTitle"
        case searchBody = "SearchBody"
        case searchTitleAnime = "SearchTitleAnime"
        case searchBodyAnime = "SearchBodyAnime"

        case duplicateTitle = "DuplicateTitle"
        case duplicateBody = "DuplicateBody"
        case savedTitle = "SavedTitle"
        case savedBody = "SavedBody"

        case restartTitle = "RestartTitle"
        case restartBody = "RestartBody"
        case restartButton = "RestartButton"
        case later = "Later"

        case notAvailableTitle = "NotAvailableTitle"
        case notAvailableBody = "NotAvailableBody"

        case noEmailTitle = "NoEmailTitle"
        case noEmailBody = "NoEmailBody"

        case warning = "Warning"
        case warningReminder = "WarningReminder"
        case settings = "Settings"

        case author = "Author"
        case publisher = "Publisher"
        case oneShot = "OneShot"
        case books = "Books"
        case boughtDay = "BoughtDay"
        case extras = "Extras"
        case boughtMangas = "BoughtMangas"

        case coffeeLoading = "CoffeeLoading"
        case coffeeSuccessTitle = "CoffeSuccessTitle"
        case coffeeSuccessBody = "CoffeSuccessBody"
        case coffeeErrorTitle = "CoffeErrorTitle"
        case coffeeErrorBody = "CoffeErrorBody"

        case filterOff = "FilterOff"
        case apply = "Apply"
        case cancel = "Cancel"
        case okay = "Okay"
        case no = "No"

        case update = "update"
        case previousEP = "prevEP"
        case nextEP = "nextEP"
        case changeCategory = "changeCategory"
        case playing = "playing"
        case list = "list"
        case finished = "finished"
        case actions = "actions"

        case more = "More"

        var locale: String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }
}
