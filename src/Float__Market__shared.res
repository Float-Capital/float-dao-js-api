// these are all in here instead of Market.res to avoid dependency cycles

type withProvider = {provider: Float__Ethers.providerType, marketIndex: int}
type withWallet = {wallet: Float__Ethers.walletType, marketIndex: int}

type withProviderOrWallet =
  | P(withProvider)
  | W(withWallet)

let wrapMarketP: withProvider => withProviderOrWallet = market => P(market)
let wrapMarketW: withWallet => withProviderOrWallet = market => W(market)

let fundingRateMultiplier = (provider, config, marketIndex): Promise.t<Float__Ethers.BigNumber.t> =>
    provider
    ->Float__Ethers.wrapProvider
    ->Float__Util.makeLongShortContract(config)
    ->Float__Contracts.LongShort.fundingRateMultiplier_e18(~marketIndex)

