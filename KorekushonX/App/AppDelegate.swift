import IQKeyboardManagerSwift
import Sheeeeeeeeet
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = .systemPurple
        window?.backgroundColor = .black

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = false
        IQKeyboardManager.shared.shouldPlayInputClicks = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.toolbarTintColor = .systemPurple

        let linkItem = ActionSheetLinkItemCell.appearance()
        linkItem.tintColor = .systemPurple
        linkItem.titleColor = .systemPurple

        ActionSheetSectionTitleCell.appearance().titleColor = .systemPurple
        let singleSelect = ActionSheetSingleSelectItemCell.appearance()
        singleSelect.selectedTintColor = .systemPurple
        singleSelect.selectedIcon = UIImage(named: Constants.Images.selected.rawValue)
        singleSelect.selectedTitleColor = .systemPurple
        singleSelect.selectedIconColor = .systemPurple
        singleSelect.unselectedIcon = UIImage(named: Constants.Images.unselected.rawValue)
        singleSelect.unselectedIconColor = .systemPurple
        let multiSelect = ActionSheetMultiSelectItemCell.appearance()
        multiSelect.selectedTintColor = .systemPurple
        multiSelect.selectedIcon = UIImage(named: Constants.Images.selected.rawValue)
        multiSelect.selectedTitleColor = .systemPurple
        multiSelect.selectedIconColor = .systemPurple
        multiSelect.unselectedIcon = UIImage(named: Constants.Images.unselected.rawValue)
        multiSelect.unselectedIconColor = .systemPurple

        if UserDefaults.standard.object(forKey: Constants.Keys.showCover.rawValue) == nil {
            UserDefaults.standard.set(true, forKey: Constants.Keys.showCover.rawValue)
        }

        if #available(iOS 13.0, *) {
            switch UserDefaults.standard.integer(forKey: Constants.Keys.appStyle.rawValue) {
            case 1:
                self.window?.overrideUserInterfaceStyle = .dark
            case 2:
                self.window?.overrideUserInterfaceStyle = .light
            default:
                self.window?.overrideUserInterfaceStyle = .unspecified
            }
        }

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, _ in
            UserDefaults.standard.set(granted, forKey: Constants.Keys.reminderActive.rawValue)
        }

        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
