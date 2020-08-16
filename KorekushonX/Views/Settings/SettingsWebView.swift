import UIKit
import WebKit

class SettingsWebView: UIViewController, WKNavigationDelegate {
    @IBOutlet private var webView: WKWebView!
    var file: String = "Impressum"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = file
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = self

        if let url = Bundle.main.url(forResource: file, withExtension: ".html") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}
