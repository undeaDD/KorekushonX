import IQKeyboardManagerSwift
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

        if UserDefaults.standard.object(forKey: "settingsSammlungShowCover") == nil {
            UserDefaults.standard.set(true, forKey: "settingsSammlungShowCover")
        }

        if #available(iOS 13.0, *) {
            switch UserDefaults.standard.integer(forKey: "settingsAppStyle") {
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
            UserDefaults.standard.set(granted, forKey: "ErinnerungActive")
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
