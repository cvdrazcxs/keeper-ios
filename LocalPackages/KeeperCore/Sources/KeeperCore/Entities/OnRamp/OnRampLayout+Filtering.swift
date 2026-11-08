public extension OnRampLayout {
    func filteredByCashOrCryptoAvailability(isAvailable: Bool) -> OnRampLayout {
        guard !isAvailable else {
            return self
        }

        return OnRampLayout(items: [])
    }

    func filteredByTRC20Availability(isAvailable: Bool) -> OnRampLayout {
        guard !isAvailable else {
            return self
        }

        return OnRampLayout(
            items: items.compactMap { item in
                guard let assets = item.assets else {
                    return item
                }
                let filteredAssets = assets.compactMap { asset -> OnRampLayoutToken? in
                    guard !asset.isTronNetwork else { return nil }
                    return asset.filteringOutTronNetworks()
                }
                guard !filteredAssets.isEmpty else {
                    return nil
                }
                return OnRampLayoutItem(
                    type: item.type,
                    title: item.title,
                    itemDescription: item.itemDescription,
                    image: item.image,
                    preferredCurrency: item.preferredCurrency,
                    assets: filteredAssets
                )
            }
        )
    }
}

private extension OnRampLayoutToken {
    func filteringOutTronNetworks() -> OnRampLayoutToken {
        OnRampLayoutToken(
            symbol: symbol,
            assetId: assetId,
            address: address,
            network: network,
            networkName: networkName,
            networkImage: networkImage,
            image: image,
            decimals: decimals,
            stablecoin: stablecoin,
            cashMethods: cashMethods,
            cryptoMethods: cryptoMethods.filter { !$0.isTronNetwork }
        )
    }
}
