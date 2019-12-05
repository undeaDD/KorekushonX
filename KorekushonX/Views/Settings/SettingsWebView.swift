import UIKit
import WebKit

class SettingsWebView: UIViewController {
    @IBOutlet private var webView: WKWebView!
    var file: String = "Impressum"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = file
    }
}
