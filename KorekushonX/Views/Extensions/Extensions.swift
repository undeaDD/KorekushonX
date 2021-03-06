import UIKit

struct WebImage {
    static func apiImage(_ search: String, _ prefix: String = "manga") -> UIImage {
        let semaphore = DispatchSemaphore(value: 0)
        var image: UIImage?
        let title = search.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        let url = "https://www.googleapis.com/books/v1/volumes?q=\(prefix)%20\(title)&fields=items(volumeInfo(imageLinks))&maxResults=10"

        var req = URLRequest(url: URL(string: url)!)
        req.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36", forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: req) { data, _, _ in
            if let data = data, let string = String(data: data, encoding: .utf8) {
                if let result = string.slice(from: "\"thumbnail\": \"", to: "\""), let imageUrl = URL(string: result.replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "http://", with: "https://")) {
                    if let data = try? Data(contentsOf: imageUrl) {
                        image = UIImage(data: data)
                    }
                }
            } else {
                image = UIImage(named: Constants.Images.default.rawValue)!
            }
            semaphore.signal()
        }.resume()

        _ = semaphore.wait(timeout: .distantFuture)
        return image ?? UIImage(named: Constants.Images.default.rawValue)!
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

    var firstCharacter: Character? {
        return isEmpty ? Character(self[startIndex].uppercased()) : nil
    }
}

extension Optional where Wrapped == String {
    func trim() -> String {
        if let string = self {
            if string.isEmpty { return Constants.Strings.unknown.rawValue } else {
                let result = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if result.isEmpty { return Constants.Strings.unknown.rawValue } else {
                    return result
                }
            }
        } else { return Constants.Strings.unknown.rawValue }
    }
}

extension Array {
    func toIndexedDictionary(by selector: (Element) -> String) -> [Character: [Element]] {
        var dictionary = [Character: [Element]]()
        for element in self {
            let selector = selector(element)
            guard let firstCharacter = selector.firstCharacter else { continue }

            if let list = dictionary[firstCharacter] {
                dictionary[firstCharacter] = list + [element]
            } else {
                dictionary[firstCharacter] = [element]
            }
        }
        return dictionary
    }
}

extension UIColor {
    var isDarkColor: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b < 0.50
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        guard let outputImage = CIFilter(name: Constants.Keys.areaAverage.rawValue, parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector])?.outputImage else { return nil }
        var bitmap = [UInt8](repeating: 0, count: 4)
        CIContext(options: [.workingColorSpace: kCFNull as Any]).render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

class ImagePickerView: UIImagePickerController { }
