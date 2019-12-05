import Foundation

/// `SingleUserDefaultsStore` offers a convenient way to store a single `Codable` object in `UserDefaults`.
open class SingleUserDefaultsStore<T: Codable> {
	/// Store's unique identifier.
	///
	/// **Warning**: Never use the same identifier for two -or more- different stores.
	public let uniqueIdentifier: String

	/// JSON encoder. _default is JSONEncoder()_
	open var encoder = JSONEncoder()

	/// JSON decoder. _default is JSONDecoder()_
	open var decoder = JSONDecoder()

	/// UserDefaults store.
	private var store: UserDefaults

	/// 1tialize store with given identifier.
	///
	/// **Warning**: Never use the same identifier for two -or more- different stores.
	///
	/// - Parameter uniqueIdentifier: store's unique identifier.
	public required init?(uniqueIdentifier: String) {
		guard let store = UserDefaults(suiteName: uniqueIdentifier) else { return nil }
		self.uniqueIdentifier = uniqueIdentifier
		self.store = store
	}

	/// Save object to store.
	///
	/// - Parameter object: object to save.
	/// - Throws: JSON encoding error.
	public func save(_ object: T) throws {
		let data = try encoder.encode(generateDict(for: object))
		store.set(data, forKey: key)
	}

	/// Save optional object (if not nil) to store.
	///
	/// - Parameter optionalObject: optional object to save.
	/// - Throws: JSON encoding error.
	public func save(_ optionalObject: T?) throws {
		guard let object = optionalObject else { return }
		try save(object)
	}

	/// Get object from store.
	public var object: T? {
		guard let data = store.data(forKey: key) else { return nil }
		guard let dict = try? decoder.decode([String: T].self, from: data) else { return nil }
		return extractObject(from: dict)
	}

	/// Delete object from store.
	public func delete() {
		store.set(nil, forKey: key)
		store.removeSuite(named: uniqueIdentifier)
	}

	/// Check if store has an object.
	public var hasObject: Bool {
		return object != nil
	}
}

// MARK: - Helpers
private extension SingleUserDefaultsStore {
	/// Enclose the object in a dictionary to enable single object storing.
	///
	/// - Parameter object: object.
	/// - Returns: dictionary enclosing object.
	func generateDict(for object: T) -> [String: T] {
		return [key: object]
	}

	/// Extract object from dictionary.
	///
	/// - Parameter dict: dictionary.
	/// - Returns: object.
	func extractObject(from dict: [String: T]) -> T? {
		return dict[key]
	}

	/// Store key for object.
	var key: String {
		return "\(uniqueIdentifier)-single-object"
	}
}
