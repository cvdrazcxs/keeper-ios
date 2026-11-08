import Foundation
import TKFeatureFlags

public final class ConfigurationAssembly {
    private let bootConfigurationAPIAssembly: BootConfigurationAPIAssembly
    private let coreAssembly: CoreAssembly
    private let featureFlags: TKFeatureFlags
    private let tkAppSettings: TKAppSettings

    init(
        bootConfigurationAPIAssembly: BootConfigurationAPIAssembly,
        featureFlags: TKFeatureFlags,
        tkAppSettings: TKAppSettings,
        coreAssembly: CoreAssembly
    ) {
        self.coreAssembly = coreAssembly
        self.featureFlags = featureFlags
        self.tkAppSettings = tkAppSettings
        self.bootConfigurationAPIAssembly = bootConfigurationAPIAssembly
    }

    private weak var _configuration: Configuration?
    public var configuration: Configuration {
        if let configuration = _configuration {
            return configuration
        } else {
            let configuration = Configuration(
                bootConfigurationService: bootConfigurationService(),
                featureFlags: featureFlags,
                tkAppSettings: tkAppSettings
            )
            _configuration = configuration
            return configuration
        }
    }

    func bootConfigurationService() -> BootConfigurationService {
        BootConfigurationServiceImplementation(
            api: bootConfigurationAPIAssembly.api,
            repository: bootConfigurationRepository()
        )
    }

    func bootConfigurationRepository() -> BootConfigurationRepository {
        BootConfigurationRepositoryImplementation(
            fileSystemVault: coreAssembly.fileSystemVault()
        )
    }
}
