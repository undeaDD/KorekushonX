import Foundation

/// Conform to `Identifiable` protocol in uniquely identified objects you want to store in a `UserDefaultsStore`.
public protocol Identifiable {
	/// ID type.
	associatedtype ID: Hashable

	/// Id Key.
	static var idKey: WritableKeyPath<Self, ID> { get }
}
