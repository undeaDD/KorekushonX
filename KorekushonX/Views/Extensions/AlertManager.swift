import Sheeeeeeeeet
import UIKit

struct AlertManager {
    private init() { }

    static let shared = AlertManager()

    func filterSammlung(_ vc: UIViewController, _ completion: @escaping () -> Void) {
        let spacer = SectionMargin()
        let title = SectionTitle(title: Constants.Strings.filterCollection.locale)

        var items: [MenuItem] = [spacer, title]
        for elem in [
            Constants.Strings.filterTitle.locale,
            Constants.Strings.filterAuthor.locale,
            Constants.Strings.filterPublisher.locale,
            Constants.Strings.filterComplete.locale,
            Constants.Strings.filterIncomplete.locale
        ].enumerated() {
            let isSelected = UserDefaults.standard.integer(forKey: Constants.Keys.mangaFilter.rawValue) == (elem.offset + 1)
            let temp = SingleSelectItem(title: elem.element, isSelected: isSelected, value: elem.offset + 1)
            items.append(temp)
        }

        items.append(DestructiveButton(title: Constants.Strings.filterOff.locale))
        items.append(CancelButton(title: Constants.Strings.cancel.locale))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                UserDefaults.standard.set(value, forKey: Constants.Keys.mangaFilter.rawValue)
                completion()
            } else if (item as? DestructiveButton) != nil {
                UserDefaults.standard.set(0, forKey: Constants.Keys.mangaFilter.rawValue)
                completion()
            }
        }.present(in: vc, from: vc.view)
    }

    func filterAnimes(_ vc: UIViewController, _ completion: @escaping () -> Void) {
        let spacer = SectionMargin()
        let title = SectionTitle(title: Constants.Strings.filterAnimes.locale)

        var items: [MenuItem] = [spacer, title]
        for elem in [
            Constants.Strings.filterCurrent.locale,
            Constants.Strings.filterWatchlist.locale,
            Constants.Strings.filterWatched.locale
        ].enumerated() {
            let isSelected = UserDefaults.standard.integer(forKey: Constants.Keys.animeFilter.rawValue) == (elem.offset + 1)
            let temp = SingleSelectItem(title: elem.element, isSelected: isSelected, value: elem.offset + 1)
            items.append(temp)
        }

        items.append(DestructiveButton(title: Constants.Strings.filterOff.locale))
        items.append(CancelButton(title: Constants.Strings.cancel.locale))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                UserDefaults.standard.set(value, forKey: Constants.Keys.animeFilter.rawValue)
                completion()
            } else if (item as? DestructiveButton) != nil {
                UserDefaults.standard.set(0, forKey: Constants.Keys.animeFilter.rawValue)
                completion()
            }
        }.present(in: vc, from: vc.view)
    }

    func filterGekaufte(_ vc: UIViewController, _ completion: @escaping () -> Void) {
        let spacer = SectionMargin()
        let title = SectionTitle(title: Constants.Strings.filterBooks.locale)

        var items: [MenuItem] = [spacer, title]
        for elem in [
            Constants.Strings.filterGenerated.locale,
            Constants.Strings.sortByManga.locale,
            Constants.Strings.sortByPriceDown.locale,
            Constants.Strings.sortByPriceUp.locale
        ].enumerated() {
            let isSelected = UserDefaults.standard.integer(forKey: Constants.Keys.booksFilter.rawValue) == (elem.offset + 1)
            let temp = SingleSelectItem(title: elem.element, isSelected: isSelected, value: elem.offset + 1)
            items.append(temp)
        }

        items.append(DestructiveButton(title: Constants.Strings.filterOff.locale))
        items.append(CancelButton(title: Constants.Strings.cancel.locale))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                UserDefaults.standard.set(value, forKey: Constants.Keys.booksFilter.rawValue)
                completion()
            } else if item as? DestructiveButton != nil {
                UserDefaults.standard.set(0, forKey: Constants.Keys.booksFilter.rawValue)
                completion()
            }
        }.present(in: vc, from: vc.view)
    }

    func optionsAnime(_ vc: UIViewController, _ isNotFirst: Bool, category: Int, _ completion: @escaping (Int) -> Void) {
        var items: [MenuItem] = []

        items.append(SectionMargin())
        items.append(SectionTitle(title: Constants.Strings.update.locale))

        let temp = LinkItem(title: Constants.Strings.previousEP.locale, value: 3, image: UIImage(named: Constants.Images.minus.rawValue))
        temp.isEnabled = isNotFirst
        items.append(temp)
        items.append(LinkItem(title: Constants.Strings.nextEP.locale, value: 4, image: UIImage(named: Constants.Images.plus.rawValue)))

        items.append(SectionMargin())
        items.append(SectionTitle(title: Constants.Strings.changeCategory.locale))
        let a = SingleSelectItem(title: Constants.Strings.playing.locale, isSelected: category == 0, value: 5, image: UIImage(named: Constants.Images.play.rawValue))
        a.tapBehavior = category == 0 ? .none : .dismiss
        let b = SingleSelectItem(title: Constants.Strings.list.locale, isSelected: category == 1, value: 6, image: UIImage(named: Constants.Images.wait.rawValue))
        b.tapBehavior = category == 1 ? .none : .dismiss
        let c = SingleSelectItem(title: Constants.Strings.finished.locale, isSelected: category == 2, value: 7, image: UIImage(named: Constants.Images.done.rawValue))
        c.tapBehavior = category == 2 ? .none : .dismiss
        items.append(contentsOf: [a, b, c])

        items.append(SectionMargin())
        items.append(SectionTitle(title: Constants.Strings.actions.locale))
        items.append(LinkItem(title: Constants.Strings.share.locale, value: 0, image: UIImage(named: Constants.Images.share.rawValue)))
        items.append(LinkItem(title: Constants.Strings.edit.locale, value: 1, image: UIImage(named: Constants.Images.edit.rawValue)))
        items.append(DestructiveItem(title: Constants.Strings.trash.locale, value: 2, image: UIImage(named: Constants.Images.trash.rawValue)))
        items.append(CancelButton(title: Constants.Strings.cancel.locale))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                completion(value)
            }
        }.present(in: vc, from: vc.view)
    }

    func options(_ vc: UIViewController, _ completion: @escaping (Int) -> Void) {
        var items: [MenuItem] = []
        items.append(LinkItem(title: Constants.Strings.share.locale, value: 0, image: UIImage(named: Constants.Images.share.rawValue)))
        items.append(LinkItem(title: Constants.Strings.edit.locale, value: 1, image: UIImage(named: Constants.Images.edit.rawValue)))
        items.append(DestructiveItem(title: Constants.Strings.trash.locale, value: 2, image: UIImage(named: Constants.Images.trash.rawValue)))
        items.append(CancelButton(title: Constants.Strings.cancel.locale))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                completion(value)
            }
        }.present(in: vc, from: vc.view)
    }

    func optionMinimal(_ vc: UIViewController, _ withEdit: Bool = false, _ completion: @escaping (Int) -> Void) {
        var items: [MenuItem] = []
        if withEdit {
            items.append(LinkItem(title: Constants.Strings.edit.locale, value: 0, image: UIImage(named: Constants.Images.edit.rawValue)))
        }
        items.append(DestructiveItem(title: Constants.Strings.trash.locale, value: 1, image: UIImage(named: Constants.Images.trash.rawValue)))
        items.append(CancelButton(title: Constants.Strings.cancel.locale))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                completion(value)
            }
        }.present(in: vc, from: vc.view)
    }

    func selectImage(_ vc: UIViewController, _ completion: @escaping (Int) -> Void) {
        var items: [MenuItem] = []
        items.append(SectionMargin())
        items.append(SectionTitle(title: Constants.Strings.imageChoose.locale))
        items.append(LinkItem(title: Constants.Strings.imageAPI.locale, value: 0, image: UIImage(named: Constants.Images.imageAPI.rawValue)))
        items.append(LinkItem(title: Constants.Strings.photoLibrary.locale, value: 1, image: UIImage(named: Constants.Images.photoLibrary.rawValue)))
        items.append(LinkItem(title: Constants.Strings.camera.locale, value: 2, image: UIImage(named: Constants.Images.camera.rawValue)))
        items.append(DestructiveItem(title: Constants.Strings.noImage.locale, value: 3, image: UIImage(named: Constants.Images.noImage.rawValue)))
        items.append(CancelButton(title: Constants.Strings.cancel.locale))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                completion(value)
            }
        }.present(in: vc, from: vc.view)
    }

    func selectSammlungType(_ vc: UIViewController) {
        var items: [MenuItem] = []
        let isSelected: [Int] = UserDefaults.standard.array(forKey: Constants.Keys.selectedSammlungView.rawValue) as? [Int] ?? [0]
        items.append(SectionMargin())
        items.append(SectionTitle(title: Constants.Strings.styleCollection.locale))
        items.append(MultiSelectItem(title: Constants.Strings.styleRow.locale, isSelected: isSelected.contains(0), value: 0, image: UIImage(named: Constants.Images.styleRow.rawValue)))
        items.append(MultiSelectItem(title: Constants.Strings.styleColumns.locale, isSelected: isSelected.contains(1), value: 1, image: UIImage(named: Constants.Images.styleColumns.rawValue)))
        items.append(MultiSelectItem(title: Constants.Strings.styleCompact.locale, isSelected: isSelected.contains(2), value: 2, image: UIImage(named: Constants.Images.styleCompact.rawValue)))
        items.append(DestructiveButton(title: Constants.Strings.apply.locale))
        items.append(CancelButton(title: Constants.Strings.cancel.locale))
        Menu(items: items).toActionSheet { sheet, item in
            if item is DestructiveButton {
                var array: [Int] = sheet.items.compactMap { item in
                    if let item = item as? MultiSelectItem {
                        return item.isSelected ? (item.value as? Int) : nil
                    } else { return nil }
                }
                if array.isEmpty { array.append(0) }
                UserDefaults.standard.set(array, forKey: Constants.Keys.selectedSammlungView.rawValue)
                AlertManager.shared.restartNeeded(vc)
            }
        }.present(in: vc, from: vc.view)
    }

    func selectAppIcon(_ vc: UIViewController) {
        if UIApplication.shared.supportsAlternateIcons {
            var items: [MenuItem] = []
            let isSelected = UIApplication.shared.alternateIconName == Constants.Keys.darkIcon.rawValue
            items.append(SectionMargin())
            items.append(SectionTitle(title: Constants.Strings.appSymbol.locale))
            items.append(SingleSelectItem(title: Constants.Strings.appSymbolLight.locale, isSelected: !isSelected, value: 0, image: UIImage(named: Constants.Images.lightsOn.rawValue)))
            items.append(SingleSelectItem(title: Constants.Strings.appSymbolDark.locale, isSelected: isSelected, value: 1, image: UIImage(named: Constants.Images.lightsOff.rawValue)))
            items.append(CancelButton(title: Constants.Strings.cancel.locale))
            Menu(items: items).toActionSheet { _, item in
                if let value = item.value as? Int {
                    UIApplication.shared.setAlternateIconName(value == 1 ? Constants.Keys.darkIcon.rawValue : nil)
                }
            }.present(in: vc, from: vc.view)
        } else {
            AlertManager.shared.errorNotAvailable(vc)
        }
    }

    @available(iOS 13.0, *)
    func selectSystemStyle(_ vc: UIViewController) {
        var items: [MenuItem] = []
        let isSelected = UserDefaults.standard.integer(forKey: Constants.Keys.appStyle.rawValue)
        items.append(SectionMargin())
        items.append(SectionTitle(title: Constants.Strings.systemStyle.locale))
        items.append(SingleSelectItem(title: Constants.Strings.systemStyleAutomatic.locale, isSelected: isSelected == 0, value: 0, image: UIImage(named: Constants.Images.lightsAutomatic.rawValue)))
        items.append(SingleSelectItem(title: Constants.Strings.systemStyleLight.locale, isSelected: isSelected == 2, value: 2, image: UIImage(named: Constants.Images.lightsOn.rawValue)))
        items.append(SingleSelectItem(title: Constants.Strings.appSymbolDark.locale, isSelected: isSelected == 1, value: 1, image: UIImage(named: Constants.Images.lightsOff.rawValue)))
        items.append(CancelButton(title: Constants.Strings.cancel.locale))
        Menu(items: items).toActionSheet { _, item in
            if let value = item.value as? Int {
                UserDefaults.standard.set(value, forKey: Constants.Keys.appStyle.rawValue)
                UIApplication.shared.delegate?.window??.overrideUserInterfaceStyle = value == 0 ? .unspecified : (value == 1 ? .dark : .light)
            }
        }.present(in: vc, from: vc.view)
    }

    func repairData(_ vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.Strings.repairTitle.locale, message: Constants.Strings.repairBody.locale, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: Constants.Strings.okay.locale, style: .destructive, handler: { _ in
                let alert2 = UIAlertController(title: Constants.Strings.repairWait.locale, message: Constants.Strings.repairWaitBody.locale, preferredStyle: .alert)
                vc.present(alert2, animated: true)
                SammlungManager.shared.repairAll {
                    AnimeManager.shared.repairAll {
                        alert2.dismiss(animated: true)
                    }
                }
            }))

            alert.addAction(UIAlertAction(title: Constants.Strings.cancel.locale, style: .cancel, handler: nil))
            vc.present(alert, animated: true)
        }
    }

    func removeAll(_ vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.Strings.removeAll.locale, message: Constants.Strings.removeBody.locale, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: Constants.Strings.okay.locale, style: .destructive, handler: { _ in
                FilesStore<Manga>(uniqueIdentifier: Constants.Keys.managerMangas.rawValue).deleteAll()
                FilesStore<Book>(uniqueIdentifier: Constants.Keys.managerBooks.rawValue).deleteAll()
                FilesStore<Wunsch>(uniqueIdentifier: Constants.Keys.managerWishes.rawValue).deleteAll()
                FilesStore<Anime>(uniqueIdentifier: Constants.Keys.managerAnime.rawValue).deleteAll()
                UserDefaults.standard.set(true, forKey: Constants.Keys.mangaReload.rawValue)
                UserDefaults.standard.set(true, forKey: Constants.Keys.booksReload.rawValue)
                UserDefaults.standard.set(true, forKey: Constants.Keys.wishesReload.rawValue)
                UserDefaults.standard.set(true, forKey: Constants.Keys.animeReload.rawValue)
                ErinnerungManager.shared.removeAll()
            }))

            alert.addAction(UIAlertAction(title: Constants.Strings.cancel.locale, style: .cancel, handler: nil))
            vc.present(alert, animated: true)
        }
    }

    func manualImageSearch(_ vc: UIViewController, _ completion: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: Constants.Strings.searchTitle.locale, message: Constants.Strings.searchBody.locale, preferredStyle: .alert)
            alertController.addTextField { textField in textField.placeholder = "Kiss of the Fox" }
            alertController.addAction(UIAlertAction(title: Constants.Strings.search.locale, style: .default) { [weak alertController] _ in
                guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
                completion(textField.text.trim())
            })
            alertController.addAction(UIAlertAction(title: Constants.Strings.cancel.locale, style: .cancel, handler: nil))
            vc.present(alertController, animated: true, completion: nil)
        }
    }

    func manualImageSearchAnime(_ vc: UIViewController, _ completion: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: Constants.Strings.searchTitleAnime.locale, message: Constants.Strings.searchBodyAnime.locale, preferredStyle: .alert)
            alertController.addTextField { textField in textField.placeholder = "No Game No Life" }
            alertController.addAction(UIAlertAction(title: Constants.Strings.search.locale, style: .default) { [weak alertController] _ in
                guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
                completion(textField.text.trim())
            })
            alertController.addAction(UIAlertAction(title: Constants.Strings.cancel.locale, style: .cancel, handler: nil))
            vc.present(alertController, animated: true, completion: nil)
        }
    }

    func duplicateError(_ vc: UIViewController, _ type: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.Strings.duplicateTitle.locale, message: "\(type) \(Constants.Strings.duplicateBody.locale)", preferredStyle: .alert)
            vc.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    alert.dismiss(animated: true)
                }
            }
        }
    }

    func savedInfo(_ vc: UIViewController, _ type: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.Strings.savedTitle.locale, message: "\(type) \(Constants.Strings.savedBody.locale)", preferredStyle: .alert)
            vc.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    alert.dismiss(animated: true)
                }
            }
        }
    }

    func loadingDonation(_ vc: UIViewController, _ completion: @escaping (UIAlertController) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.Strings.coffeeLoading.locale, message: "☕️  ☕️  ☕️", preferredStyle: .alert)
            vc.present(alert, animated: true) {
                completion(alert)
            }
        }
    }

    func resultDonation(_ vc: UIViewController, _ result: Bool) {
        let alert = UIAlertController(title: result ? Constants.Strings.coffeeSuccessTitle.locale : Constants.Strings.coffeeErrorTitle.locale, message: result ? Constants.Strings.coffeeSuccessBody.locale : Constants.Strings.coffeeErrorBody.locale, preferredStyle: .alert)
        vc.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                alert.dismiss(animated: true)
            }
        }
    }

    func notificationError(_ vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.Strings.warning.locale, message: Constants.Strings.warningReminder.locale, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Strings.no.locale, style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: Constants.Strings.settings.locale, style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            vc.present(alert, animated: true)
        }
    }

    func emailError(_ vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.Strings.noEmailTitle.locale, message: Constants.Strings.noEmailBody.locale, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Strings.okay.locale, style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }

    func errorNotAvailable(_ vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.Strings.notAvailableTitle.locale, message: Constants.Strings.notAvailableBody.locale, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Strings.okay.locale, style: .cancel, handler: nil))
            vc.present(alert, animated: true)
        }
    }

    func restartNeeded(_ vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Constants.Strings.restartTitle.locale, message: Constants.Strings.restartBody.locale, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Strings.restartButton.locale, style: .destructive, handler: { _ in
                exit(0)
            }))
            alert.addAction(UIAlertAction(title: Constants.Strings.later.locale, style: .cancel))
            vc.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                    alert.dismiss(animated: true)
                }
            }
        }
    }
}
