import UIKit
import WebKit

class SettingsWebView: UIViewController {
    @IBOutlet private var webView: WKWebView!
    var file: String = "Impressum"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = file
        webView.scrollView.backgroundColor = .clear

        if let url = Bundle.main.url(forResource: file, withExtension: ".html") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
}
