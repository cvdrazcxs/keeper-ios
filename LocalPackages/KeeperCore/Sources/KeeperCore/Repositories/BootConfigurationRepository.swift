import Foundation
import KeeperCoreComponents

enum BootConfigurationRepositoryGetError: Error {
    case noDefaultConfigurationInBundle
    case defaultConfigurationCorrupted(error: Error)
}

enum BootConfigurationRepositorySaveError: Error {
    case writeFailed(error: Error)
}

protocol BootConfigurationRepository {
    var configuration: BootConfigurations {
        get throws(BootConfigurationRepositoryGetError)
    }

    func saveConfiguration(
        _ configuration: BootConfigurations
    ) throws(BootConfigurationRepositorySaveError)
}

struct BootConfigurationRepositoryImplementation: BootConfigurationRepository {
    let fileSystemVault: FileSystemVault<BootConfigurations, String>

    func saveConfiguration(
        _ configuration: BootConfigurations
    ) throws(BootConfigurationRepositorySaveError) {
        do {
            try fileSystemVault.saveItem(configuration, key: .fileVaultConfigurationKey)
        } catch {
            throw .writeFailed(error: error)
        }
    }

    var configuration: BootConfigurations {
        get throws(BootConfigurationRepositoryGetError) {
            if let configuration = try? fileSystemVault.loadItem(key: .fileVaultConfigurationKey) {
                return configuration
            }

            guard let url = Bundle.module.url(forResource: .defaultConfigurationFileName, withExtension: nil),
                  let data = try? Data(contentsOf: url)
            else {
                throw .noDefaultConfigurationInBundle
            }

            let decoder = JSONDecoder()
            do {
                return try decoder.decode(BootConfigurations.self, from: data)
            } catch {
                throw .defaultConfigurationCorrupted(error: error)
            }
        }
    }
}

private extension String {
    static let fileVaultConfigurationKey = "RemoteConfigurations"
    static let defaultConfigurationFileName = "DefaultBootConfiguration.json"
}
