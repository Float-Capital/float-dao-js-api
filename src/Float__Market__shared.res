type withProvider = {provider: Float__Ethers.providerType, marketIndex: int}
type withWallet = {wallet: Float__Ethers.walletType, marketIndex: int}

type withProviderOrWallet =
  | P(withProvider)
  | W(withWallet)

let wrapMarketP: withProvider => withProviderOrWallet = market => P(market)
let wrapMarketW: withWallet => withProviderOrWallet = market => W(market)
