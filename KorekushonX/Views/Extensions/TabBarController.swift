import ExpandedTabBar
import UIKit

class TabBarController: ExpandedTabBarController, ExpandedTabBarControllerDelegate {
    var snowView: SnowFallingView?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .secondarySystemBackground
        } else {
            self.view.backgroundColor = .white
        }

        UITabBarItem.appearance().setBadgeTextAttributes([.foregroundColor: UIColor.clear, .font: UIFont.systemFont(ofSize: 12, weight: .bold)], for: .normal)
        UITabBarItem.appearance().setBadgeTextAttributes([.foregroundColor: UIColor.systemPurple, .font: UIFont.systemFont(ofSize: 12, weight: .bold)], for: .selected)

        tabBar.layer.shadowOffset = CGSize(width: 0, height: 6)
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowRadius = 12.0
        tabBar.layer.shadowOpacity = 0.4
        delegate = self

        moreTitle = Constants.Strings.more.locale
        expandedTabBarOptions = options

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

     @objc func appMovedToBackground() {
        snowView?.removeFromSuperview()
        snowView = nil
    }

    @objc func appCameToForeground() {
        if snowView == nil {
            snowView = SnowFallingView(frame: UIScreen.main.bounds)
            snowView!.isUserInteractionEnabled = false
            view.addSubview(snowView!)
        }

        if let snowView = snowView {
            view.bringSubviewToFront(snowView)
            snowView.startSnow()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appCameToForeground()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        snowView?.removeFromSuperview()
        snowView = nil
    }

    private var options: Options {
        var options = ExpandedTabBarOptions()

        options.indicatorType = .triangle
        options.animationType = .top

        options.container.roundedCorners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        options.container.cornerRadius = 16

        if #available(iOS 13.0, *) {
            options.container.color = .secondarySystemGroupedBackground
        }
        options.container.tabSpace = 15
        options.container.tab.iconTitleSpace = 15
        options.container.tab.iconColor = .lightGray
        options.container.tab.titleColor = .lightGray

        return options
    }

    func expandedTabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController, withItem tabBarItem: UITabBarItem?) {
        tabBarController.tabBar.tintColor = .systemPurple
        (viewController as? UINavigationController)?.popToRootViewController(animated: false)
    }

    func addManga() {
        selectedIndex = 0
        (selectedViewController as? UINavigationController)?.topViewController?.performSegue(withIdentifier: Constants.Segues.edit.rawValue, sender: nil)
    }
}
