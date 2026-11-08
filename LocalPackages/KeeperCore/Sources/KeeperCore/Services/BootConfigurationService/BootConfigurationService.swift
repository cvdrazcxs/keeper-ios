import Foundation

protocol BootConfigurationService {
    func getConfiguration() throws -> BootConfigurations
    func loadConfiguration() async throws -> BootConfigurations
}

final class BootConfigurationServiceImplementation: BootConfigurationService {
    private let api: BootConfigurationAPI
    private let repository: BootConfigurationRepository

    init(
        api: BootConfigurationAPI,
        repository: BootConfigurationRepository
    ) {
        self.api = api
        self.repository = repository
    }

    func getConfiguration() throws -> BootConfigurations {
        try repository.configuration
    }

    func loadConfiguration() async throws -> BootConfigurations {
        let configuration = try await api.loadConfigurations()
        try? repository.saveConfiguration(configuration)
        return configuration
    }
}
