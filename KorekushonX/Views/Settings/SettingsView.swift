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
        applyFooter()
    }

    private func applyFooter() {
        if let footer = tableView.footerView(forSection: 1) {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
            footer.textLabel?.text = "\(Constants.Strings.version.locale): \(version) (\(build))"
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
        if segue.identifier == Constants.Segues.webView.rawValue, let dest = segue.destination as? SettingsWebView {
            switch sender as? Int ?? 0 {
            case 0:
                dest.file = Constants.HTML.imprint.rawValue
            case 1:
                dest.file = Constants.HTML.dataprotection.rawValue
            case 2:
                dest.file = Constants.HTML.licenses.rawValue
            default:
                dest.file = Constants.HTML.changelog.rawValue
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 3:
            if let toggle = cell.contentView.subviews.last as? UISwitch {
                toggle.isOn = UserDefaults.standard.bool(forKey: Constants.Keys.calculateColors.rawValue)
            }
        case 4:
            if let toggle = cell.contentView.subviews.last as? UISwitch {
                toggle.isOn = UserDefaults.standard.bool(forKey: Constants.Keys.showCover.rawValue)
            }
        case 5:
            if let toggle = cell.contentView.subviews.last as? UISwitch {
                toggle.isOn = UserDefaults.standard.bool(forKey: Constants.Keys.showAnimeView.rawValue)
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
                UserDefaults.standard.set(!toggle.isOn, forKey: Constants.Keys.calculateColors.rawValue)
                UserDefaults.standard.set(true, forKey: Constants.Keys.mangaReload.rawValue)
                toggle.setOn(!toggle.isOn, animated: true)
            }
        case (0, 4):
            if let toggle = tableView.cellForRow(at: indexPath)?.contentView.subviews.last as? UISwitch {
                UserDefaults.standard.set(!toggle.isOn, forKey: Constants.Keys.showCover.rawValue)
                toggle.setOn(!toggle.isOn, animated: true)
            }
        case (0, 5):
            if let toggle = tableView.cellForRow(at: indexPath)?.contentView.subviews.last as? UISwitch {
                UserDefaults.standard.set(!toggle.isOn, forKey: Constants.Keys.showAnimeView.rawValue)
                toggle.setOn(!toggle.isOn, animated: true)
                AlertManager.shared.restartNeeded(self)
            }
        case (0, 6):
            AlertManager.shared.loadingDonation(self) { alert in
                DonationManager.shared.donateCoffee { result in
                    alert.dismiss(animated: false) {
                        AlertManager.shared.resultDonation(self, result)
                    }
                }
            }
        case (0, 7):
            AlertManager.shared.repairData(self)
        case (0, 8):
            AlertManager.shared.removeAll(self)
        case (1, let index):
            performSegue(withIdentifier: Constants.Segues.webView.rawValue, sender: index)
        default:
            return
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
