import UIKit

class WebImage {
    class func apiImage(_ search: String) -> UIImage {
        let semaphore = DispatchSemaphore(value: 0)
        var image: UIImage?
        let title = search.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        let url = "https://www.googleapis.com/books/v1/volumes?q=manga%20\(title)&fields=items(volumeInfo(imageLinks))&maxResults=10"

        var req = URLRequest(url: URL(string: url)!)
        req.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36", forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: req) { data, _, _ in
            if let data = data, let string = String(data: data, encoding: .utf8) {
                if let result = string.slice(from: "\"thumbnail\": \"", to: "\""), let imageUrl = URL(string: result.replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "http://", with: "https://")) {
                    print(imageUrl)
                    if let data = try? Data(contentsOf: imageUrl) {
                        image = UIImage(data: data)
                    }
                }
            } else {
                image = UIImage(named: "default")!
            }
            semaphore.signal()
        }.resume()

        _ = semaphore.wait(timeout: .distantFuture)
        return image ?? UIImage(named: "default")!
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

extension Optional where Wrapped == String {
    func trim() -> String {
        if let string = self {
            if string.isEmpty { return "-" } else {
                let result = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if result.isEmpty { return "-" } else {
                    return result
                }
            }
        } else { return "-" }
    }
}
