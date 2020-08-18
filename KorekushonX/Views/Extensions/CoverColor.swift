import UIKit

class CoverColor: Codable {
    private var _green: CGFloat = 0
    private var _blue: CGFloat = 0
    private var _red: CGFloat = 0
    private var alpha: CGFloat = 0

    init(color: UIColor) {
        color.getRed(&_red, green: &_green, blue: &_blue, alpha: &alpha)
    }

    var color: UIColor {
        get {
            return UIColor(red: _red, green: _green, blue: _blue, alpha: alpha)
        }
        set {
            newValue.getRed(&_red, green: &_green, blue: &_blue, alpha: &alpha)
        }
    }

    var cgColor: CGColor {
        get {
            return color.cgColor
        }
        set {
            UIColor(cgColor: newValue).getRed(&_red, green: &_green, blue: &_blue, alpha: &alpha)
        }
    }
}
