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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let footer = tableView.footerView(forSection: 1) {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
            footer.textLabel?.text = "Version: \(version) (\(build))"
            footer.sizeToFit()
        }
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
            AlertManager.shared.emailError(self)
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
        switch indexPath.row {
        case 3:
            if let toggle = cell.contentView.subviews.last as? UISwitch {
                toggle.isOn = UserDefaults.standard.bool(forKey: "settingsSammlungShowCover")
            }
        case 4:
            if let toggle = cell.contentView.subviews.last as? UISwitch {
                toggle.isOn = UserDefaults.standard.bool(forKey: "settingsShowAnimeView")
            }
        default:
            return
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            AlertManager.shared.selectSammlungType(self)
        case (0, 1):
            AlertManager.shared.selectAppIcon(self)
        case (0, 2):
            if #available(iOS 13.0, *) {
                AlertManager.shared.selectSystemStyle(self)
            } else {
                AlertManager.shared.errorNotAvailable(self)
            }
        case (0, 3):
            if let toggle = tableView.cellForRow(at: indexPath)?.contentView.subviews.last as? UISwitch {
                UserDefaults.standard.set(!toggle.isOn, forKey: "settingsSammlungShowCover")
                toggle.setOn(!toggle.isOn, animated: true)
            }
        case (0, 4):
            if let toggle = tableView.cellForRow(at: indexPath)?.contentView.subviews.last as? UISwitch {
                UserDefaults.standard.set(!toggle.isOn, forKey: "settingsShowAnimeView")
                toggle.setOn(!toggle.isOn, animated: true)
                AlertManager.shared.restartNeeded(self)
            }
        case (0, 5):
            AlertManager.shared.repairData(self)
        case (0, 6):
            AlertManager.shared.removeAll(self)
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
