import Foundation

/// `SingleFileStore` offers a convenient way to store a single `Codable` objects in the files system.
open class SingleFileStore<T: Codable> {
	/// Store's unique identifier.
	///
	/// **Warning**: Never use the same identifier for two -or more- different stores.
	public let uniqueIdentifier: String

	/// Store `Expiration` option. _default is .never_
	public let expiration: Expiration

	/// JSON encoder. _default is JSONEncoder()_
	open var encoder = JSONEncoder()

	/// JSON decoder. _default is JSONDecoder()_
	open var decoder = JSONDecoder()

	/// FileManager. _default is FileManager.default_
	private var manager = FileManager.default

	/// Initialize store with given identifier.
	///
	/// **Warning**: Never use the same identifier for two -or more- different stores.
	///
	/// - Parameters:
	///   - uniqueIdentifier: store's unique identifier.
	///   - expiryDuration: optional store's expiry duration _default is .never_.
	public required init(uniqueIdentifier: String, expiration: Expiration = .never) {
		self.uniqueIdentifier = uniqueIdentifier
		self.expiration = expiration
	}

	/// Save object to store.
	///
	/// - Parameter object: object to save.
	/// - Throws: `FileManager` or JSON encoding error.
	public func save(_ object: T) throws {
		let data = try encoder.encode(generateDict(for: object))
		let url = try storeURL()
		try manager.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
		manager.createFile(atPath: try fileURL().path, contents: data, attributes: nil)

		let attributes: [FileAttributeKey: Any] = [
			.creationDate: Date(),
			.modificationDate: expiration.date
		]

		try manager.setAttributes(attributes, ofItemAtPath: fileURL().path)
	}

	/// Save optional object (if not nil) to store.
	///
	/// - Parameter optionalObject: optional object to save.
	/// - Throws: `FileManager` or JSON encoding error.
	public func save(_ optionalObject: T?) throws {
		guard let object = optionalObject else { return }
		try save(object)
	}

	/// Get object from store.
	public var object: T? {
		guard let path = try? fileURL().path else { return nil }
		guard let data = manager.contents(atPath: path) else { return nil }

		guard let attributes = try? manager.attributesOfItem(atPath: path) else { return nil }
		guard let modificationDate = attributes[.modificationDate] as? Date else { return nil }
		guard modificationDate >= Date() else {
			try? delete()
			return nil
		}

		guard let dict = try? decoder.decode([String: T].self, from: data) else { return nil }
		return extractObject(from: dict)
	}

	/// Delete object from store.
	public func delete() throws {
		let url = try storeURL()
		guard manager.fileExists(atPath: url.path) else { return }
		try manager.removeItem(at: url)
	}

	/// Check if store has an object.
	public var hasObject: Bool {
		return object != nil
	}
}

// MARK: - Helpers
private extension SingleFileStore {
	/// Documents URL.
	///
	/// - Returns: Documents URL.
	/// - Throws: `FileManager` error
	func documentsURL() throws -> URL {
		let directory: FileManager.SearchPathDirectory
		switch expiration {
		case .never:
			directory = .documentDirectory
		default:
			directory = .cachesDirectory
		}

		return try manager.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
	}

	/// FilesStore URL.
	///
	/// - Returns: FilesStore URL.
	/// - Throws: `FileManager` error
	func filesStoreURL() throws -> URL {
		return try documentsURL().appendingPathComponent("FilesStore")
	}

	/// Store URL.
	///
	/// - Returns: Store URL.
	/// - Throws: `FileManager` error
	func storeURL() throws -> URL {
		return try filesStoreURL().appendingPathComponent(uniqueIdentifier, isDirectory: true)
	}

	/// URL for file.
	///
	/// - Returns: file URL.
	/// - Throws: `FileManager` error.
	func fileURL() throws -> URL {
		return try storeURL().appendingPathComponent(key)
	}

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
