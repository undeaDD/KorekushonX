import Foundation

/// Conform to `Identifiable` protocol in uniquely identified objects you want to store in a `UserDefaultsStore`.
public protocol Identifiable {
	/// ID type.
    // swiftlint:disable type_name
	associatedtype ID: Hashable
    // swiftlint:enable type_name

	/// Id Key.
	static var idKey: WritableKeyPath<Self, ID> { get }
}
