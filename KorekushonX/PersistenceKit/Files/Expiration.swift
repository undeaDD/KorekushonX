import Foundation

/// `Expiration` offers options about the validity of files stored in `FilesStore` and `SingleFileStore`.
public enum Expiration {
	/// Object will not expire automatically.
	case never

	/// Object will expire after the specified amount of seconds.
	case seconds(TimeInterval)

	/// Object will expire on the specified date.
	case date(Date)
}

// Source: https://github.com/hyperoslo/Cache/blob/master/Source/Shared/Library/Expiry.swift

extension Expiration {
	/// Returns the appropriate date object
	var date: Date {
		switch self {
		case .never:
			// Ref: http://lists.apple.com/archives/cocoa-dev/2005/Apr/msg01833.html
			return Date(timeIntervalSince1970: 60 * 60 * 24 * 365 * 68)
		case .seconds(let seconds):
			return Date().addingTimeInterval(seconds)
		case .date(let date):
			return date
		}
	}

	/// Checks if cached object is expired according to expiration date
	var isExpired: Bool {
		return date < Date()
	}
}
