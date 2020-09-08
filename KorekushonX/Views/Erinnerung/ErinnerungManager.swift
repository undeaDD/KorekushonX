import UIKit
import UserNotifications

class ErinnerungManager {
    var list: [Erinnerung] = []

    static let shared = ErinnerungManager()
    let formatter: DateFormatter = {
        let temp = DateFormatter()
        temp.dateStyle = .medium
        temp.timeStyle = .none
        temp.locale = NSLocale.current
        return temp
    }()

    private init() {}

    func rawCount() -> Int {
        return list.count
    }

    func shedule(_ title: String, _ date: Date, _ completion: @escaping () -> Void) {
        let content = UNMutableNotificationContent()
        content.title = Constants.Strings.remindMe.locale + ":"
        content.body = title
        content.sound = .default

        let uuid = UUID().uuidString
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error == nil {
                DispatchQueue.main.async {
                    completion()
                }
            }
        })
    }

    func removeAll() {
        for erinnerung in list {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [erinnerung.id])
        }
        UserDefaults.standard.set(true, forKey: Constants.Keys.remindReload.rawValue)
    }

    func removeErinnerung(_ erinnerung: Erinnerung) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [erinnerung.id])
        UserDefaults.standard.set(true, forKey: Constants.Keys.remindReload.rawValue)
    }

    func reloadIfNeccessary(_ tableView: UITableView, _ force: Bool = false) {
        if force || UserDefaults.standard.bool(forKey: Constants.Keys.remindReload.rawValue) {
            UserDefaults.standard.set(false, forKey: Constants.Keys.remindReload.rawValue)
            UNUserNotificationCenter.current().getPendingNotificationRequests { list in
                self.list = []
                for item in list {
                    let date = Calendar.current.date(from: (item.trigger as! UNCalendarNotificationTrigger).dateComponents)
                    self.list.append(Erinnerung(id: item.identifier, title: item.content.body, date: date!.timeIntervalSince1970))
                }

                DispatchQueue.main.async {
                    UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { tableView.reloadData() })
                }
            }
        }
    }
}
