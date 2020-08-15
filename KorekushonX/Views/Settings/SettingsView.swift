import MessageUI
import UIKit

class SettingsView: UITableViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    @IBAction private func dismiss() {
        if #available(iOS 13.0, *) {
            if let presenting = self.navigationController?.presentationController {
                presenting.delegate?.presentationControllerDidDismiss?(presenting)
            }
        }
        navigationController?.dismiss(animated: true)
    }

    @IBAction private func like() {
        if MFMailComposeViewController.canSendMail() {
            let composePicker = MFMailComposeViewController()
            composePicker.mailComposeDelegate = self
            composePicker.delegate = self
            composePicker.setToRecipients(["dominic.drees@live.de"])
            composePicker.setSubject("KorekushonX Feedback")
            present(composePicker, animated: true)
        } else {
            let alert = UIAlertController(title: "Kein Konto gefunden", message: "Du hast kein Mailkonto eingerichtet, um Feedback zu versenden. Hier ist meine Mail Adresse, falls du von einem anderen Gerät Feedback senden willst.\n\ndominic.drees@live.de", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Schade 😢", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webView", let dest = segue.destination as? SettingsWebView {
            switch sender as? Int ?? 0 {
            case 0:
                dest.file = "Impressum"
            case 1:
                dest.file = "Datenschutz"
            case 2:
                dest.file = "Lizenzen"
            default:
                dest.file = "Änderungen"
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let toggle = cell.contentView.subviews.last as? UISwitch {
            toggle.isOn = UserDefaults.standard.bool(forKey: "settingsSammlungShowCover")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let alert = UIAlertController(title: nil, message: "Sammlungs Ansicht auswählen\n( Benötigt einen App neustart! )", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Zeilen (Standard)", style: .default, handler: { _ in
                UserDefaults.standard.set(0, forKey: "settingsSammlungView")
            }))

            alert.addAction(UIAlertAction(title: "Buchrücken (Experimentell)", style: .default, handler: { _ in
                UserDefaults.standard.set(1, forKey: "settingsSammlungView")
            }))

            alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
            present(alert, animated: true)
        case (0, 1):
            if UIApplication.shared.supportsAlternateIcons {
                let alert = UIAlertController(title: nil, message: "App Symbol auswählen", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Hell (Standard)", style: .default, handler: { _ in
                    UIApplication.shared.setAlternateIconName(nil)
                }))

                alert.addAction(UIAlertAction(title: "Dunkel", style: .default, handler: { _ in
                    UIApplication.shared.setAlternateIconName("Dark")
                }))

                alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
                present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Nicht verfügbar", message: "Diese Funktion ist auf deinem Gerät leider nicht verfügbar.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                present(alert, animated: true)
            }
        case (0, 2):
            if let toggle = tableView.cellForRow(at: indexPath)?.contentView.subviews.last as? UISwitch {
                UserDefaults.standard.set(!toggle.isOn, forKey: "settingsSammlungShowCover")
                toggle.setOn(!toggle.isOn, animated: true)
            }
        case (0, 3):
            if #available(iOS 13.0, *) {
                let alert = UIAlertController(title: nil, message: "System Style auswählen", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Automatisch", style: .default, handler: { _ in
                    UIApplication.shared.delegate?.window??.overrideUserInterfaceStyle = .unspecified
                    UserDefaults.standard.set(0, forKey: "settingsAppStyle")
                }))

                alert.addAction(UIAlertAction(title: "Dark Mode", style: .default, handler: { _ in
                    UIApplication.shared.delegate?.window??.overrideUserInterfaceStyle = .dark
                    UserDefaults.standard.set(1, forKey: "settingsAppStyle")
                }))

                alert.addAction(UIAlertAction(title: "Light Mode", style: .default, handler: { _ in
                    UIApplication.shared.delegate?.window??.overrideUserInterfaceStyle = .light
                    UserDefaults.standard.set(2, forKey: "settingsAppStyle")
                }))

                alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
                present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "System updaten", message: "Diese Funktion ist erst mit iOS 13 kompatibel. Bitte update dein Gerät.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                present(alert, animated: true)
            }
        case (0, 4):
            let alert = UIAlertController(title: "Alle Daten reparieren", message: "Dies kann fehlerhafte Daten wiederherstellen und reparieren, aber auch löschen.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ja", style: .destructive, handler: { _ in
                SammlungManager.shared.repairAll()
            }))

            alert.addAction(UIAlertAction(title: "Nein", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        case (0, 5):
            let alert = UIAlertController(title: "Alles löschen? 😳", message: "Dadurch werden alle lokal gespeicherten Daten gelöscht.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ja", style: .destructive, handler: { _ in
                FilesStore<Manga>(uniqueIdentifier: "mangas").deleteAll()
                FilesStore<Book>(uniqueIdentifier: "books").deleteAll()
                FilesStore<Wunsch>(uniqueIdentifier: "wishes").deleteAll()
                UserDefaults.standard.set(true, forKey: "SammlungNeedsUpdating")
                UserDefaults.standard.set(true, forKey: "BooksNeedsUpdating")
                UserDefaults.standard.set(true, forKey: "WunschNeedsUpdating")
                ErinnerungManager.shared.removeAll()
            }))

            alert.addAction(UIAlertAction(title: "Nein", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        case (1, let index):
            performSegue(withIdentifier: "webView", sender: index)
        default:
            return
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
