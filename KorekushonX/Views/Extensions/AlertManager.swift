import Sheeeeeeeeet
import UIKit

struct AlertManager {
    private init() { }

    static let shared = AlertManager()

    func filterSammlung(_ vc: UIViewController, _ completion: @escaping () -> Void) {
        let spacer = SectionMargin()
        let title = SectionTitle(title: "Sammlung Filtern:")

        var items: [MenuItem] = [spacer, title]
        for elem in ["Nach Titel", "Nach Autor", "Nach Verlag", "Nur Vollständige", "Nur nicht Vollständige"].enumerated() {
            let isSelected = UserDefaults.standard.integer(forKey: "SammlungFilter") == (elem.offset + 1)
            let temp = SingleSelectItem(title: elem.element, isSelected: isSelected, value: elem.offset + 1)
            items.append(temp)
        }

        items.append(DestructiveButton(title: "Nicht Filtern"))
        items.append(CancelButton(title: "Abbrechen"))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                UserDefaults.standard.set(value, forKey: "SammlungFilter")
                completion()
            } else if (item as? DestructiveButton) != nil {
                UserDefaults.standard.set(0, forKey: "SammlungFilter")
                completion()
            }
        }.present(in: vc, from: vc.view)
    }

    func filterGekaufte(_ vc: UIViewController, _ completion: @escaping () -> Void) {
        let spacer = SectionMargin()
        let title = SectionTitle(title: "Bände Filtern:")

        var items: [MenuItem] = [spacer, title]
        for elem in ["Generierte ausblenden", "Nach Reihe sortieren", "Preis absteigend", "Preis aufsteigend"].enumerated() {
            let isSelected = UserDefaults.standard.integer(forKey: "GekauftFilter") == (elem.offset + 1)
            let temp = SingleSelectItem(title: elem.element, isSelected: isSelected, value: elem.offset + 1)
            items.append(temp)
        }

        items.append(DestructiveButton(title: "Nicht Filtern"))
        items.append(CancelButton(title: "Abbrechen"))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                UserDefaults.standard.set(value, forKey: "GekauftFilter")
                completion()
            } else if item as? DestructiveButton != nil {
                UserDefaults.standard.set(0, forKey: "GekauftFilter")
                completion()
            }
        }.present(in: vc, from: vc.view)
    }

    func options(_ vc: UIViewController, _ completion: @escaping (Int) -> Void) {
        var items: [MenuItem] = []
        items.append(SectionMargin())
        items.append(SectionTitle(title: "Aktion ausführen:"))
        items.append(LinkItem(title: "Teilen", value: 0, image: UIImage(named: "teilen")))
        items.append(LinkItem(title: "Bearbeiten", value: 1, image: UIImage(named: "editieren")))
        items.append(DestructiveItem(title: "Löschen", value: 2, image: UIImage(named: "müll")))
        items.append(CancelButton(title: "Abbrechen"))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                completion(value)
            }
        }.present(in: vc, from: vc.view)
    }

    func optionMinimal(_ vc: UIViewController, _ withEdit: Bool = false, _ completion: @escaping (Int) -> Void) {
        var items: [MenuItem] = []
        items.append(SectionMargin())
        items.append(SectionTitle(title: "Aktion ausführen:"))
        if withEdit {
            items.append(LinkItem(title: "Bearbeiten", value: 0, image: UIImage(named: "editieren")))
        }
        items.append(DestructiveItem(title: "Löschen", value: 1, image: UIImage(named: "müll")))
        items.append(CancelButton(title: "Abbrechen"))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                completion(value)
            }
        }.present(in: vc, from: vc.view)
    }

    func selectImage(_ vc: UIViewController, _ completion: @escaping (Int) -> Void) {
        var items: [MenuItem] = []
        items.append(SectionMargin())
        items.append(SectionTitle(title: "Bild auswählen:"))
        items.append(LinkItem(title: "Automatisch (Web-API)", value: 0, image: UIImage(named: "api")))
        items.append(LinkItem(title: "Fotoalbum", value: 1, image: UIImage(named: "photoLibrary")))
        items.append(LinkItem(title: "Kamera", value: 2, image: UIImage(named: "camera")))
        items.append(DestructiveItem(title: "Kein Bild", value: 3, image: UIImage(named: "noImage")))
        items.append(CancelButton(title: "Abbrechen"))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                completion(value)
            }
        }.present(in: vc, from: vc.view)
    }

    func selectSammlungType(_ vc: UIViewController) {
        var items: [MenuItem] = []
        let isSelected = UserDefaults.standard.integer(forKey: "settingsSammlungView")
        items.append(SectionMargin())
        items.append(SectionTitle(title: "Sammlungs Ansicht auswählen:"))
        items.append(SingleSelectItem(title: "Zeilen (Standard)", isSelected: 0 == isSelected, value: 0, image: UIImage(named: "rows")))
        items.append(SingleSelectItem(title: "Buchrücken", isSelected: 1 == isSelected, value: 1, image: UIImage(named: "columns")))
        items.append(SingleSelectItem(title: "Kompakt", isSelected: 2 == isSelected, value: 2, image: UIImage(named: "compact")))
        items.append(CancelButton(title: "Abbrechen"))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                UserDefaults.standard.set(value, forKey: "settingsSammlungView")
                AlertManager.shared.restartNeeded(vc)
            }
        }.present(in: vc, from: vc.view)
    }

    func selectAppIcon(_ vc: UIViewController) {
        if UIApplication.shared.supportsAlternateIcons {
            var items: [MenuItem] = []
            let isSelected = UIApplication.shared.alternateIconName == "Dark"
            items.append(SectionMargin())
            items.append(SectionTitle(title: "App Symbol auswählen:"))
            items.append(SingleSelectItem(title: "Hell (Standard)", isSelected: !isSelected, value: 0, image: UIImage(named: "lightsOn")))
            items.append(SingleSelectItem(title: "Dunkel", isSelected: isSelected, value: 1, image: UIImage(named: "lightsOff")))
            items.append(CancelButton(title: "Abbrechen"))
            Menu(items: items).toActionSheet { _, item in
                if let value = item.value as? Int {
                    UIApplication.shared.setAlternateIconName(value == 1 ? "Dark" : nil)
                }
            }.present(in: vc, from: vc.view)
        } else {
            AlertManager.shared.errorNotAvailable(vc)
        }
    }

    @available(iOS 13.0, *)
    func selectSystemStyle(_ vc: UIViewController) {
        var items: [MenuItem] = []
        let isSelected = UserDefaults.standard.integer(forKey: "settingsAppStyle")
        items.append(SectionMargin())
        items.append(SectionTitle(title: "System Style auswählen:"))
        items.append(SingleSelectItem(title: "Automatisch", isSelected: isSelected == 0, value: 0, image: UIImage(named: "lightsAuto")))
        items.append(SingleSelectItem(title: "Hell", isSelected: isSelected == 2, value: 2, image: UIImage(named: "lightsOn")))
        items.append(SingleSelectItem(title: "Dunkel", isSelected: isSelected == 1, value: 1, image: UIImage(named: "lightsOff")))
        items.append(CancelButton(title: "Abbrechen"))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                UserDefaults.standard.set(value, forKey: "settingsAppStyle")
                UIApplication.shared.delegate?.window??.overrideUserInterfaceStyle = value == 0 ? .unspecified : (value == 1 ? .dark : .light)
            }
        }.present(in: vc, from: vc.view)
    }

    func repairData(_ vc: UIViewController) {
        let alert = UIAlertController(title: "Alle Daten reparieren", message: "Dies kann fehlerhafte Daten wiederherstellen und reparieren, aber auch löschen.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: { _ in
            SammlungManager.shared.repairAll()
        }))

        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        vc.present(alert, animated: true)
    }

    func removeAll(_ vc: UIViewController) {
        let alert = UIAlertController(title: "Alles löschen?", message: "Dadurch werden alle lokal gespeicherten Daten gelöscht.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: { _ in
            FilesStore<Manga>(uniqueIdentifier: "mangas").deleteAll()
            FilesStore<Book>(uniqueIdentifier: "books").deleteAll()
            FilesStore<Wunsch>(uniqueIdentifier: "wishes").deleteAll()
            UserDefaults.standard.set(true, forKey: "SammlungNeedsUpdating")
            UserDefaults.standard.set(true, forKey: "BooksNeedsUpdating")
            UserDefaults.standard.set(true, forKey: "WunschNeedsUpdating")
            ErinnerungManager.shared.removeAll()
        }))

        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        vc.present(alert, animated: true)
    }

    func manualImageSearch(_ vc: UIViewController, _ completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Suchbegriff", message: "Nach dem Bild suchen\n(Manga Titel)", preferredStyle: .alert)
        alertController.addTextField { textField in textField.placeholder = "Kiss of the Fox" }
        alertController.addAction(UIAlertAction(title: "Suchen", style: .default) { [weak alertController] _ in
            guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
            completion(textField.text.trim())
        })
        alertController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        vc.present(alertController, animated: true, completion: nil)
    }

    func duplicateError(_ vc: UIViewController, _ type: String) {
        let alert = UIAlertController(title: "Duplikat", message: "\(type) konnte nicht gespeichert werden.", preferredStyle: .alert)
        vc.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350)) {
                alert.dismiss(animated: true)
            }
        }
    }

    func savedInfo(_ vc: UIViewController, _ type: String) {
        let alert = UIAlertController(title: "Gespeichert", message: "\(type) wurde erfolgreich gespeichert", preferredStyle: .alert)
        vc.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                alert.dismiss(animated: true)
            }
        }
    }

    func notificationError(_ vc: UIViewController) {
        let alert = UIAlertController(title: "Warnung", message: "Mitteilungen werden für Erinnerungen benötigt. Du kannst Mitteilungen in den Einstellungen wieder einschalten. Starte anschließend die App neu !!!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Nein", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Einstellungen", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        vc.present(alert, animated: true)
    }

    func emailError(_ vc: UIViewController) {
        let alert = UIAlertController(title: "Kein Konto gefunden", message: "Du hast kein Mailkonto eingerichtet, um Feedback zu versenden. Hier ist meine Mail Adresse, falls du von einem anderen Gerät Feedback senden willst.\n\ndominic.drees@live.de", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }

    func errorNotAvailable(_ vc: UIViewController) {
        let alert = UIAlertController(title: "Nicht verfügbar", message: "Diese Funktion ist auf deinem Gerät leider nicht verfügbar. Vielleicht wird dies durch ein System update behoben.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        vc.present(alert, animated: true)
    }

    func restartNeeded(_ vc: UIViewController) {
        let alert = UIAlertController(title: "Neustart", message: "Ein Neustart der App ist erforderlich.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "App Beenden", style: .destructive, handler: { _ in
            exit(0)
        }))
        vc.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                alert.dismiss(animated: true)
            }
        }
    }
}
