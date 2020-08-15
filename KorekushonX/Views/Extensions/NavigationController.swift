import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .secondarySystemBackground
        } else {
            self.view.backgroundColor = .white
        }
    }
}

class SammlungNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .secondarySystemBackground
        } else {
            self.view.backgroundColor = .white
        }
        switch UserDefaults.standard.integer(forKey: "settingsSammlungView") {
        case 1:
            setViewControllers([UIStoryboard(name: "SammlungView", bundle: .main).instantiateViewController(withIdentifier: "BookView")], animated: false)
        default:
            setViewControllers([UIStoryboard(name: "SammlungView", bundle: .main).instantiateViewController(withIdentifier: "RowView")], animated: false)
        }
    }
}
