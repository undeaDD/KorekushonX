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

        var array: [Int] = UserDefaults.standard.array(forKey: Constants.Keys.selectedSammlungView.rawValue) as? [Int] ?? [0]
        if array.isEmpty { array.append(0) }

        switch array.randomElement() {
        case 1:
            setViewControllers([UIStoryboard(name: Constants.Keys.sammlungView.rawValue, bundle: .main).instantiateViewController(withIdentifier: Constants.Keys.bookView.rawValue)], animated: false)
        case 2:
            setViewControllers([UIStoryboard(name: Constants.Keys.sammlungView.rawValue, bundle: .main).instantiateViewController(withIdentifier: Constants.Keys.compactView.rawValue)], animated: false)
        default:
            setViewControllers([UIStoryboard(name: Constants.Keys.sammlungView.rawValue, bundle: .main).instantiateViewController(withIdentifier: Constants.Keys.rowView.rawValue)], animated: false)
        }
    }
}
