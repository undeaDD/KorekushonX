import Foundation

/// `KeychainError` defines the set of errors used in `SingleKeychainStore`.
public enum KeychainError: Error {
	/// Unable to save obejct to Keychain
	case saveFailure
}

extension KeychainError: LocalizedError {
	/// Error description
	public var errorDescription: String? {
		return localizedDescription
	}

	/// Error localized description
	public var localizedDescription: String {
		return "Unable to save obejct to Keychain"
	}
}
